import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_strings.dart';
import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/primary_button.dart';

/// The official Welcome / Landing screen for inHercue.
/// Directly mirrors `Welcome({ go })` from the Figma React/CSS reference:
/// - Radial gradient canvas (ivory glow)
/// - Top-right accessible "Urgent help" action
/// - Decorative background botanicals (`✦` and `☾`)
/// - Centered 62px circular heart badge (`.logo-mark`)
/// - "WELCOME TO" uppercase tracked kicker
/// - "inHERcue" Playfair Display display heading with responsive clamp
/// - Editorial subtitle in Playfair Display
/// - Plum pill primary button with right arrow ("Begin your journey →")
/// - Underlined text button ("Explore with demo data")
/// - Safety tagline ("Private by design • Guidance, never diagnosis")
class WelcomeScreen extends StatelessWidget {
  /// Callback when "Begin your journey" is pressed.
  /// If null, navigates to [AppRoutes.auth] via [Navigator].
  final VoidCallback? onBeginJourney;

  /// Callback when "Explore with demo data" is pressed.
  /// If null, navigates to [AppRoutes.home] via [Navigator].
  final VoidCallback? onExploreDemo;

  /// Callback when "Urgent help" is pressed.
  /// If null, navigates to [AppRoutes.urgent] via [Navigator].
  final VoidCallback? onUrgent;

  const WelcomeScreen({
    super.key,
    this.onBeginJourney,
    this.onExploreDemo,
    this.onUrgent,
  });

  void _handleBeginJourney(BuildContext context) {
    if (onBeginJourney != null) {
      onBeginJourney!();
    } else {
      Navigator.of(context).pushNamed(AppRoutes.auth);
    }
  }

  void _handleExploreDemo(BuildContext context) {
    if (onExploreDemo != null) {
      onExploreDemo!();
    } else {
      Navigator.of(context)
          .pushNamed(AppRoutes.home, arguments: const {'isDemo': true});
    }
  }

  void _handleUrgent(BuildContext context) {
    if (onUrgent != null) {
      onUrgent!();
    } else {
      Navigator.of(context).pushNamed(AppRoutes.urgent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Responsive typography clamps matching Figma CSS:
    // .welcome h1 { font-size: clamp(48px, 11vw, 76px); letter-spacing: -0.04em; }
    // .welcome-copy { font-size: clamp(19px, 4vw, 24px); }
    final headlineFontSize = (screenWidth * 0.11).clamp(48.0, 76.0);
    final copyFontSize = (screenWidth * 0.04).clamp(19.0, 24.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // CSS: radial-gradient(circle at 50% 30%, #fffdfa 0, var(--ivory) 58%, #efe4df 120%)
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.15,
            colors: [Color(0xFFFFFDF8), AppColors.ivory, Color(0xFFEFE4DF)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ---------------------------------------------------------------
              // Decorative Botanicals (Figma CSS: .botanical, .b1, .b2)
              // ---------------------------------------------------------------
              Positioned(
                left: -25.0,
                bottom: screenHeight * 0.10,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 120.0,
                        height: 1.0,
                        color: AppColors.rose.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: screenWidth * 0.01,
                top: screenHeight * 0.14,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: Text(
                      '☾',
                      style: TextStyle(
                        fontSize: 120.0,
                        height: 1.0,
                        color: AppColors.rose.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // Top-Right Urgent Help Action (.urgent-welcome)
              // ---------------------------------------------------------------
              Positioned(
                top: 8.0,
                right: 16.0,
                child: Semantics(
                  button: true,
                  label: AppStrings.urgentHelp,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleUrgent(context),
                      borderRadius: BorderRadius.circular(4.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 44.0,
                          minHeight: 44.0,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              AppStrings.urgentHelp,
                              style: GoogleFonts.dmSans(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.danger,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.danger,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // Main Welcome Content (.welcome-content, max-width: 470px)
              // ---------------------------------------------------------------
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 36.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Logo Mark (62x62 soft rose circle with heart icon)
                        Semantics(
                          label: 'inHERcue logo mark',
                          child: Container(
                            width: 62.0,
                            height: 62.0,
                            margin: const EdgeInsets.only(bottom: 22.0),
                            decoration: const BoxDecoration(
                              color: AppColors.roseLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: InHercueIcon(
                                icon: InHercueIconType.heart,
                                size: 29.0,
                                color: AppColors.plum,
                              ),
                            ),
                          ),
                        ),

                        // 2. Kicker: WELCOME TO
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            AppStrings.welcomeKicker,
                            style: AppTextStyles.kicker,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // 3. Headline: inHERcue
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Semantics(
                            header: true,
                            label: AppStrings.welcomeHeadline,
                            child: Text(
                              AppStrings.welcomeHeadline,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: headlineFontSize,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.04 * headlineFontSize,
                                color: AppColors.plum,
                                height: 1.15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        // 4. Welcome Editorial Copy
                        Padding(
                          padding: const EdgeInsets.only(bottom: 36.0),
                          child: Text(
                            AppStrings.welcomeSubtitle,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: copyFontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: AppColors.plumSoft,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // 5. Primary Action: Begin your journey →
                        PrimaryButton(
                          label: AppStrings.beginJourney,
                          showArrow: true,
                          onPressed: () => _handleBeginJourney(context),
                        ),

                        // 6. Text Button: Explore with demo data
                        Semantics(
                          button: true,
                          label: AppStrings.exploreDemo,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _handleExploreDemo(context),
                              borderRadius: BorderRadius.circular(8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 44.0,
                                  minWidth: 44.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    AppStrings.exploreDemo,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.plum,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 7. Safety Tagline
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            AppStrings.safetyTagline,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11.0,
                              color: AppColors.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
