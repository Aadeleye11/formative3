import 'package:material_symbols_icons/symbols.dart';
import '../theme.dart';
import 'models.dart';

/// Single-user local state + brand palette. Marketplace data itself comes
/// from Firestore via MarketplaceRepository, not from here.
abstract final class Fixtures {
  /// The signed-in student's profile, replaced once they finish the setup
  /// wizard. These are just defaults until then.
  static StudentProfile amina = const StudentProfile(
    name: '',
    initials: '',
    program: '',
    cohort: '',
    city: '',
    skills: [],
    hoursPerWeek: 10,
    workStyle: 'Hybrid',
    interests: [],
  );

  /// "N verified experiences · M endorsed skills" — always "0 · 0" until
  /// verified work history has a real backend.
  static String get passportSummary {
    final entries = passport;
    final skills = <String>{};
    for (final e in entries) {
      skills.addAll(e.skills);
    }
    final roles = entries.length;
    final skillCount = skills.length;
    return '$roles verified experience${roles == 1 ? '' : 's'} · '
        '$skillCount endorsed skill${skillCount == 1 ? '' : 's'}';
  }

  // Brand palette used only by dev tooling (component sheet, screen gallery).

  static const StartupBrand learnify = StartupBrand(
    name: 'Learnify',
    gradient: AppColors.logoLearnify,
    icon: Symbols.school_rounded,
    category: 'Edtech',
    stage: 'MVP',
    city: 'Kigali',
    teamSize: 4,
    founded: 2025,
    oneLiner: 'Peer-powered revision app for ALU students',
    description:
        'Built at the ALU Venture Lab, Learnify helps 400+ students revise with peer-made decks and spaced repetition — offline mode shipping this term.',
  );

  static const StartupBrand eduBridge = StartupBrand(
    name: 'EduBridge',
    gradient: AppColors.logoEduBridge,
    icon: Symbols.menu_book_rounded,
    category: 'Edtech',
    stage: 'Revenue',
    city: 'Kigali',
    teamSize: 6,
    founded: 2024,
    oneLiner: 'Mentorship matching for ALU alumni & students',
    description:
        'EduBridge connects students with alumni mentors across Africa.',
  );

  static const StartupBrand greenLoop = StartupBrand(
    name: 'GreenLoop',
    gradient: AppColors.logoGreenLoop,
    icon: Symbols.eco_rounded,
    category: 'Climate',
    stage: 'MVP',
    city: 'Kigali',
    teamSize: 5,
    founded: 2025,
    oneLiner: 'Campus composting & recycling rewards',
    description: 'GreenLoop turns campus recycling into rewards for students.',
  );

  static const StartupBrand sokoFresh = StartupBrand(
    name: 'SokoFresh',
    gradient: AppColors.logoSokoFresh,
    icon: Symbols.storefront_rounded,
    category: 'Agritech',
    stage: 'Revenue',
    city: 'Remote',
    teamSize: 8,
    founded: 2023,
    oneLiner: 'Fresh produce marketplace for campus & city',
    description: 'SokoFresh connects smallholder farmers directly to buyers.',
  );

  static const StartupBrand ileZao = StartupBrand(
    name: 'IleZao',
    gradient: AppColors.logoIleZao,
    icon: Symbols.agriculture_rounded,
    category: 'Agritech',
    stage: 'Idea',
    city: 'On-campus',
    teamSize: 3,
    founded: 2026,
    oneLiner: 'Precision agriculture sensors for smallholders',
    description:
        'IleZao builds low-cost soil sensors for precision agriculture.',
  );

  static const StartupBrand koraHealth = StartupBrand(
    name: 'Kora Health',
    gradient: AppColors.logoKoraHealth,
    icon: Symbols.favorite_rounded,
    category: 'Health',
    stage: 'MVP',
    city: 'Kigali',
    teamSize: 5,
    founded: 2025,
    oneLiner: 'Appointment booking for community clinics',
    description: 'Kora Health streamlines appointment booking for clinics.',
  );

  static const StartupBrand payNest = StartupBrand(
    name: 'PayNest',
    gradient: AppColors.logoSokoFresh,
    icon: Symbols.account_balance_wallet_rounded,
    category: 'Fintech',
    stage: 'Revenue',
    city: 'Kigali',
    teamSize: 9,
    founded: 2023,
    oneLiner: 'Savings circles for student communities',
    description: 'PayNest digitizes rotating savings circles for students.',
  );

  // Intentionally empty — real marketplace data comes from Firestore.

  static final List<Opportunity> opportunities = [];

  static final List<Application> applications = [];

  static int get shortlistedCount => applications
      .where((a) => a.status == ApplicationStatus.shortlisted)
      .length;
  static int get acceptedCount =>
      applications.where((a) => a.status == ApplicationStatus.accepted).length;

  static const List<PassportEntry> passport = [];

  static const List<NotificationItem> notifications = [];

  static final List<Applicant> applicants = [];
}
