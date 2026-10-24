import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import 'in_hercue_icon.dart';

/// Available destinations for the inHercue bottom navigation bar.
enum InHercueNavDestination {
  home,
  records,
  newEntry,
  learn,
  profile,
}

/// The official bottom navigation bar for inHercue.
/// Faithfully reproduces the BottomNav component from the Figma reference:
/// - Fixed height: 78px (+ safe area inset)
/// - Frosted translucent paper background (alpha 0.96 with 15px backdrop blur)
/// - Top border: 1px solid AppColors.line (#E6DDD8)
/// - 5 destinations: Home, Records, elevated central New Entry (+), Learn, Profile
/// - Central New Entry button is elevated (-18px margin) in Plum (#432B3D) with a 4px Paper border
/// - Active color: Plum (#432B3D)
/// - Inactive color: #8C8086
class InHercueBottomNav extends StatelessWidget {
  /// The currently active navigation destination.
  final InHercueNavDestination currentDestination;

  /// Callback when any navigation destination is selected.
  final ValueChanged<InHercueNavDestination>? onDestinationSelected;

  /// Optional dedicated callback when the elevated central "New entry" button is tapped.
  /// If provided, this is invoked instead of [onDestinationSelected] for [InHercueNavDestination.newEntry].
  final VoidCallback? onNewEntry;

  /// Inactive item color matching CSS `#8c8086`.
  static const Color inactiveColor = Color(0xFF8C8086);

  /// Height of the navigation bar body (excluding safe-area inset).
  static const double barHeight = 78.0;

  const InHercueBottomNav({
    super.key,
    required this.currentDestination,
    this.onDestinationSelected,
    this.onNewEntry,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPadding = math.max(7.0, bottomInset);
    final totalHeight = barHeight + (bottomInset > 7.0 ? bottomInset - 7.0 : 0.0);

    return SizedBox(
      height: totalHeight + 18.0, // extra 18px allows central button to pop up above the bar
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Frosted glass background bar
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: totalHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.paper.withValues(alpha: 0.96),
                    border: const Border(
                      top: BorderSide(color: AppColors.line, width: 1.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Navigation items row
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: totalHeight + 18.0,
            child: Padding(
              padding: EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: bottomPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTab(
                        context: context,
                        destination: InHercueNavDestination.home,
                        icon: InHercueIconType.home,
                        label: AppStrings.navHome,
                        index: 1,
                      ),
                      _buildTab(
                        context: context,
                        destination: InHercueNavDestination.records,
                        icon: InHercueIconType.records,
                        label: AppStrings.navRecords,
                        index: 2,
                      ),
                      _buildCenterTab(context: context),
                      _buildTab(
                        context: context,
                        destination: InHercueNavDestination.learn,
                        icon: InHercueIconType.learn,
                        label: AppStrings.navLearn,
                        index: 4,
                      ),
                      _buildTab(
                        context: context,
                        destination: InHercueNavDestination.profile,
                        icon: InHercueIconType.user,
                        label: AppStrings.navProfile,
                        index: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a standard navigation tab (Home, Records, Learn, Profile).
  Widget _buildTab({
    required BuildContext context,
    required InHercueNavDestination destination,
    required InHercueIconType icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentDestination == destination;
    final itemColor = isSelected ? AppColors.plum : inactiveColor;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label, Tab $index of 5',
        child: InkWell(
          onTap: () => onDestinationSelected?.call(destination),
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
            padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 31.0,
                  child: Center(
                    child: InHercueIcon(
                      icon: icon,
                      size: 21.0,
                      color: itemColor,
                    ),
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: itemColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the elevated central "New entry" tab.
  Widget _buildCenterTab({required BuildContext context}) {
    final isSelected = currentDestination == InHercueNavDestination.newEntry;
    final labelColor = isSelected ? AppColors.plum : inactiveColor;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${AppStrings.navNewEntry}, Tab 3 of 5',
        child: InkWell(
          onTap: () {
            if (onNewEntry != null) {
              onNewEntry!();
            } else {
              onDestinationSelected?.call(InHercueNavDestination.newEntry);
            }
          },
          borderRadius: BorderRadius.circular(25.0),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Elevated circular button: 42x42 Plum with 4px Paper border protruding ~18px above the bar
                SizedBox(
                  height: 31.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -18.0,
                        child: Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            color: AppColors.plum,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.paper,
                              width: 4.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.plum.withValues(alpha: 0.18),
                                blurRadius: 8.0,
                                offset: const Offset(0.0, 3.0),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: InHercueIcon(
                              icon: InHercueIconType.plus,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  AppStrings.navNewEntry,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: labelColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
