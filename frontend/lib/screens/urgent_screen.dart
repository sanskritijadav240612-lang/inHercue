import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';

/// Urgent medical assistance and crisis support screen for inHERcue.
/// Directly mirrors the `Urgent({ go })` screen in the React reference:
/// - Light emergency tinted background (#fbf4f1)
/// - Topbar with back navigation
/// - Centered narrow container
/// - Circular emergency alert icon (70px, background #f1d9d6, danger red icon)
/// - "URGENT HELP" kicker
/// - "You don’t have to handle this alone." Playfair Display heading
/// - "Call emergency services" prominent danger red button
/// - "Need someone to talk to?" crisis support box (988 hotline)
/// - Explicit safety disclaimer: "inHERcue is not an emergency service and cannot provide medical care."
class UrgentScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const UrgentScreen({
    super.key,
    this.onBack,
  });

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _showCallingNotice(BuildContext context, String service, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.plum,
        content: Text(
          'Connecting to $service ($number)... Please use your device phone dialer.',
          style: GoogleFonts.dmSans(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4F1),
      body: SafeArea(
        child: Column(
          children: [
            InHercueTopbar(
              onBack: () => _handleBack(context),
              onUrgent: () {}, // Already on urgent screen
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12.0),
                        // 70px circular alert icon
                        Container(
                          width: 70.0,
                          height: 70.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1D9D6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: InHercueIcon(
                              icon: InHercueIconType.alert,
                              size: 34.0,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Kicker
                        Text(
                          'URGENT HELP',
                          style: AppTextStyles.kicker.copyWith(
                            color: AppColors.danger,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 10.0),

                        // Heading
                        Text(
                          'You don’t have to handle this alone.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14.0),

                        // Paragraph
                        Text(
                          'If you or someone else is in immediate danger, call your local emergency number now.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 28.0),

                        // Emergency Call button
                        SizedBox(
                          width: double.infinity,
                          height: 54.0,
                          child: ElevatedButton(
                            onPressed: () => _showCallingNotice(context, 'Emergency Services', '911'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const InHercueIcon(
                                  icon: InHercueIconType.alert,
                                  size: 20.0,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  'Call emergency services',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Urgent crisis box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.0),
                            border: Border.all(color: const Color(0xFFEFD8D4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need someone to talk to?',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'In the U.S. or Canada, call or text 988 for 24/7 crisis support. Elsewhere, contact your local crisis line.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.0,
                                  color: AppColors.muted,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 14.0),
                              InkWell(
                                onTap: () => _showCallingNotice(context, 'Crisis Line', '988'),
                                child: Text(
                                  'Call or text 988',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Disclaimer
                        Text(
                          'inHERcue is not an emergency service and cannot provide medical care.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.0,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
