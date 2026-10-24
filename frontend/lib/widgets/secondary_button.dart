import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// The official secondary button for inHercue.
/// Directly mirrors `.secondary` from the Figma reference:
/// - Outlined pill shape (border-radius: 100px)
/// - Background: transparent
/// - Border: 1px solid Plum (#432B3D)
/// - Min-height: 54px (exceeds 44x44px touch target)
/// - Typography: DM Sans 16px, w600, Plum
/// - Padding: horizontal 24px
/// - Full support for disabled state and accessible semantics
class SecondaryButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Callback when tapped. If null, the button is rendered in the disabled state.
  final VoidCallback? onPressed;

  /// Optional custom leading widget.
  final Widget? leadingIcon;

  /// Optional custom trailing widget.
  final Widget? trailingIcon;

  /// Optional custom width. Defaults to double.infinity (full-width pill).
  final double? width;

  /// Minimum height. Defaults to 54.0px matching the Figma reference.
  final double minHeight;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.width = double.infinity,
    this.minHeight = 54.0,
  });

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _isEnabled
        ? AppColors.plum
        : AppColors.plum.withValues(alpha: 0.38);

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: label,
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(
            color: effectiveColor,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100.0),
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(100.0),
            splashColor: AppColors.plum.withValues(alpha: 0.08),
            highlightColor: AppColors.plum.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon!,
                      const SizedBox(width: 10.0),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: effectiveColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 10.0),
                      trailingIcon!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
