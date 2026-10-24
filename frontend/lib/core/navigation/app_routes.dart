import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/auth_screen.dart';
import '../../screens/home_dashboard_screen.dart';
import '../../screens/profile_setup_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Centralized route definitions for inHercue.
/// Mirrors the screen state enumeration from the Figma design reference (src/App.tsx).
class AppRoutes {
  AppRoutes._();

  // Root & Authentication
  static const String welcome = '/';
  static const String auth = '/auth';
  static const String profileSetup = '/profile-setup';

  // Core Hub & Shell
  static const String home = '/home';
  static const String checkin = '/checkin';
  static const String urgent = '/urgent';

  // Feature Modules
  static const String physical = '/physical';
  static const String mental = '/mental';
  static const String period = '/period';
  static const String patterns = '/patterns';
  static const String selfcare = '/selfcare';
  static const String guidance = '/guidance';
  static const String myths = '/myths';
  static const String passport = '/passport';
  static const String doctors = '/doctors';
  static const String summary = '/summary';
  static const String reminders = '/reminders';
  static const String settings = '/settings';
  static const String community = '/community';

  // Navigation Hub Destinations
  static const String records = '/records';
  static const String learn = '/learn';
  static const String profile = '/profile';
  static const String entry = '/entry';
  static const String symptoms = '/symptoms';
  static const String alerts = '/alerts';
  static const String reports = '/reports';

  /// Standard route table for the application.
  /// Destination screens are integrated as they are completed.
  static Map<String, WidgetBuilder> get routes => getRoutes();

  /// Builds the route table optionally injecting [AuthState] into screens.
  static Map<String, WidgetBuilder> getRoutes([AuthState? authState]) {
    return {
      welcome: (context) => const WelcomeScreen(),
      auth: (context) => AuthScreen(authState: authState),
      profileSetup: (context) => const ProfileSetupScreen(),
      home: (context) => HomeDashboardScreen(authState: authState),
      urgent: (context) => const DestinationPlaceholderScreen(
            title: 'Urgent Help',
            routeName: urgent,
          ),
      checkin: (context) => const DestinationPlaceholderScreen(
            title: 'Daily Check-In',
            routeName: checkin,
          ),
      physical: (context) => const DestinationPlaceholderScreen(
            title: 'Physical Health',
            routeName: physical,
          ),
      mental: (context) => const DestinationPlaceholderScreen(
            title: 'Mental Wellness',
            routeName: mental,
          ),
      period: (context) => const DestinationPlaceholderScreen(
            title: 'Period Tracker',
            routeName: period,
          ),
      patterns: (context) => const DestinationPlaceholderScreen(
            title: 'Health Patterns',
            routeName: patterns,
          ),
      selfcare: (context) => const DestinationPlaceholderScreen(
            title: 'Self-Care Studio',
            routeName: selfcare,
          ),
      guidance: (context) => const DestinationPlaceholderScreen(
            title: 'Wellness Guidance',
            routeName: guidance,
          ),
      myths: (context) => const DestinationPlaceholderScreen(
            title: 'Myth vs Fact',
            routeName: myths,
          ),
      passport: (context) => const DestinationPlaceholderScreen(
            title: 'Health Passport',
            routeName: passport,
          ),
      doctors: (context) => const DestinationPlaceholderScreen(
            title: 'Find a Doctor',
            routeName: doctors,
          ),
      summary: (context) => const DestinationPlaceholderScreen(
            title: 'Doctor Summary',
            routeName: summary,
          ),
      reminders: (context) => const DestinationPlaceholderScreen(
            title: 'Reminders',
            routeName: reminders,
          ),
      settings: (context) => const DestinationPlaceholderScreen(
            title: 'Settings',
            routeName: settings,
          ),
      community: (context) => const DestinationPlaceholderScreen(
            title: 'Community',
            routeName: community,
          ),
      records: (context) => const DestinationPlaceholderScreen(
            title: 'Health History',
            routeName: records,
          ),
      learn: (context) => const DestinationPlaceholderScreen(
            title: 'Learn',
            routeName: learn,
          ),
      profile: (context) => const DestinationPlaceholderScreen(
            title: 'Profile & Settings',
            routeName: profile,
          ),
      entry: (context) => const DestinationPlaceholderScreen(
            title: 'New Entry',
            routeName: entry,
          ),
      symptoms: (context) => const DestinationPlaceholderScreen(
            title: 'Symptom Tracker',
            routeName: symptoms,
          ),
      alerts: (context) => const DestinationPlaceholderScreen(
            title: 'Alerts',
            routeName: alerts,
          ),
      reports: (context) => const DestinationPlaceholderScreen(
            title: 'Health Reports',
            routeName: reports,
          ),
    };
  }
}

/// Fallback / placeholder destination for routes scheduled for upcoming milestones.
/// Accurately differentiates between demo exploration, authenticated sessions, and pending modules.
class DestinationPlaceholderScreen extends StatelessWidget {
  final String title;
  final String routeName;

  const DestinationPlaceholderScreen({
    super.key,
    required this.title,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final isDemo = (args is Map && args['isDemo'] == true) ||
        (routeName == AppRoutes.home &&
            !(AuthStateScope.maybeOf(context)?.isAuthenticated ?? false));

    final authState = AuthStateScope.maybeOf(context);
    final user = authState?.currentUser;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.screenHeading.copyWith(fontSize: 20.0),
        ),
        backgroundColor: AppColors.ivory,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.plum),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDemo) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: AppColors.gold, width: 1.0),
                    ),
                    child: Text(
                      'DEMO MODE (SAMPLE DATA)',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ] else if (user != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: AppColors.sage, width: 1.0),
                    ),
                    child: Text(
                      'AUTHENTICATED USER',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.sage,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
                Text(
                  title,
                  style: AppTextStyles.sectionHeading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  isDemo
                      ? 'You are viewing inHERcue in demo mode with sample data.\nThis is not an authenticated session and no personal records are saved.\n($routeName)'
                      : (user != null
                          ? 'Welcome, ${user.name}!\nYour authenticated session is active. Full dashboard is being assembled in the next milestone.\n($routeName)'
                          : 'Route: $routeName\nScheduled for implementation in upcoming milestone.'),
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
