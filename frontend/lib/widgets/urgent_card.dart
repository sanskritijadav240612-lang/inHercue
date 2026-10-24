import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'in_hercue_icon.dart';

/// The official urgent care banner card for inHercue.
/// Faithfully reproduces `.urgent-card` from the Figma reference:
/// - Background: #FBEFEC (AppColors.urgentBg)
/// - Border: 1px solid #E7C6C4 (AppColors.urgentBorder)
/// - Corner radius: 20px
/// - Padding: 22px
/// - Icon: 46x46 circular #F1D9D6 badge with Danger (#A64D54) alert icon
/// - Title: Playfair Display 20px, w600, Plum
/// - Description: DM Sans 12px, Muted
/// - Action: Danger pill button with 30px radius, white text, 46px min-height on mobile
/// - Responsive: stacks button full-width on mobile viewports (<460px)
class UrgentCard extends StatelessWidget {
  /// Card title. Defaults to the Figma copy.
  final String title;

  /// Card descriptive text. Defaults to the Figma copy.
  final String description;

  /// Action button label. Defaults to 'Get urgent help'.
  final String buttonLabel;

  /// Callback when the urgent button is tapped.
  final VoidCallback onUrgent;

  /// Outer margin around the card. Defaults to Figma `margin: 28px 0 10px`.
  final EdgeInsetsGeometry margin;

  const UrgentCard({
    super.key,
    this.title = 'Need medical help right now?',
    this.description =
        'Do not wait for your next check-in if symptoms are severe or alarming.',
    this.buttonLabel = 'Get urgent help',
    required this.onUrgent,
    this.margin = const EdgeInsets.only(top: 28.0, bottom: 10.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.urgentBg,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.urgentBorder,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(22.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive check matching CSS @media (max-width: 620px)
          final isNarrow = constraints.maxWidth < 460.0;

          final iconWidget = Container(
            width: 46.0,
            height: 46.0,
            decoration: const BoxDecoration(
              color: AppColors.urgentIconBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: InHercueIcon(
                icon: InHercueIconType.alert,
                size: 22.0,
                color: AppColors.danger,
              ),
            ),
          );

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plum,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                description,
                style: GoogleFonts.dmSans(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          );

          final buttonWidget = Semantics(
            button: true,
            label: buttonLabel,
            child: Material(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(30.0),
              child: InkWell(
                onTap: onUrgent,
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 46.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 11.0,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    buttonLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconWidget,
                    const SizedBox(width: 16.0),
                    Expanded(child: textContent),
                  ],
                ),
                const SizedBox(height: 18.0),
                SizedBox(
                  width: double.infinity,
                  child: buttonWidget,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 18.0),
              Expanded(child: textContent),
              const SizedBox(width: 18.0),
              buttonWidget,
            ],
          );
        },
      ),
    );
  }
}
