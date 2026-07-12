import 'package:flutter/material.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../a_auth/onboarding_screen.dart';
import '../a_auth/role_selection_screen.dart';
import '../a_auth/sign_in_screen.dart';
import '../a_auth/splash_screen.dart';
import '../a_auth/startup_verification_screen.dart';
import '../a_auth/student_setup_screen.dart';
import '../a_auth/verification_pending_screen.dart';
import '../b_student/application_detail_screen.dart';
import '../b_student/applications_screen.dart';
import '../b_student/apply_flow_screen.dart';
import '../b_student/chat_thread_screen.dart';
import '../b_student/explore_screen.dart';
import '../b_student/messages_list_screen.dart';
import '../b_student/notifications_screen.dart';
import '../b_student/opportunity_details_screen.dart';
import '../b_student/passport_screen.dart';
import '../b_student/profile_screen.dart';
import '../b_student/saved_screen.dart';
import '../b_student/student_shell.dart';
import '../c_startup/analytics_screen.dart';
import '../c_startup/applicant_detail_screen.dart';
import '../c_startup/dashboard_screen.dart';
import '../c_startup/pipeline_screen.dart';
import '../c_startup/post_role_screen.dart';
import '../c_startup/postings_screen.dart';
import '../c_startup/scheduler_screen.dart';
import '../c_startup/startup_profile_screen.dart';
import '../c_startup/startup_public_profile_screen.dart';
import '../c_startup/startup_shell.dart';
import '../d_states/empty_states_screen.dart';
import '../d_states/loading_states_screen.dart';
import '../d_states/offline_error_screen.dart';
import '../library/component_sheet_screen.dart';

class _Entry {
  final String code;
  final String title;
  final WidgetBuilder builder;
  const _Entry(this.code, this.title, this.builder);
}

/// Dev-only index of every screen, reachable directly for QA.
class ScreenGalleryScreen extends StatelessWidget {
  const ScreenGalleryScreen({super.key});

  // Throwaway sample data just for preview navigation — real fixture lists
  // are intentionally empty.
  static final _sampleOpportunity = Opportunity(
    id: 'sample',
    title: 'Flutter Developer Intern',
    startup: Fixtures.learnify,
    category: 'Engineering',
    skills: const ['Flutter', 'Firebase', 'UI Testing'],
    commitment: 'Part-time · 8–10 hrs/wk',
    location: 'On-campus · Kigali',
    compensation: 'Stipend',
    postedLabel: 'Posted 3 days ago',
    closesLabel: 'Closes in 12 days',
    applicantsCount: 4,
    matchPercent: 92,
    description: 'Sample opportunity for gallery preview.',
  );

  static final _sampleApplication = Application(
    id: 'sample',
    opportunity: _sampleOpportunity,
    status: ApplicationStatus.reviewing,
    appliedLabel: 'Applied 3 days ago',
  );

  static final _sampleApplicant = Applicant(
    name: 'Sample Applicant',
    initials: 'SA',
    avatarGradient: AppColors.avatarGradient,
    program: 'BSc Software Engineering',
    cohort: "Class of '27",
    city: 'Kigali',
    skills: const ['Flutter', 'Firebase'],
    matchPercent: 92,
    appliedLabel: '2h ago',
    motivation: 'Sample applicant for gallery preview.',
    screening: const {'Weekly hours': '8–10 hrs'},
    skillsFit: 0.95,
    availabilityFit: 1.0,
    interestsFit: 0.8,
    stage: PipelineStage.newApplicant,
  );

