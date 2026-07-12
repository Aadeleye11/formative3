import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/fixtures.dart';
import '../data/models.dart';
import '../theme.dart';
import 'auth_service.dart';

const List<Gradient> _gradientPalette = [
  AppColors.logoLearnify,
  AppColors.logoEduBridge,
  AppColors.logoGreenLoop,
  AppColors.logoSokoFresh,
  AppColors.logoIleZao,
  AppColors.logoKoraHealth,
];

int _gradientSeedFor(String uid) =>
    uid.hashCode.abs() % _gradientPalette.length;

String _relativeLabel(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

double _skillsFit(List<String> have, List<String> required) {
  if (required.isEmpty) return 0.7;
  final haveLower = have.map((e) => e.toLowerCase()).toSet();
  final overlap = required
      .where((r) => haveLower.contains(r.toLowerCase()))
      .length;
  return (overlap / required.length).clamp(0.0, 1.0);
}

double _availabilityFit(String hoursChoice, String commitment) {
  if (hoursChoice.isEmpty || commitment.isEmpty) return 0.7;
  return commitment.toLowerCase().contains(hoursChoice.toLowerCase())
      ? 1.0
      : 0.65;
}

double _interestsFit(List<String> interests, String category) {
  return interests.map((e) => e.toLowerCase()).contains(category.toLowerCase())
      ? 1.0
      : 0.4;
}

/// Computed match score for a live posting/application.
int computeMatchPercent({
  required List<String> studentSkills,
  required List<String> studentInterests,
  required List<String> requiredSkills,
  required String category,
}) {
  final skills = _skillsFit(studentSkills, requiredSkills);
  final interests = _interestsFit(studentInterests, category);
  final pct = (skills * 0.75 + interests * 0.25) * 100;
  return pct.clamp(35, 99).round();
}

/// The single source of truth for every Firestore read/write in the app.
class MarketplaceRepository {
  MarketplaceRepository._();
  static final instance = MarketplaceRepository._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _db.collection('opportunities');
  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');
  CollectionReference<Map<String, dynamic>> get _startups =>
      _db.collection('startups');
  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');
  CollectionReference<Map<String, dynamic>> _notificationsFor(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  /// Reverse-lookup: a [Gradient] a screen already holds back to its palette
  /// index, for storing on a new Firestore doc.
  int gradientSeedFor(Gradient gradient) {
    final i = _gradientPalette.indexOf(gradient);
    return i < 0 ? 0 : i;
  }

  Gradient gradientForSeed(int seed) =>
      _gradientPalette[seed % _gradientPalette.length];

  // Notifications

  Future<void> _notify(
    String? uid, {
    required NotifKind kind,
    required String title,
    required String subtitle,
  }) async {
    if (uid == null || uid.isEmpty) return;
    await _notificationsFor(uid).add({
      'kind': kind.name,
      'title': title,
      'subtitle': subtitle,
      'unread': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// The signed-in user's real notifications (student or founder).
  Stream<List<NotificationItem>> watchMyNotifications() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _notificationsFor(user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final d = doc.data();
            final createdAt = (d['createdAt'] as Timestamp?)?.toDate();
            return NotificationItem(
              kind: NotifKind.values.byName(d['kind'] as String? ?? 'status'),
              title: d['title'] as String? ?? '',
              subtitle: d['subtitle'] as String? ?? '',
              time: createdAt != null ? _relativeLabel(createdAt) : 'now',
              unread: d['unread'] as bool? ?? true,
            );
          }).toList(),
        );
  }

  // Startup profile

  /// Saves the signed-in founder's startup identity.
  Future<void> saveStartupProfile({
    required String name,
    required String category,
    required String city,
    required String oneLiner,
    required String stage,
    Uint8List? logoBytes,
    String? affiliationProofName,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await _startups.doc(user.uid).set({
      'name': name,
      'category': category,
      'city': city,
      'oneLiner': oneLiner,
      'stage': stage,
      'gradientSeed': _gradientSeedFor(user.uid),
      'verified': true,
      'createdAt': FieldValue.serverTimestamp(),
      if (logoBytes != null) 'logoBase64': base64Encode(logoBytes),
      'affiliationProofName': ?affiliationProofName,
    }, SetOptions(merge: true));
  }

  /// Null until the signed-in founder completes verification.
  Stream<StartupBrand?> watchMyStartup() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(null);
    return _startups.doc(user.uid).snapshots().map((doc) {
      final d = doc.data();
      if (d == null) return null;
      return _startupFromMap(d);
    });
  }

  /// One-shot version of [watchMyStartup], for gating logic.
  Future<StartupBrand?> getMyStartupOnce() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return null;
    final doc = await _startups.doc(user.uid).get();
    final d = doc.data();
    if (d == null) return null;
    return _startupFromMap(d);
  }

  /// Any founder's startup identity, looked up by uid.
  Future<StartupBrand?> getStartupByUid(String uid) async {
    final doc = await _startups.doc(uid).get();
    final d = doc.data();
    if (d == null) return null;
    return _startupFromMap(d);
  }

  StartupBrand _startupFromMap(Map<String, dynamic> d) => StartupBrand(
    name: d['name'] as String? ?? 'My Startup',
    gradient: _gradientPalette[(d['gradientSeed'] as num?)?.toInt() ?? 0],
    icon: Symbols.storefront_rounded,
    category: d['category'] as String? ?? '',
    stage: d['stage'] as String? ?? 'MVP',
    city: d['city'] as String? ?? '',
    teamSize: 1,
    founded: DateTime.now().year,
    oneLiner: d['oneLiner'] as String? ?? '',
    description: d['oneLiner'] as String? ?? '',
    verified: d['verified'] as bool? ?? false,
    logoBytes: (d['logoBase64'] as String?) != null
        ? base64Decode(d['logoBase64'] as String)
        : null,
  );

  // Posts

  Stream<List<Opportunity>> watchLiveOpportunities() {
    return _opportunities
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_opportunityFromDoc).toList());
  }

  /// Just the signed-in founder's own postings.
  Stream<List<Opportunity>> watchMyPostings() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _opportunities
        .where('startupId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) => snap.docs.map(_opportunityFromDoc).toList());
  }

  /// Only the owning founder can do this — see firestore.rules.
  Future<void> deleteOpportunity(String opportunityId) {
    return _opportunities.doc(opportunityId).delete();
  }

  Future<void> postOpportunity({
    required String title,
    required String category,
    required List<String> skills,
    required String commitment,
    required String location,
    required String compensation,
    required String description,
    String? closesLabel,
    List<ScreeningQuestion> screeningQuestions = const [],
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final startupDoc = await _startups.doc(user.uid).get();
    final s = startupDoc.data();
    await _opportunities.add({
      'startupId': user.uid,
      'startupName': s?['name'] as String? ?? user.displayName ?? 'My Startup',
      'startupCategory': s?['category'] as String? ?? category,
      'startupStage': s?['stage'] as String? ?? 'MVP',
      'startupCity': s?['city'] as String? ?? 'Kigali',
      'startupVerified': s?['verified'] as bool? ?? false,
      'gradientSeed':
          (s?['gradientSeed'] as num?)?.toInt() ?? _gradientSeedFor(user.uid),
      'title': title,
      'category': category,
      'skills': skills,
      'commitment': commitment,
      'location': location,
      'compensation': compensation,
      'description': description,
      'closesLabel': closesLabel,
      'postedAt': FieldValue.serverTimestamp(),
      'screeningQuestions': screeningQuestions
          .map(
            (q) => {
              'type': q.type.name,
              'question': q.question,
              'options': q.options,
            },
          )
          .toList(),
    });
  }

  Opportunity _opportunityFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    final skills = List<String>.from(d['skills'] as List? ?? const []);
    final category = d['category'] as String? ?? '';
    final postedAt = (d['postedAt'] as Timestamp?)?.toDate();
    final amina = Fixtures.amina;

    final startup = StartupBrand(
      name: d['startupName'] as String? ?? 'Startup',
      gradient: _gradientPalette[(d['gradientSeed'] as num?)?.toInt() ?? 0],
      icon: Symbols.storefront_rounded,
      category: d['startupCategory'] as String? ?? '',
      stage: d['startupStage'] as String? ?? '',
      city: d['startupCity'] as String? ?? '',
      teamSize: 1,
      founded: postedAt?.year ?? DateTime.now().year,
      oneLiner: '',
      description: '',
      verified: d['startupVerified'] as bool? ?? false,
    );

    return Opportunity(
      id: doc.id,
      title: d['title'] as String? ?? '',
      startup: startup,
      category: category,
      skills: skills,
      commitment: d['commitment'] as String? ?? '',
      location: d['location'] as String? ?? '',
      compensation: d['compensation'] as String? ?? '',
      postedLabel: postedAt != null
          ? 'Posted ${_relativeLabel(postedAt)}'
          : 'Just posted',
      closesLabel: d['closesLabel'] as String? ?? 'Open',
      applicantsCount: 0,
      matchPercent: computeMatchPercent(
        studentSkills: amina.skills,
        studentInterests: amina.interests,
        requiredSkills: skills,
        category: category,
      ),
      description: d['description'] as String? ?? '',
      ownerUid: d['startupId'] as String?,
      isLive: true,
      saved: List<String>.from(
        d['savedBy'] as List? ?? const [],
      ).contains(AuthService.instance.currentUser?.uid),
      screeningQuestions: _screeningQuestionsFromList(
        d['screeningQuestions'] as List?,
      ),
    );
  }

  List<ScreeningQuestion> _screeningQuestionsFromList(List? raw) {
    if (raw == null) return const [];
    return raw.indexed.map((entry) {
      final (i, q) = entry;
      final map = Map<String, dynamic>.from(q as Map);
      return ScreeningQuestion(
        id: 'q$i',
        type: ScreeningQuestionType.values.byName(
          map['type'] as String? ?? 'shortAnswer',
        ),
        question: map['question'] as String? ?? '',
        options: List<String>.from(map['options'] as List? ?? const []),
      );
    }).toList();
  }

  /// Toggles whether the signed-in student has saved this opportunity.
  Future<void> toggleSaved(Opportunity opportunity, bool saved) async {
    final user = AuthService.instance.currentUser;
    if (user == null || !opportunity.isLive) return;
    await _opportunities.doc(opportunity.id).update({
      'savedBy': saved
          ? FieldValue.arrayUnion([user.uid])
          : FieldValue.arrayRemove([user.uid]),
    });
  }

  /// Live opportunities the signed-in student has saved (for Saved screen).
  Stream<List<Opportunity>> watchMySavedOpportunities() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _opportunities
        .where('savedBy', arrayContains: user.uid)
        .snapshots()
        .map((snap) => snap.docs.map(_opportunityFromDoc).toList());
  }

  // Applying

  Future<void> apply({
    required Opportunity opportunity,
    required String motivation,
    required Map<String, String> screeningAnswers,
    required String hoursChoice,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final amina = Fixtures.amina;
    await _applications.add({
      'opportunityId': opportunity.id,
      'opportunityTitle': opportunity.title,
      'category': opportunity.category,
      'requiredSkills': opportunity.skills,
      'commitment': opportunity.commitment,
      'startupId': opportunity.ownerUid,
      'startupName': opportunity.startup.name,
      'startupGradientSeed': _gradientPalette.indexOf(
        opportunity.startup.gradient,
      ),
      'studentUid': user.uid,
      'studentName': amina.name,
      'studentInitials': amina.initials,
      'studentProgram': amina.program,
      'studentCohort': amina.cohort,
      'studentCity': amina.city,
      'studentSkills': amina.skills,
      'studentInterests': amina.interests,
      'motivation': motivation,
      'screeningAnswers': screeningAnswers,
      'hoursChoice': hoursChoice,
      'status': ApplicationStatus.applied.name,
      'appliedAt': FieldValue.serverTimestamp(),
      'interviewInfo': null,
    });
    await _notify(
      opportunity.ownerUid,
      kind: NotifKind.match,
      title: 'New applicant · ${amina.name}',
      subtitle: '${opportunity.title} · just applied',
    );
  }

  /// The signed-in student's own applications (for the Applications tab).
  Stream<List<Application>> watchMyApplications() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _applications
        .where('studentUid', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snap) => snap.docs.map(_applicationFromDoc).toList()..sort(
            (a, b) => (b.appliedAt ?? DateTime(0)).compareTo(
              a.appliedAt ?? DateTime(0),
            ),
          ),
        );
  }

  /// Student asks for a different interview time — notifies the founder.
  Future<void> requestReschedule(Application application) async {
    final user = AuthService.instance.currentUser;
    if (user == null || !application.isLive) return;
    await _notify(
      application.opportunity.ownerUid,
      kind: NotifKind.message,
      title: 'Reschedule requested',
      subtitle:
          '${Fixtures.amina.name} · ${application.opportunity.title} · '
          "wants a different interview time",
    );
  }

  /// Applicants across every posting the signed-in founder owns. Declined/
  /// closed ones are excluded — there's no "declined" Kanban column to show
  /// them in, so they'd otherwise resurface under "New".
  Stream<List<Applicant>> watchApplicantsForMyPostings() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _applications
        .where('startupId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snap) => snap.docs
              .where((doc) {
                final status = doc.data()['status'] as String?;
                return status != ApplicationStatus.declined.name &&
                    status != ApplicationStatus.closed.name;
              })
              .map(_applicantFromDoc)
              .toList()
            ..sort(
              (a, b) => (b.appliedAt ?? DateTime(0)).compareTo(
                a.appliedAt ?? DateTime(0),
              ),
            ),
        );
  }

  /// Declines an applicant outright, separate from the pipeline-stage moves.
  Future<void> declineApplicant(Applicant applicant) async {
    await _applications.doc(applicant.id).update({
      'status': ApplicationStatus.declined.name,
    });
    final role = applicant.opportunityTitle.isEmpty
        ? 'your application'
        : applicant.opportunityTitle;
    await _notify(
      applicant.studentUid,
      kind: NotifKind.status,
      title: "You weren't selected for this role",
      subtitle: role,
    );
  }

  /// Student-initiated status change, e.g. withdrawing. No notification —
  /// the student is the one making the change.
  Future<void> updateStatus(String applicationId, ApplicationStatus status) {
    return _applications.doc(applicationId).update({'status': status.name});
  }

  /// Founder-initiated pipeline move — notifies the applying student.
  Future<void> updateStage(Applicant applicant, PipelineStage stage) async {
    final status = _statusForStage(stage);
    await _applications.doc(applicant.id).update({'status': status.name});
    final role = applicant.opportunityTitle.isEmpty
        ? 'your application'
        : applicant.opportunityTitle;
    final isOffer = status == ApplicationStatus.accepted;
    await _notify(
      applicant.studentUid,
      kind: isOffer ? NotifKind.celebration : NotifKind.status,
      title: isOffer
          ? 'You got the offer! 🎉'
          : 'Your application moved to ${status.label}',
      subtitle: role,
    );
  }

  /// Writes proposed interview slots, moves the application to Interview,
  /// and notifies the student.
  Future<void> proposeInterview(
    Applicant applicant, {
    required List<String> slots,
    required String location,
  }) async {
    final info = '${slots.join(' · ')} · $location';
    await _applications.doc(applicant.id).update({
      'status': ApplicationStatus.interview.name,
      'interviewInfo': info,
    });
    final role = applicant.opportunityTitle.isEmpty
        ? 'your application'
        : applicant.opportunityTitle;
    await _notify(
      applicant.studentUid,
      kind: NotifKind.interview,
      title: 'Interview slots proposed',
      subtitle: '$role · $info',
    );
  }

  ApplicationStatus _statusForStage(PipelineStage stage) => switch (stage) {
    PipelineStage.newApplicant => ApplicationStatus.applied,
    PipelineStage.reviewing => ApplicationStatus.reviewing,
    PipelineStage.interview => ApplicationStatus.interview,
    PipelineStage.offer => ApplicationStatus.accepted,
  };

  PipelineStage _stageForStatus(ApplicationStatus status) => switch (status) {
    ApplicationStatus.applied => PipelineStage.newApplicant,
    ApplicationStatus.reviewing => PipelineStage.reviewing,
    ApplicationStatus.shortlisted => PipelineStage.reviewing,
    ApplicationStatus.interview => PipelineStage.interview,
    ApplicationStatus.accepted => PipelineStage.offer,
    ApplicationStatus.closed => PipelineStage.newApplicant,
    ApplicationStatus.declined => PipelineStage.newApplicant,
  };

  Application _applicationFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    final appliedAt = (d['appliedAt'] as Timestamp?)?.toDate();
    final gradientSeed = (d['startupGradientSeed'] as num?)?.toInt() ?? -1;
    final startup = StartupBrand(
      name: d['startupName'] as String? ?? 'Startup',
      gradient: gradientSeed >= 0 && gradientSeed < _gradientPalette.length
          ? _gradientPalette[gradientSeed]
          : AppColors.avatarGradient,
      icon: Symbols.storefront_rounded,
      category: d['category'] as String? ?? '',
      stage: '',
      city: '',
      teamSize: 1,
      founded: DateTime.now().year,
      oneLiner: '',
      description: '',
    );
    final opportunity = Opportunity(
      id: d['opportunityId'] as String? ?? doc.id,
      title: d['opportunityTitle'] as String? ?? '',
      startup: startup,
      category: d['category'] as String? ?? '',
      skills: List<String>.from(d['requiredSkills'] as List? ?? const []),
      commitment: d['commitment'] as String? ?? '',
      location: '',
      compensation: '',
      postedLabel: appliedAt != null ? _relativeLabel(appliedAt) : '',
      closesLabel: 'Open',
      applicantsCount: 0,
      matchPercent: 0,
      description: '',
      ownerUid: d['startupId'] as String?,
    );
    return Application(
      id: doc.id,
      opportunity: opportunity,
      status: ApplicationStatus.values.byName(
        d['status'] as String? ?? 'applied',
      ),
      appliedLabel: appliedAt != null
          ? 'Applied ${_relativeLabel(appliedAt)}'
          : 'Applied just now',
      interviewInfo: d['interviewInfo'] as String?,
      appliedAt: appliedAt,
      isLive: true,
    );
  }

  Applicant _applicantFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final appliedAt = (d['appliedAt'] as Timestamp?)?.toDate();
    final skills = List<String>.from(d['studentSkills'] as List? ?? const []);
    final interests = List<String>.from(
      d['studentInterests'] as List? ?? const [],
    );
    final requiredSkills = List<String>.from(
      d['requiredSkills'] as List? ?? const [],
    );
    final hoursChoice = d['hoursChoice'] as String? ?? '';
    final commitment = d['commitment'] as String? ?? '';
    final skillsFit = _skillsFit(skills, requiredSkills);
    final availabilityFit = _availabilityFit(hoursChoice, commitment);
    final interestsFit = _interestsFit(
      interests,
      d['category'] as String? ?? '',
    );
    final matchPercent =
        (skillsFit * 0.6 + availabilityFit * 0.2 + interestsFit * 0.2) * 100;
    final screeningAnswers = Map<String, String>.from(
      d['screeningAnswers'] as Map? ?? const {},
    );
    final status = ApplicationStatus.values.byName(
      d['status'] as String? ?? 'applied',
    );

    return Applicant(
      id: doc.id,
      studentUid: d['studentUid'] as String? ?? '',
      opportunityTitle: d['opportunityTitle'] as String? ?? '',
      opportunityId: d['opportunityId'] as String? ?? '',
      appliedAt: appliedAt,
      name: d['studentName'] as String? ?? 'Applicant',
      initials: d['studentInitials'] as String? ?? '?',
      avatarGradient: AppColors.avatarGradient,
      program: d['studentProgram'] as String? ?? '',
      cohort: d['studentCohort'] as String? ?? '',
      city: d['studentCity'] as String? ?? '',
      skills: skills,
      matchPercent: matchPercent.clamp(35, 99).round(),
      appliedLabel: appliedAt != null ? _relativeLabel(appliedAt) : '',
      motivation: d['motivation'] as String? ?? '',
      screening: {
        ...screeningAnswers,
        if (hoursChoice.isNotEmpty) 'Weekly hours': hoursChoice,
      },
      skillsFit: skillsFit,
      availabilityFit: availabilityFit,
      interestsFit: interestsFit,
      passportEntry: null,
      isLive: true,
      stage: _stageForStatus(status),
    );
  }

  // Chat

  /// Deterministic doc id so either side can find/create the thread with no
  /// extra query.
  String _chatIdFor(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Opens (creating if needed) the thread between the student and a
  /// startup. Safe to call every time the screen opens.
  Future<String> getOrCreateChatAsStudent({
    required String startupUid,
    required String startupName,
    required int startupGradientSeed,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw StateError('Not signed in');
    final amina = Fixtures.amina;
    final chatId = _chatIdFor(user.uid, startupUid);
    await _chats.doc(chatId).set({
      'studentUid': user.uid,
      'studentName': amina.name,
      'studentInitials': amina.initials,
      'startupUid': startupUid,
      'startupName': startupName,
      'startupGradientSeed': startupGradientSeed,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return chatId;
  }

  /// Opens (creating if needed) the thread with one of the founder's applicants.
  Future<String> getOrCreateChatAsStartup({
    required String studentUid,
    required String studentName,
    required String studentInitials,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw StateError('Not signed in');
    final myStartup = await getMyStartupOnce();
    final chatId = _chatIdFor(user.uid, studentUid);
    await _chats.doc(chatId).set({
      'studentUid': studentUid,
      'studentName': studentName,
      'studentInitials': studentInitials,
      'startupUid': user.uid,
      'startupName': myStartup?.name ?? 'My Startup',
      'startupGradientSeed': myStartup == null
          ? 0
          : gradientSeedFor(myStartup.gradient),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return chatId;
  }

  ChatSummary _chatSummaryAsStudent(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ChatSummary(
      chatId: doc.id,
      peerUid: d['startupUid'] as String? ?? '',
      peerName: d['startupName'] as String? ?? 'Startup',
      peerInitials: '',
      peerGradientSeed: (d['startupGradientSeed'] as num?)?.toInt() ?? 0,
      lastMessage: d['lastMessage'] as String? ?? '',
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      unread: d['studentUnread'] as bool? ?? false,
    );
  }

  ChatSummary _chatSummaryAsStartup(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ChatSummary(
      chatId: doc.id,
      peerUid: d['studentUid'] as String? ?? '',
      peerName: d['studentName'] as String? ?? 'Student',
      peerInitials: d['studentInitials'] as String? ?? '?',
      peerGradientSeed: 0,
      lastMessage: d['lastMessage'] as String? ?? '',
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      unread: d['startupUnread'] as bool? ?? false,
    );
  }

  /// The signed-in student's conversations (for the student Messages tab).
  Stream<List<ChatSummary>> watchMyChatsAsStudent() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _chats.where('studentUid', isEqualTo: user.uid).snapshots().map(
      (snap) =>
          snap.docs.map(_chatSummaryAsStudent).toList()..sort(
            (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
              a.lastMessageAt ?? DateTime(0),
            ),
          ),
    );
  }

  /// The signed-in founder's conversations (for the startup Messages inbox).
  Stream<List<ChatSummary>> watchMyChatsAsStartup() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _chats.where('startupUid', isEqualTo: user.uid).snapshots().map(
      (snap) =>
          snap.docs.map(_chatSummaryAsStartup).toList()..sort(
            (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
              a.lastMessageAt ?? DateTime(0),
            ),
          ),
    );
  }

  Stream<List<ChatMessageDoc>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final d = doc.data();
            return ChatMessageDoc(
              id: doc.id,
              senderUid: d['senderUid'] as String? ?? '',
              text: d['text'] as String? ?? '',
              createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
            );
          }).toList(),
        );
  }

  Future<void> sendMessage(
    String chatId,
    String text, {
    required bool senderIsStudent,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await _chats.doc(chatId).collection('messages').add({
      'senderUid': user.uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _chats.doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderUid': user.uid,
      'studentUnread': !senderIsStudent,
      'startupUnread': senderIsStudent,
    });
  }

  Future<void> markChatRead(String chatId, {required bool asStudent}) {
    return _chats.doc(chatId).update({
      asStudent ? 'studentUnread' : 'startupUnread': false,
    });
  }
}
