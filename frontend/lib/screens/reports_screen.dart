import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// Doctor-ready report builder screen for inHERcue.
/// Directly mirrors `Reports({ go })` from the React reference:
/// - Topbar with back, urgent, and alerts navigation
/// - Date range filter (From, To)
/// - Custom section selection checkboxes (Symptoms, Check-ins, Mood, Sleep, Period, Conditions, Medications)
/// - Preview mode with editable summary, export options and share preview mock triggers
/// - Bottom navigation (Records active)
class ReportsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ReportsScreen({super.key, this.onBack});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _preview = false;
  String _status = '';
  final TextEditingController _summaryController = TextEditingController(
    text: 'Demo summary: Two symptoms and four daily check-ins were logged in this date range. Mood was mostly steady and average reported sleep was restful.',
  );

  final List<String> _sections = [
    'Symptom history',
    'Daily check-ins',
    'Mood and stress',
    'Sleep',
    'Period logs',
    'Confirmed conditions',
    'User-entered medications',
  ];
  late final List<bool> _selectedSections;

  @override
  void initState() {
    super.initState();
    _selectedSections = List.generate(_sections.length, (i) => i < 5);
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (_preview) {
      setState(() => _preview = false);
    } else if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.records);
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
              title: 'Health report',
              onBack: () => _handleBack(context),
              onUrgent: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
              onAlerts: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
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
                        Text(
                          'USER-CONTROLLED REPORT',
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Prepare a health report',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Select exactly what you want to review or share. Demo data is clearly marked.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        if (!_preview) ...[
                          // Form
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.plum,
                                                ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          TextFormField(
                                            initialValue: '2025-05-01',
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                                borderSide: const BorderSide(
                                                  color: AppColors.line,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'To',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.plum,
                                                ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          TextFormField(
                                            initialValue: '2025-05-26',
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                                borderSide: const BorderSide(
                                                  color: AppColors.line,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),

                                Text(
                                  'Include in report',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const SizedBox(height: 10.0),

                                ...List.generate(_sections.length, (i) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedSections[i] =
                                            !_selectedSections[i];
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: _selectedSections[i],
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedSections[i] =
                                                    val ?? false;
                                              });
                                            },
                                            activeColor: AppColors.plum,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Text(
                                              _sections[i],
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14.0,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 20.0),

                                PrimaryButton(
                                  label: 'Preview report',
                                  onPressed: () =>
                                      setState(() => _preview = true),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Preview Card
                          Container(
                            padding: const EdgeInsets.all(26.0),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldLight,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: Text(
                                        'PREVIEW · DEMO DATA',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14.0),
                                Text(
                                  'inHERcue Health Overview',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '1–26 May 2025',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.0,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 18.0),

                                Text(
                                  'Editable summary',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                TextFormField(
                                  controller: _summaryController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13.0),
                                      borderSide: const BorderSide(
                                        color: AppColors.line,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18.0),

                                const Divider(color: AppColors.line),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Included sections',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Symptoms · Check-ins · Mood & stress · Sleep · Period logs',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.0,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 20.0),

                                if (_status.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.sageLight,
                                      borderRadius: BorderRadius.circular(11.0),
                                    ),
                                    child: Text(
                                      _status,
                                      style: GoogleFonts.dmSans(
                                        color: const Color(0xFF3D6645),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ],

                                Row(
                                  children: [
                                    Expanded(
                                      child: SecondaryButton(
                                        label: 'Edit report',
                                        onPressed: () =>
                                            setState(() => _preview = false),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      flex: 2,
                                      child: PrimaryButton(
                                        label: 'Export options',
                                        onPressed: () {
                                          setState(
                                            () => _status = 'Export prepared for this prototype. No file was downloaded.',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                SecondaryButton(
                                  label: 'Share preview',
                                  onPressed: () {
                                    setState(
                                      () => _status = 'Share preview opened. Nothing was sent.',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            InHercueBottomNav(
              currentDestination: InHercueNavDestination.records,
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
