import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

/// The official primary button for inHercue.
/// Directly mirrors `.primary` from the Figma reference:
/// - Pill shape (border-radius: 100px)
/// - Background: Plum (#432B3D) with hover/press (#56364E)
/// - Min-height: 54px (exceeds 44x44px touch target)
/// - Box shadow: `0 10px 30px rgba(67, 43, 61, 0.16)`
/// - Typography: DM Sans 16px, w600, White
/// - Optional right arrow (`→`) matching reference screens
/// - Full support for loading, disabled, and custom trailing icons
class PrimaryButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Callback when tapped. If null, the button is rendered in the disabled state.
  final VoidCallback? onPressed;

  /// Whether to display a loading spinner instead of the label.
  final bool isLoading;

  /// Whether to display the signature right arrow (`→`) after the label.
  final bool showArrow;

  /// Optional custom leading widget.
  final Widget? leadingIcon;

  /// Optional custom trailing widget (overrides [showArrow] if provided).
  final Widget? trailingIcon;

  /// Optional custom width. Defaults to double.infinity (full-width pill).
  final double? width;

  /// Minimum height. Defaults to 54.0px matching the Figma reference.
  final double minHeight;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.showArrow = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width = double.infinity,
    this.minHeight = 54.0,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _isEnabled
        ? AppColors.plum
        : AppColors.plum.withValues(alpha: 0.38);

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? const SizedBox(
              width: 22.0,
              height: 22.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
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
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 12.0),
                  trailingIcon!,
                ] else if (showArrow) ...[
                  const SizedBox(width: 12.0),
                  Text(
                    '→',
                    style: GoogleFonts.dmSans(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: label,
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.plum.withValues(alpha: 0.16),
                    blurRadius: 30.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(100.0),
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(100.0),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: AppColors.plumHover,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 14.0,
              ),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
