import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// Entry selector and health note logger for inHERcue.
/// Directly mirrors `NewEntry({ go })` from the React reference:
/// - Quick entry options: Daily Check-in, Log Symptom, Log Period, Health Note
/// - Routes directly to Daily Check-in, Symptom Tracker, or Period Tracker
/// - In-place form for private Health Notes (title, note text, date)
/// - Success confirmation screen when Health Note is saved
/// - Bottom navigation (New entry active)
class NewEntryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const NewEntryScreen({super.key, this.onBack});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  String _selectedType = '';
  String _saved = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: '2025-05-26',
  );

  static const List<String> _entryTypes = [
    'Daily Check-in',
    'Log Symptom',
    'Log Period',
    'Health Note',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _handleContinue(BuildContext context) {
    if (_selectedType == 'Daily Check-in') {
      Navigator.of(context).pushNamed(AppRoutes.checkin);
    } else if (_selectedType == 'Log Symptom') {
      Navigator.of(context).pushNamed(AppRoutes.symptoms);
    } else if (_selectedType == 'Log Period') {
      Navigator.of(context).pushNamed(AppRoutes.period);
    } else if (_selectedType == 'Health Note') {
      if (_noteController.text.trim().isNotEmpty) {
        setState(() => _saved = 'Health note');
      }
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
              title: 'New entry',
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
                    constraints: const BoxConstraints(maxWidth: 600.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ADD TO YOUR HISTORY',
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'What would you like to log?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Your entry is only saved after confirmation.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        if (_saved.isEmpty) ...[
                          // Choice List
                          Column(
                            children: _entryTypes.map((type) {
                              final isSelected = _selectedType == type;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selectedType = type),
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                      vertical: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.roseLight
                                          : AppColors.paper,
                                      borderRadius: BorderRadius.circular(15.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.rose
                                            : AppColors.line,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          type,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15.0,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        Container(
                                          width: 24.0,
                                          height: 24.0,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.plum
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.plum
                                                  : AppColors.line,
                                            ),
                                          ),
                                          child: Center(
                                            child: isSelected
                                                ? const Text(
                                                    '✓',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          if (_selectedType == 'Health Note') ...[
                            const SizedBox(height: 16.0),
                            Text(
                              'Title',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.plum,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: 'What is this note about?',
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
                            const SizedBox(height: 14.0),

                            Text(
                              'Note',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.plum,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _noteController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Write your private health note…',
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
                            const SizedBox(height: 14.0),

                            Text(
                              'Date',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.plum,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                hintText: 'YYYY-MM-DD',
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
                          ],

                          const SizedBox(height: 24.0),
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Cancel',
                                  onPressed: () => _handleBack(context),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                flex: 2,
                                child: PrimaryButton(
                                  label: _selectedType == 'Health Note'
                                      ? 'Save note'
                                      : 'Continue',
                                  onPressed: _selectedType.isNotEmpty
                                      ? () => _handleContinue(context)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Completion View
                          Center(
                            child: Container(
                              width: 78.0,
                              height: 78.0,
                              decoration: const BoxDecoration(
                                color: AppColors.roseLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 32.0,
                                    color: AppColors.plum,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          Text(
                            'ENTRY SAVED',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.kicker,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '$_saved added',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.plum,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Your entry is now visible in your demo health history.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14.0,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 28.0),

                          SecondaryButton(
                            label: 'Add another',
                            onPressed: () {
                              setState(() {
                                _saved = '';
                                _selectedType = '';
                                _noteController.clear();
                                _titleController.clear();
                              });
                            },
                          ),
                          const SizedBox(height: 12.0),
                          PrimaryButton(
                            label: 'View saved entry',
                            onPressed: () =>
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.records),
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
              currentDestination: InHercueNavDestination.newEntry,
              onDestinationSelected: (dest) =>
                  _navigateDestination(context, dest),
            ),
          ],
        ),
      ),
    );
  }
}