  @override
  Widget build(BuildContext context) {
    final opp = _sampleOpportunity;
    final application = _sampleApplication;
    final applicant = _sampleApplicant;

    final sections = <String, List<_Entry>>{
      'Group A · Auth & Onboarding': [
        _Entry('A1', 'Splash', (_) => const SplashScreen()),
        _Entry('A2', 'Onboarding carousel', (_) => const OnboardingScreen()),
        _Entry('A3', 'Role selection', (_) => const RoleSelectionScreen()),
        _Entry(
          'A4',
          'Sign in (+ A4-E error)',
          (_) => const SignInScreen(role: AppRole.student),
        ),
        _Entry('A5', 'Student setup wizard', (_) => const StudentSetupScreen()),
        _Entry(
          'A6',
          'Startup verification form',
          (_) => const StartupVerificationScreen(),
        ),
        _Entry(
          'A7',
          'Verification pending',
          (_) => const VerificationPendingScreen(startupName: 'My Startup'),
        ),
      ],
      'Group B · Student': [
        _Entry(
          'B1',
          'Home shell (Home/Explore/Applications/Profile)',
          (_) => const StudentShell(),
        ),
        _Entry(
          'B2',
          'Explore · filters (+ B2-E empty)',
          (_) => const ExploreScreen(),
        ),
        _Entry(
          'B3',
          'Opportunity details · Why you match',
          (_) => OpportunityDetailsScreen(opportunity: opp),
        ),
        _Entry(
          'B4',
          'Apply flow (3 steps + success)',
          (_) => ApplyFlowScreen(opportunity: opp),
        ),
        _Entry(
          'B5',
          'My Applications (+ B5-E empty)',
          (_) => const ApplicationsScreen(),
        ),
        _Entry(
          'B6',
          'Application detail · timeline',
          (_) => ApplicationDetailScreen(application: application),
        ),
        _Entry('B7', 'Saved opportunities', (_) => const SavedScreen()),
        _Entry(
          'B8',
          'Notifications center',
          (_) => const NotificationsScreen(),
        ),
        _Entry('B9', 'Messages list', (_) => const MessagesListScreen()),
        _Entry(
          'B10',
          'Chat thread',
          (_) => const ChatThreadScreen(
            startupUid: 'dev-startup-uid',
            startupName: 'Learnify',
            startupGradientSeed: 0,
          ),
        ),
        _Entry('B11', 'Student profile', (_) => const ProfileScreen()),
        _Entry('B12', 'Experience Passport', (_) => const PassportScreen()),
      ],
      'Group C · Startup': [
        _Entry('C1', 'Startup dashboard shell', (_) => const StartupShell()),
        _Entry('—', 'Dashboard tab only', (_) => const DashboardScreen()),
        _Entry('—', 'Postings tab only', (_) => const PostingsScreen()),
        _Entry('C2', 'Post a role wizard', (_) => const PostRoleScreen()),
        _Entry(
          'C3',
          'Applicant pipeline · kanban',
          (_) => const PipelineScreen(),
        ),
        _Entry(
          'C4',
          'Applicant detail · embedded passport',
          (_) => ApplicantDetailScreen(applicant: applicant),
        ),
        _Entry('C5', 'Startup analytics', (_) => const AnalyticsScreen()),
        _Entry(
          'C6',
          'Startup public profile',
          (_) => StartupPublicProfileScreen(startup: Fixtures.learnify),
        ),
        _Entry(
          'C7',
          'Interview scheduler',
          (_) => SchedulerScreen(applicant: applicant),
        ),
        _Entry('—', 'Startup profile tab', (_) => const StartupProfileScreen()),
      ],
      'Group D · System states': [
        _Entry(
          'D1',
          'Loading · home skeleton',
          (_) => const LoadingStatesScreen(),
        ),
        _Entry('D2', 'Empty states', (_) => const EmptyStatesScreen()),
        _Entry('D3', 'Error · offline', (_) => const OfflineErrorScreen()),
      ],
      'Library': [
        _Entry('★', 'Component sheet', (_) => const ComponentSheetScreen()),
      ],
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ALULink · Screen gallery'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: sections.entries.expand((section) sync* {
          yield Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              section.key.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: .6,
              ),
            ),
          );
          for (final e in section.value) {
            yield ListTile(
              leading: SizedBox(
                width: 34,
                child: Text(
                  e.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
              title: Text(
                e.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkFaint,
              ),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: e.builder)),
            );
          }
        }).toList(),
      ),
    );
  }
}
