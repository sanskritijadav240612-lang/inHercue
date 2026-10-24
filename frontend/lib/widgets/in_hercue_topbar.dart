import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'in_hercue_icon.dart';

/// The official topbar navigation widget for inHercue.
/// Directly mirrors the Topbar component from the Figma design reference:
/// - Height: 72px
/// - Left: Stylized `inHERcue` brand logo OR a back arrow button
/// - Center: Centered screen title (optional)
/// - Right: Notification bell with unread badge (optional) + "Urgent help" red action link
///
/// Implements [PreferredSizeWidget] so it can be passed directly to [Scaffold.appBar]
/// or used as a standalone header widget.
class InHercueTopbar extends StatelessWidget implements PreferredSizeWidget {
  /// Centered screen title.
  final String? title;

  /// Callback when the back button is pressed.
  /// If provided, a back arrow button is displayed on the left.
  /// If null, the stylized `inHERcue` logo is displayed on the left.
  final VoidCallback? onBack;

  /// Callback when the "Urgent help" action link is tapped.
  final VoidCallback? onUrgent;

  /// Callback when the alerts notification bell is tapped.
  /// If provided, the notification bell with badge is shown on the right.
  final VoidCallback? onAlerts;

  /// Number of unread alerts shown in the badge. Defaults to 2 matching the design reference.
  final int alertCount;

  /// Optional custom leading widget to override both logo and back arrow.
  final Widget? leading;

  /// Optional custom trailing actions to override default alerts + urgent help buttons.
  final List<Widget>? actions;

  /// Background color of the topbar. Defaults to transparent.
  final Color backgroundColor;

  /// Horizontal padding. Defaults to 18.0px matching the design reference.
  final double horizontalPadding;

  const InHercueTopbar({
    super.key,
    this.title,
    this.onBack,
    this.onUrgent,
    this.onAlerts,
    this.alertCount = 2,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.horizontalPadding = 18.0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: NavigationToolbar(
        leading: _buildLeading(context),
        middle: _buildMiddle(),
        trailing: _buildTrailing(context),
        centerMiddle: true,
      ),
    );
  }

  /// Builds the left-aligned widget (custom leading, back button, or brand logo).
  Widget _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading!;
    }

    if (onBack != null) {
      return Semantics(
        button: true,
        label: 'Go back',
        child: InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(22.0),
          child: const SizedBox(
            width: 44.0,
            height: 44.0,
            child: Center(
              child: InHercueIcon(
                icon: InHercueIconType.back,
                size: 22.0,
                color: AppColors.plum,
              ),
            ),
          ),
        ),
      );
    }

    // Default: Stylized brand logo (inHERcue)
    return Semantics(
      label: 'inHERcue',
      header: true,
      child: Text.rich(
        TextSpan(
          text: AppStrings.brandPrefix,
          style: GoogleFonts.playfairDisplay(
            fontSize: 25.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            color: AppColors.plum,
          ),
          children: [
            TextSpan(
              text: AppStrings.brandAccent,
              style: GoogleFonts.playfairDisplay(
                fontSize: 25.0,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: AppColors.rose,
              ),
            ),
            TextSpan(
              text: AppStrings.brandSuffix,
              style: GoogleFonts.playfairDisplay(
                fontSize: 25.0,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
                color: AppColors.plum,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the center-aligned screen title.
  Widget? _buildMiddle() {
    if (title == null || title!.isEmpty) {
      return null;
    }

    return Text(
      title!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }

  /// Builds the right-aligned actions (alerts bell + urgent help link).
  Widget _buildTrailing(BuildContext context) {
    if (actions != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: actions!,
      );
    }

    final children = <Widget>[];

    // Notification bell with badge (if onAlerts callback is supplied)
    if (onAlerts != null) {
      children.add(
        Semantics(
          button: true,
          label: alertCount > 0 ? '$alertCount unread alerts' : 'Alerts',
          child: InkWell(
            onTap: onAlerts,
            borderRadius: BorderRadius.circular(22.0),
            child: SizedBox(
              width: 44.0,
              height: 44.0,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const InHercueIcon(
                      icon: InHercueIconType.bell,
                      size: 22.0,
                      color: AppColors.plum,
                    ),
                    if (alertCount > 0)
                      Positioned(
                        right: -4.0,
                        top: -4.0,
                        child: Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            alertCount > 9 ? '9+' : '$alertCount',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      children.add(const SizedBox(width: 4.0));
    }

    // Urgent help link (if onUrgent callback is supplied)
    if (onUrgent != null) {
      children.add(
        Semantics(
          button: true,
          label: AppStrings.urgentHelp,
          child: TextButton(
            onPressed: onUrgent,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
              minimumSize: const Size(44.0, 44.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.urgentHelp,
              style: AppTextStyles.urgentLink,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
