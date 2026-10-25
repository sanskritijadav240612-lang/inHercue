import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/mini_chart_widget.dart';

enum HubType { records, learn, profile }

/// Navigation Hub screen for inHERcue (Records, Learn, and Profile).
/// Directly mirrors the `Hub({ screen, go })` component from the React reference:
/// - Topbar with title and urgent action
/// - Kicker, large Playfair Display heading, and calming subtitle
/// - Wave trend chart for Health History (`MiniChartWidget`)
/// - Styled vertical option list with circular icon badges, headings, subtitles, and chevrons
/// - Synced bottom navigation reflecting active hub destination
class HubScreen extends StatelessWidget {
  final HubType type;
  final VoidCallback? onBack;

  const HubScreen({super.key, required this.type, this.onBack});

  String get _title {
    switch (type) {
      case HubType.records:
        return 'Health history';
      case HubType.learn:
        return 'Learn & grow';
      case HubType.profile:
        return 'Your profile';
    }
  }

  String get _kicker {
    switch (type) {
      case HubType.records:
        return 'DEMO DATA · PRIVATE TO YOU';
      case HubType.learn:
      case HubType.profile:
        return 'inHERcue';
    }
  }

  String get _subtitle {
    switch (type) {
      case HubType.records:
        return 'Your wellbeing over time, in one calm view.';
      case HubType.learn:
      case HubType.profile:
        return 'Choose where you’d like to go next.';
    }
  }

  InHercueNavDestination get _navDestination {
    switch (type) {
      case HubType.records:
        return InHercueNavDestination.records;
      case HubType.learn:
        return InHercueNavDestination.learn;
      case HubType.profile:
        return InHercueNavDestination.profile;
    }
  }

  List<Map<String, dynamic>> _getItems() {
    switch (type) {
      case HubType.records:
        return [
          {
            'route': AppRoutes.patterns,
            'title': 'Health patterns',
            'subtitle': 'Trends & charts',
            'icon': InHercueIconType.chart,
          },
          {
            'route': AppRoutes.summary,
            'title': 'Doctor-ready summary',
            'subtitle': 'Prepare for appointments',
            'icon': InHercueIconType.records,
          },
          {
            'route': AppRoutes.passport,
            'title': 'Health passport',
            'subtitle': 'Your portable overview',
            'icon': InHercueIconType.shield,
          },
        ];
      case HubType.learn:
        return [
          {
            'route': AppRoutes.guidance,
            'title': 'Wellness guidance',
            'subtitle': 'Clinician-reviewed education',
            'icon': InHercueIconType.learn,
          },
          {
            'route': AppRoutes.myths,
            'title': 'Myth vs Fact',
            'subtitle': 'Clear up common misconceptions',
            'icon': InHercueIconType.sparkle,
          },
          {
            'route': AppRoutes.selfcare,
            'title': 'Self-Care Studio',
            'subtitle': 'Restorative practices',
            'icon': InHercueIconType.heart,
          },
        ];
      case HubType.profile:
        return [
          {
            'route': AppRoutes.profileSetup,
            'title': 'Health profile',
            'subtitle': 'Review and edit answers',
            'icon': InHercueIconType.user,
          },
          {
            'route': AppRoutes.reminders,
            'title': 'Reminders',
            'subtitle': 'Choose your gentle prompts',
            'icon': InHercueIconType.bell,
          },
          {
            'route': AppRoutes.settings,
            'title': 'Settings & privacy',
            'subtitle': 'Control your information',
            'icon': InHercueIconType.shield,
          },
          {
            'route': AppRoutes.doctors,
            'title': 'Find a doctor',
            'subtitle': 'Care that listens',
            'icon': InHercueIconType.search,
          },
        ];
    }
  }

  void _navigateDestination(BuildContext context, InHercueNavDestination dest) {
    switch (dest) {
      case InHercueNavDestination.home:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case InHercueNavDestination.records:
        if (type != HubType.records) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.records);
        }
        break;
      case InHercueNavDestination.newEntry:
        Navigator.of(context).pushNamed(AppRoutes.entry);
        break;
      case InHercueNavDestination.learn:
        if (type != HubType.learn) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.learn);
        }
        break;
      case InHercueNavDestination.profile:
        if (type != HubType.profile) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
              title: _title,
              onUrgent: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_kicker, style: AppTextStyles.kicker),
                        const SizedBox(height: 8.0),
                        Text(
                          _title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // If records: Mini Chart
                        if (type == HubType.records) ...[
                          const MiniChartWidget(
                            title: 'Energy',
                            subtitle: 'Last 7 days',
                          ),
                          const SizedBox(height: 20.0),
                        ],

                        // Hub items list
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context)
                                      .pushNamed(item['route'] as String),
                              borderRadius: BorderRadius.circular(16.0),
                              child: Container(
                                padding: const EdgeInsets.all(17.0),
                                decoration: BoxDecoration(
                                  color: AppColors.paper,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42.0,
                                      height: 42.0,
                                      decoration: const BoxDecoration(
                                        color: AppColors.roseLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: InHercueIcon(
                                          icon:
                                              item['icon'] as InHercueIconType,
                                          size: 20.0,
                                          color: AppColors.plum,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] as String,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.plum,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            item['subtitle'] as String,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12.0,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const InHercueIcon(
                                      icon: InHercueIconType.chevron,
                                      size: 16.0,
                                      color: AppColors.muted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            InHercueBottomNav(
              currentDestination: _navDestination,
              onDestinationSelected: (dest) =>
                  _navigateDestination(context, dest),
              onNewEntry: () =>
                  Navigator.of(context).pushNamed(AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }
}
