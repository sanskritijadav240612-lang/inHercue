import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';

/// Alerts & notifications screen for inHERcue.
/// Directly mirrors `Alerts({ go })` from the React reference:
/// - Topbar with back and urgent navigation
/// - Header kicker: "2 NEW", heading: "Alerts & reminders"
/// - Expandable interactive accordion list for safety guidance, check-in reminder, and cycle estimate notifications
/// - Deep links to urgent help, reminders, and period tracker
/// - Bottom navigation (Profile active)
class AlertsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AlertsScreen({
    super.key,
    this.onBack,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _openIndex = 0;

  static const List<List<String>> _alerts = [
    [
      'Safety guidance',
      'Severe or sudden symptoms deserve attention',
      'If symptoms feel severe, sudden, or are accompanied by trouble breathing, fainting, heavy bleeding, or immediate danger, contact emergency services. inHERcue cannot determine whether this is an emergency.',
    ],
    [
      'Reminder',
      'Daily check-in at 8:00 PM',
      'Open your check-in when you are ready. You can change this reminder in Settings.',
    ],
    [
      'Notification',
      'Cycle estimate updated',
      'Your next-period estimate changed after your latest demo entry. Predictions are estimates only.',
    ],
  ];

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _navigateDestination(BuildContext context, InHercueNavDestination dest) {
    switch (dest) {
      case InHercueNavDestination.home:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case InHercueNavDestination.records:
        Navigator.of(context).pushReplacementNamed(AppRoutes.records);
        break;
      case InHercueNavDestination.newEntry:
        Navigator.of(context).pushNamed(AppRoutes.entry);
        break;
      case InHercueNavDestination.learn:
        Navigator.of(context).pushReplacementNamed(AppRoutes.learn);
        break;
      case InHercueNavDestination.profile:
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
              title: 'Alerts',
              onBack: () => _handleBack(context),
              onUrgent: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '2 NEW',
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Alerts & reminders',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Safety guidance, configured reminders and account notifications.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Accordion List
                        ...List.generate(_alerts.length, (i) {
                          final a = _alerts[i];
                          final isOpen = _openIndex == i;

                          InHercueIconType iconType = InHercueIconType.bell;
                          if (i == 0) iconType = InHercueIconType.alert;
                          if (i == 2) iconType = InHercueIconType.calendar;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(17.0),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _openIndex = isOpen ? -1 : i;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(17.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(17.0),
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
                                              icon: iconType,
                                              size: 20.0,
                                              color: AppColors.plum,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                a[0].toUpperCase(),
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: AppColors.rose,
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              Text(
                                                a[1],
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InHercueIcon(
                                          icon: isOpen ? InHercueIconType.chevron : InHercueIconType.chevron,
                                          size: 16.0,
                                          color: AppColors.muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isOpen)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(73.0, 0.0, 20.0, 18.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a[2],
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13.0,
                                            color: AppColors.muted,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),
                                        InkWell(
                                          onTap: () {
                                            if (i == 0) {
                                              Navigator.of(context).pushNamed(AppRoutes.urgent);
                                            } else if (i == 1) {
                                              Navigator.of(context).pushNamed(AppRoutes.reminders);
                                            } else {
                                              Navigator.of(context).pushNamed(AppRoutes.period);
                                            }
                                          },
                                          child: Text(
                                            i == 0
                                                ? 'View urgent help →'
                                                : (i == 1 ? 'Manage reminder →' : 'Review cycle →'),
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.plum,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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
              currentDestination: InHercueNavDestination.profile,
              onDestinationSelected: (dest) => _navigateDestination(context, dest),
              onNewEntry: () => Navigator.of(context).pushNamed(AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }
}
