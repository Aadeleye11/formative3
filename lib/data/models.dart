import 'dart:typed_data';

import 'package:flutter/material.dart';

enum AppRole { student, startup }

enum ApplicationStatus {
  applied,
  reviewing,
  interview,
  shortlisted,
  accepted,
  closed,
  declined,
}

extension ApplicationStatusX on ApplicationStatus {
  String get label => switch (this) {
    ApplicationStatus.applied => 'Applied',
    ApplicationStatus.reviewing => 'Under Review',
    ApplicationStatus.interview => 'Interview',
    ApplicationStatus.shortlisted => 'Shortlisted',
    ApplicationStatus.accepted => 'Accepted',
    ApplicationStatus.closed => 'Closed',
    ApplicationStatus.declined => 'Declined',
  };
}

enum PipelineStage { newApplicant, reviewing, interview, offer }

class StartupBrand {
  final String name;
  final Gradient gradient;
  final IconData icon;
  final String category;
  final String stage;
  final String city;
  final int teamSize;
  final int founded;
  final String oneLiner;
  final String description;

  /// True once a founder has completed verification.
  final bool verified;

  /// The founder's uploaded logo, if any. Shown instead of the gradient/icon
  /// fallback in [LogoTile].
  final Uint8List? logoBytes;

  const StartupBrand({
    required this.name,
    required this.gradient,
    required this.icon,
    required this.category,
    required this.stage,
    required this.city,
    required this.teamSize,
    required this.founded,
    required this.oneLiner,
    required this.description,
    this.verified = true,
    this.logoBytes,
  });
}

class StudentProfile {
  final String name;
  final String initials;
  final String program;
  final String cohort;
  final String city;
  final List<String> skills;
  final double hoursPerWeek;
  final String workStyle;
  final List<String> interests;
  final Uint8List? photoBytes;
  /// True once the student has finished the setup wizard. Gates "Switch to
  /// student workspace" so it never opens onto a blank profile.
  final bool hasCompletedSetup;

  const StudentProfile({
    required this.name,
    required this.initials,
    required this.program,
    required this.cohort,
    required this.city,
    required this.skills,
    required this.hoursPerWeek,
    required this.workStyle,
    required this.interests,
    this.photoBytes,
    this.hasCompletedSetup = false,
  });

  StudentProfile copyWith({
    String? name,
    String? initials,
    String? program,
    String? cohort,
    String? city,
    List<String>? skills,
    double? hoursPerWeek,
    String? workStyle,
    List<String>? interests,
    Uint8List? photoBytes,
    bool? hasCompletedSetup,
  }) {
    return StudentProfile(
      name: name ?? this.name,
      initials: initials ?? this.initials,
      program: program ?? this.program,
      cohort: cohort ?? this.cohort,
      city: city ?? this.city,
      skills: skills ?? this.skills,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      workStyle: workStyle ?? this.workStyle,
      interests: interests ?? this.interests,
      photoBytes: photoBytes ?? this.photoBytes,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }
}

enum ScreeningQuestionType { shortAnswer, singleChoice }

/// A founder-authored question attached to a posting. [options] only
/// applies to [singleChoice].
class ScreeningQuestion {
  final String id;
  final ScreeningQuestionType type;
  final String question;
  final List<String> options;

  const ScreeningQuestion({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
  });

  ScreeningQuestion copyWith({
    ScreeningQuestionType? type,
    String? question,
    List<String>? options,
  }) {
    return ScreeningQuestion(
      id: id,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }
}

class Opportunity {
  final String id;
  final String title;
  final StartupBrand startup;
  final String category;
  final List<String> skills;
  final String commitment;
  final String location;
  final String compensation;
  final String postedLabel;
  final String closesLabel;
  final int applicantsCount;
  final int matchPercent;
  final String description;
  bool saved;

  /// Firestore uid of the posting founder, if this is a live posting.
  final String? ownerUid;

  /// True if this is backed by a real Firestore document.
  final bool isLive;

  /// Screening questions asked of every applicant.
  final List<ScreeningQuestion> screeningQuestions;

  Opportunity({
    required this.id,
    required this.title,
    required this.startup,
    required this.category,
    required this.skills,
    required this.commitment,
    required this.location,
    required this.compensation,
    required this.postedLabel,
    required this.closesLabel,
    required this.applicantsCount,
    required this.matchPercent,
    required this.description,
    this.saved = false,
    this.ownerUid,
    this.isLive = false,
    this.screeningQuestions = const [],
  });
}

class MatchReason {
  final String label;
  final bool matched;
  const MatchReason(this.label, this.matched);
}

class Application {
  final String id;
  final Opportunity opportunity;
  ApplicationStatus status;
  final String appliedLabel;
  final String? interviewInfo;
  final DateTime? appliedAt;

  /// True if this is backed by a real Firestore document.
  final bool isLive;

  Application({
    required this.id,
    required this.opportunity,
    required this.status,
    required this.appliedLabel,
    this.interviewInfo,
    this.appliedAt,
    this.isLive = false,
  });
}

class PassportEntry {
  final StartupBrand startup;
  final String role;
  final String dates;
  final String quote;
  final String author;
  final List<String> skills;
  final String verifiedOn;

  const PassportEntry({
    required this.startup,
    required this.role,
    required this.dates,
    required this.quote,
    required this.author,
    required this.skills,
    required this.verifiedOn,
  });
}

/// One message inside a chat thread.
class ChatMessageDoc {
  final String id;
  final String senderUid;
  final String text;
  final DateTime? createdAt;

  const ChatMessageDoc({
    required this.id,
    required this.senderUid,
    required this.text,
    this.createdAt,
  });
}

/// One row in a Messages inbox. "Peer" is whichever side isn't me.
class ChatSummary {
  final String chatId;
  final String peerUid;
  final String peerName;
  final String peerInitials;
  final int peerGradientSeed;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final bool unread;

  const ChatSummary({
    required this.chatId,
    required this.peerUid,
    required this.peerName,
    required this.peerInitials,
    required this.peerGradientSeed,
    required this.lastMessage,
    this.lastMessageAt,
    this.unread = false,
  });
}

enum NotifKind { celebration, match, interview, message, status }

class NotificationItem {
  final NotifKind kind;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;

  const NotificationItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });
}

class Applicant {
  /// Firestore `applications` doc id, when [isLive].
  final String id;

  /// Firestore uid of the applying student, when [isLive].
  final String studentUid;

  /// The role they applied to.
  final String opportunityTitle;

  /// Which posting this application is for, used to group applicants by
  /// opportunity.
  final String opportunityId;
  final DateTime? appliedAt;
  final String name;
  final String initials;
  final Gradient avatarGradient;
  final String program;
  final String cohort;
  final String city;
  final List<String> skills;
  final int matchPercent;
  final String appliedLabel;
  final String motivation;
  final Map<String, String> screening;
  final double skillsFit;
  final double availabilityFit;
  final double interestsFit;
  final PassportEntry? passportEntry;
  final bool isLive;
  PipelineStage stage;

  Applicant({
    this.id = '',
    this.studentUid = '',
    this.opportunityTitle = '',
    this.opportunityId = '',
    this.appliedAt,
    required this.name,
    required this.initials,
    required this.avatarGradient,
    required this.program,
    required this.cohort,
    required this.city,
    required this.skills,
    required this.matchPercent,
    required this.appliedLabel,
    required this.motivation,
    required this.screening,
    required this.skillsFit,
    required this.availabilityFit,
    required this.interestsFit,
    this.passportEntry,
    this.isLive = false,
    required this.stage,
  });
}
