import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// Symptom tracking screen for inHERcue.
/// Directly mirrors `SymptomTracker({ go })` from the React reference:
/// - Topbar with back, urgent, and alerts navigation
/// - Toggle between Symptom History view and Add/Edit Symptom form
/// - Filter chips (All, 7 days, 30 days, Severe)
/// - Chronological history cards with severity badges (DEMO, NEW, MODERATE)
/// - Insight summary card ("2 entries this month")
/// - Medical safety disclaimer note
/// - Persistent bottom navigation (Records tab active)
class SymptomTrackerScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SymptomTrackerScreen({super.key, this.onBack});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  bool _adding = false;
  bool _saved = false;
  String _filter = 'All';

  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _severity = '';
  String _startDate = '2025-05-26';
  String _duration = '';
  String _frequency = '';
  String _notes = '';

  void _handleBack(BuildContext context) {
    if (_adding) {
      setState(() => _adding = false);
    } else if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _saveSymptom() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _saved = true;
        _adding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.plum,
          content: Text(
            'Symptom recorded in your demo history.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
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
              title: 'Symptom tracker',
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
                        // Hub header
                        Text('DEMO HEALTH RECORD', style: AppTextStyles.kicker),
                        const SizedBox(height: 8.0),
                        Text(
                          'Notice what changes.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Track symptoms over time without guessing what they mean.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        if (!_adding) ...[
                          // Action button
                          PrimaryButton(
                            label: 'Add symptom',
                            leadingIcon: const InHercueIcon(
                              icon: InHercueIconType.plus,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            onPressed: () => setState(() => _adding = true),
                          ),
                          const SizedBox(height: 18.0),

                          // Filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['All', '7 days', '30 days', 'Severe']
                                  .map((f) {
                                    final isSelected = _filter == f;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: FilterChip(
                                        label: Text(f),
                                        selected: isSelected,
                                        onSelected: (val) =>
                                            setState(() => _filter = f),
                                        backgroundColor: AppColors.paper,
                                        selectedColor: AppColors.plum,
                                        labelStyle: GoogleFonts.dmSans(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.ink,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          fontSize: 13.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.0,
                                          ),
                                          side: const BorderSide(
                                            color: AppColors.line,
                                          ),
                                        ),
                                        showCheckmark: false,
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // History List
                          if (_saved)
                            _buildHistoryCard(
                              badge: 'NEW',
                              isModerate: true,
                              title: _name.isNotEmpty ? _name : 'Headache',
                              subtitle:
                                  '$_startDate · ${_severity.isNotEmpty ? _severity : 'Moderate'} · ${_frequency.isNotEmpty ? _frequency : 'One time'}',
                              description: _notes.isNotEmpty
                                  ? _notes
                                  : 'No notes added.',
                              onEdit: () => setState(() => _adding = true),
                            ),
                          _buildHistoryCard(
                            badge: 'DEMO',
                            isModerate: false,
                            title: 'Headache',
                            subtitle: '24 May · Mild · Occasional',
                            description: 'Improved after rest and water.',
                            onEdit: () => setState(() => _adding = true),
                          ),
                          _buildHistoryCard(
                            badge: 'DEMO',
                            isModerate: true,
                            title: 'Lower back discomfort',
                            subtitle: '20 May · Moderate · Intermittent',
                            description: 'Logged during cycle day 12.',
                            onEdit: () => setState(() => _adding = true),
                          ),

                          const SizedBox(height: 18.0),

                          // Trend insight card
                          Container(
                            padding: const EdgeInsets.all(22.0),
                            decoration: BoxDecoration(
                              color: AppColors.sageLight,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DEMO TREND',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.0,
                                    letterSpacing: 1.6,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.sage,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '2 entries this month',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'There is not enough information to show a reliable pattern yet. Keep tracking and seek professional advice for concerning or persistent symptoms.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.0,
                                    color: AppColors.muted,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Form
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _saved ? 'Edit symptom' : 'Add a symptom',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),

                                  Text(
                                    'Symptom',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  TextFormField(
                                    initialValue: _name,
                                    decoration: InputDecoration(
                                      hintText: 'Describe what you noticed',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          13.0,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.line,
                                        ),
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Required'
                                        : null,
                                    onSaved: (v) => _name = v ?? '',
                                  ),
                                  const SizedBox(height: 16.0),

                                  Text(
                                    'Severity',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  DropdownButtonFormField<String>(
                                    initialValue: _severity.isNotEmpty
                                        ? _severity
                                        : null,
                                    hint: const Text('Select severity'),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          13.0,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.line,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Mild',
                                        child: Text('Mild'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Moderate',
                                        child: Text('Moderate'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Severe',
                                        child: Text('Severe'),
                                      ),
                                    ],
                                    validator: (v) =>
                                        v == null ? 'Required' : null,
                                    onChanged: (v) =>
                                        setState(() => _severity = v ?? ''),
                                    onSaved: (v) => _severity = v ?? '',
                                  ),
                                  const SizedBox(height: 16.0),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Start date',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.plum,
                                                  ),
                                            ),
                                            const SizedBox(height: 6.0),
                                            TextFormField(
                                              initialValue: _startDate,
                                              decoration: InputDecoration(
                                                hintText: 'YYYY-MM-DD',
                                                fillColor: Colors.white,
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        13.0,
                                                      ),
                                                  borderSide: const BorderSide(
                                                    color: AppColors.line,
                                                  ),
                                                ),
                                              ),
                                              onSaved: (v) =>
                                                  _startDate = v ?? '',
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
                                              'Duration',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.plum,
                                                  ),
                                            ),
                                            const SizedBox(height: 6.0),
                                            TextFormField(
                                              initialValue: _duration,
                                              decoration: InputDecoration(
                                                hintText: 'e.g. 2 hours',
                                                fillColor: Colors.white,
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        13.0,
                                                      ),
                                                  borderSide: const BorderSide(
                                                    color: AppColors.line,
                                                  ),
                                                ),
                                              ),
                                              onSaved: (v) =>
                                                  _duration = v ?? '',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),

                                  Text(
                                    'Frequency',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  DropdownButtonFormField<String>(
                                    initialValue: _frequency.isNotEmpty
                                        ? _frequency
                                        : null,
                                    hint: const Text('Select frequency'),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          13.0,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.line,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'One time',
                                        child: Text('One time'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Intermittent',
                                        child: Text('Intermittent'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Constant',
                                        child: Text('Constant'),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _frequency = v ?? ''),
                                    onSaved: (v) => _frequency = v ?? '',
                                  ),
                                  const SizedBox(height: 16.0),

                                  Text(
                                    'Notes',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  TextFormField(
                                    initialValue: _notes,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Triggers, context or what helped',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          13.0,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.line,
                                        ),
                                      ),
                                    ),
                                    onSaved: (v) => _notes = v ?? '',
                                  ),
                                  const SizedBox(height: 24.0),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: SecondaryButton(
                                          label: 'Cancel',
                                          onPressed: () =>
                                              setState(() => _adding = false),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        flex: 2,
                                        child: PrimaryButton(
                                          label: 'Review & save',
                                          onPressed: _saveSymptom,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 28.0),
                        // Medical disclaimer
                        Text(
                          'Tracking cannot diagnose a condition or rule out an emergency. Use Urgent Help if you are concerned about immediate safety.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.0,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
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

  Widget _buildHistoryCard({
    required String badge,
    required bool isModerate,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(17.0),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: isModerate ? AppColors.goldLight : AppColors.sageLight,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              badge,
              style: GoogleFonts.dmSans(
                fontSize: 9.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isModerate ? AppColors.gold : AppColors.sage,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.plum,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.0,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.0,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEdit,
            child: Text(
              'Edit',
              style: GoogleFonts.dmSans(
                color: AppColors.rose,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
