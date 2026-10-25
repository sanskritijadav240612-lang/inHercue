import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/symptom_model.dart';
import '../data/services/symptom_api_service.dart';
import '../state/auth_state.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// The Daily Check-in screen for inHERcue.
/// Faithfully reproduces the `CheckIn({ go })` multi-step questionnaire flow:
/// - Step progression with animated progress bar
/// - Multiselect symptom screen with smart skip logic (if 'No symptoms today', skips to timing/hydration)
/// - Per-symptom severity, duration, and frequency follow-up fields
/// - Single-select scale questionnaires for timing, hydration, sleep, energy, activity, appetite, mood, menstrual
/// - Review screen with edit shortcuts and optional private note
/// - Completion screen with reflection takeaway and customizable gentle plan for tomorrow
class CheckinScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CheckinScreen({super.key, this.onBack});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _step = 0;
  bool _saved = false;
  bool _isSavingCheckin = false;
  SafetyAssessment? _safetyAssessment;
  final SymptomApiService _symptomService = SymptomApiService();
  List<String> _symptoms = [];
  String _plan = 'open'; // 'open', 'saved', 'dismissed'
  bool _planReminder = false;
  final Map<String, String> _answers = {};
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _timingDurationController =
      TextEditingController();

  static const List<Map<String, dynamic>> _stepsData = [
    {
      'id': 'symptom',
      'kicker': 'BODY CHECK',
      'title': 'Are you noticing any symptoms?',
      'options': [
        'No symptoms today',
        'Headache',
        'Cramps',
        'Bloating',
        'Fatigue',
        'Other',
      ],
    },
    {
      'id': 'details',
      'kicker': 'SYMPTOM DETAILS',
      'title': 'Tell us a little more about each symptom.',
      'options': <String>[],
    },
    {
      'id': 'timing',
      'kicker': 'TIMING',
      'title': 'When did it begin?',
      'options': ['Today', 'Yesterday', '2–7 days ago', 'More than a week ago'],
    },
    {
      'id': 'hydration',
      'kicker': 'HYDRATION',
      'title': 'How has your hydration been?',
      'options': ['Low', 'Some', 'Good', 'Very good'],
    },
    {
      'id': 'sleep',
      'kicker': 'SLEEP',
      'title': 'How did you sleep?',
      'options': ['Restless', 'Not enough', 'Okay', 'Restful'],
    },
    {
      'id': 'energy',
      'kicker': 'ENERGY',
      'title': 'How is your energy today?',
      'options': ['Very low', 'Low', 'Steady', 'High'],
    },
    {
      'id': 'activity',
      'kicker': 'ACTIVITY',
      'title': 'How active were you today?',
      'options': ['Rest day', 'Light', 'Moderate', 'High'],
    },
    {
      'id': 'appetite',
      'kicker': 'APPETITE',
      'title': 'How has your appetite been?',
      'options': ['Low', 'Less than usual', 'Usual', 'Higher than usual'],
    },
    {
      'id': 'mood',
      'kicker': 'MIND',
      'title': 'How are mood and stress?',
      'options': [
        'Heavy · high stress',
        'Low · some stress',
        'Steady · manageable',
        'Calm · low stress',
      ],
    },
    {
      'id': 'menstrual',
      'kicker': 'MENSTRUAL HEALTH',
      'title': 'Anything to note about your cycle?',
      'options': [
        'No update',
        'Period started',
        'Period ended',
        'Spotting',
        'Cramps',
      ],
    },
  ];

  @override
  void dispose() {
    _noteController.dispose();
    _timingDurationController.dispose();
    super.dispose();
  }

  bool get _isReview => _step == _stepsData.length;
  bool get _isComplete => _step == _stepsData.length + 1;

  void _toggleSymptom(String value) {
    setState(() {
      if (value == 'No symptoms today') {
        if (_symptoms.contains(value)) {
          _symptoms = [];
        } else {
          _symptoms = [value];
        }
      } else {
        _symptoms.remove('No symptoms today');
        if (_symptoms.contains(value)) {
          _symptoms.remove(value);
        } else {
          _symptoms.add(value);
        }
      }
    });
  }

  void _setAnswer(String key, String value) {
    setState(() {
      _answers[key] = value;
    });
  }

  void _nextStep() {
    setState(() {
      if (_step == 0 && _symptoms.contains('No symptoms today')) {
        _step = 3; // skip symptom details & timing
      } else {
        _step++;
      }
    });
  }

  void _prevStep(BuildContext context) {
    if (_step == 3 && _symptoms.contains('No symptoms today')) {
      setState(() {
        _step = 0;
      });
    } else if (_step > 0) {
      setState(() {
        _step--;
      });
    } else {
      if (widget.onBack != null) {
        widget.onBack!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }

  bool _canContinue() {
    if (_step == 0) {
      return _symptoms.isNotEmpty;
    }
    if (_step == 1) {
      for (final s in _symptoms) {
        if (!_answers.containsKey('$s severity') ||
            _answers['$s severity']!.isEmpty) {
          return false;
        }
      }
      return true;
    }
    if (_step < _stepsData.length) {
      final key = _stepsData[_step]['id'] as String;
      return _answers.containsKey(key) && _answers[key]!.isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = _stepsData.length + 1;
    final progressFraction = _isComplete
        ? 1.0
        : (_isReview
              ? _stepsData.length / totalSteps
              : (_step + 1) / totalSteps);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            InHercueTopbar(
              title: 'Daily check-in',
              onBack: () => _prevStep(context),
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
                    constraints: const BoxConstraints(maxWidth: 520.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress Label & Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isComplete
                                  ? 'Saved'
                                  : (_isReview
                                        ? 'Review'
                                        : 'Step ${_step + 1}'),
                              style: GoogleFonts.dmSans(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '${_isComplete ? totalSteps : _step + 1} of $totalSteps',
                              style: GoogleFonts.dmSans(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Container(
                            height: 4.0,
                            color: AppColors.line,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                    width:
                                        constraints.maxWidth *
                                        progressFraction.clamp(0.0, 1.0),
                                    height: 4.0,
                                    color: AppColors.rose,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28.0),

                        if (!_isReview && !_isComplete)
                          _buildStepContent(context)
                        else if (_isReview)
                          _buildReviewContent(context)
                        else
                          _buildCompleteContent(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final stepInfo = _stepsData[_step];
    final kicker = stepInfo['kicker'] as String;
    final title = stepInfo['title'] as String;
    final options = stepInfo['options'] as List<String>;
    final stepId = stepInfo['id'] as String;

    InHercueIconType iconType = InHercueIconType.sparkle;
    if (_step < 3) {
      iconType = InHercueIconType.heart;
    } else if (_step == 4 || _step == 8) {
      iconType = InHercueIconType.moon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Icon
        Center(
          child: Container(
            width: 62.0,
            height: 62.0,
            decoration: const BoxDecoration(
              color: AppColors.roseLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: InHercueIcon(
                icon: iconType,
                size: 28.0,
                color: AppColors.plum,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18.0),

        // Kicker
        Text(kicker, textAlign: TextAlign.center, style: AppTextStyles.kicker),
        const SizedBox(height: 8.0),

        // Question Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
            color: AppColors.plum,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8.0),

        Text(
          _step == 1
              ? 'This follow-up appears because you selected a symptom.'
              : 'Choose what feels closest. You can change it before saving.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 13.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),

        // Step 0: Symptom Multiselect
        if (_step == 0)
          Column(
            children: options.map((opt) {
              final isSelected = _symptoms.contains(opt);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  onTap: () => _toggleSymptom(opt),
                  borderRadius: BorderRadius.circular(14.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.roseLight : AppColors.paper,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: isSelected ? AppColors.rose : AppColors.line,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: 26.0,
                          height: 26.0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.plum
                                : AppColors.ivory,
                            shape: BoxShape.circle,
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
                                : Text(
                                    '${options.indexOf(opt) + 1}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.0,
                                      color: AppColors.muted,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Text(
                            opt,
                            style: GoogleFonts.dmSans(
                              fontSize: 15.0,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        // Step 1: Follow-up details for each selected symptom
        else if (_step == 1)
          Column(
            children: _symptoms.map((symptom) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symptom,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Severity',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    DropdownButtonFormField<String>(
                      initialValue: _answers['$symptom severity'],
                      hint: const Text('Select severity'),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Mild', child: Text('Mild')),
                        DropdownMenuItem(
                          value: 'Moderate',
                          child: Text('Moderate'),
                        ),
                        DropdownMenuItem(
                          value: 'Severe',
                          child: Text('Severe'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) _setAnswer('$symptom severity', val);
                      },
                    ),
                    const SizedBox(height: 14.0),
                    Text(
                      'Duration',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    TextFormField(
                      initialValue: _answers['$symptom duration'],
                      decoration: InputDecoration(
                        hintText: 'e.g. 2 hours',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                      ),
                      onChanged: (val) => _setAnswer('$symptom duration', val),
                    ),
                    const SizedBox(height: 14.0),
                    Text(
                      'Frequency',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    DropdownButtonFormField<String>(
                      initialValue: _answers['$symptom frequency'],
                      hint: const Text('Select frequency'),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Once', child: Text('Once')),
                        DropdownMenuItem(
                          value: 'Intermittent',
                          child: Text('Intermittent'),
                        ),
                        DropdownMenuItem(
                          value: 'Constant',
                          child: Text('Constant'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) _setAnswer('$symptom frequency', val);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        // Other Steps: Single-Select Scales
        else
          Column(
            children: [
              ...options.map((opt) {
                final isSelected = _answers[stepId] == opt;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => _setAnswer(stepId, opt),
                    borderRadius: BorderRadius.circular(14.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.roseLight
                            : AppColors.paper,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: isSelected ? AppColors.rose : AppColors.line,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            width: 28.0,
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.plum
                                  : AppColors.ivory,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${options.indexOf(opt) + 1}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Text(
                              opt,
                              style: GoogleFonts.dmSans(
                                fontSize: 15.0,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_step == 2) ...[
                const SizedBox(height: 12.0),
                Text(
                  'Duration (Optional)',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.plum,
                  ),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _timingDurationController,
                  decoration: InputDecoration(
                    hintText: 'e.g. a few hours',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                  onChanged: (val) => _setAnswer('duration', val),
                ),
              ],
            ],
          ),

        const SizedBox(height: 28.0),
        PrimaryButton(
          label: 'Continue',
          trailingIcon: const Text(
            '→',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
          onPressed: _canContinue() ? _nextStep : null,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildReviewContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'REVIEW BEFORE SAVING',
          textAlign: TextAlign.center,
          style: AppTextStyles.kicker,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Your daily check-in',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
            color: AppColors.plum,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Nothing is saved until you confirm below.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),

        // Answers list
        Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: AppColors.line),
          ),
          child: ListTile(
            title: Text(
              'symptoms',
              style: GoogleFonts.dmSans(fontSize: 11.0, color: AppColors.muted),
            ),
            subtitle: Text(
              _symptoms.isNotEmpty ? _symptoms.join(', ') : 'None',
              style: GoogleFonts.dmSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: AppColors.plum,
              ),
            ),
            trailing: Text(
              'Edit',
              style: GoogleFonts.dmSans(
                color: AppColors.rose,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => setState(() => _step = 0),
          ),
        ),

        ..._answers.entries.map((entry) {
          final stepIndex = _stepsData.indexWhere((s) => s['id'] == entry.key);
          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: AppColors.line),
            ),
            child: ListTile(
              title: Text(
                entry.key,
                style: GoogleFonts.dmSans(
                  fontSize: 11.0,
                  color: AppColors.muted,
                ),
              ),
              subtitle: Text(
                entry.value,
                style: GoogleFonts.dmSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plum,
                ),
              ),
              trailing: Text(
                'Edit',
                style: GoogleFonts.dmSans(
                  color: AppColors.rose,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                if (stepIndex >= 0) {
                  setState(() => _step = stepIndex);
                }
              },
            ),
          );
        }),

        const SizedBox(height: 16.0),
        Text(
          'Private note (Optional)',
          style: GoogleFonts.dmSans(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: AppColors.plum,
          ),
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add anything you want to remember…',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.0),
              borderSide: const BorderSide(color: AppColors.line),
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        SecondaryButton(label: 'Back', onPressed: () => _prevStep(context)),
        const SizedBox(height: 10.0),
        PrimaryButton(
          label: _isSavingCheckin
              ? 'Saving check-in...'
              : 'Confirm & save check-in',
          trailingIcon: _isSavingCheckin
              ? null
              : const Text(
                  '✓',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
          onPressed: _isSavingCheckin ? null : _handleSaveCheckin,
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Future<void> _handleSaveCheckin() async {
    final authState = AuthStateScope.maybeOf(context);
    final token = authState?.token;

    if (token != null && token.isNotEmpty) {
      setState(() {
        _isSavingCheckin = true;
      });

      try {
        final mappedSymptoms = <Map<String, dynamic>>[];
        int calculatedPain = 0;

        for (final s in _symptoms) {
          if (s == 'No symptoms today') continue;
          final sev =
              (_answers['$s severity'] ?? _answers['${s}_severity'] ?? 'mild')
                  .toLowerCase();

          // Only calculate pain scale for pain/cramp related complaints
          final isPainRelated =
              s.toLowerCase().contains('cramp') ||
              s.toLowerCase().contains('pain') ||
              s.toLowerCase().contains('headache');

          if (isPainRelated) {
            final painVal = sev == 'severe' ? 8 : (sev == 'moderate' ? 5 : 2);
            if (painVal > calculatedPain) {
              calculatedPain = painVal;
            }
          }

          final dur = _answers['$s duration'] ?? _answers['timing'];
          final freq = _answers['$s frequency'];

          mappedSymptoms.add({
            'type': s,
            'severity': sev,
            if (dur != null && dur.isNotEmpty) 'duration': dur,
            if (freq != null && freq.isNotEmpty) 'frequency': freq,
          });
        }

        final todayStr = DateTime.now().toIso8601String().split('T').first;
        final logResult = await _symptomService.saveCheckin(
          token: token,
          date: todayStr,
          flow: _answers['menstrual']?.toLowerCase() ?? 'none',
          painScale: calculatedPain,
          symptoms: mappedSymptoms,
          hydration: _answers['hydration'],
          sleep: _answers['sleep'],
          energy: _answers['energy'],
          activity: _answers['activity'],
          appetite: _answers['appetite'],
          mood: _answers['mood'],
          notes: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

        if (!mounted) return;
        setState(() {
          _saved = true;
          _safetyAssessment = logResult.safetyAssessment;
          _step = _stepsData.length + 1;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text(
              'Could not save check-in to server: ${e.toString()}',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSavingCheckin = false;
          });
        }
      }
    } else {
      // Demo mode fallback
      setState(() {
        _saved = true;
        _step = _stepsData.length + 1;
      });
    }
  }

  Widget _buildCompleteContent(BuildContext context) {
    final hasStress =
        _answers['mood']?.toLowerCase().contains('stress') ?? false;
    final authState = AuthStateScope.maybeOf(context);
    final isAuthenticated = authState?.isAuthenticated ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 78.0,
            height: 78.0,
            decoration: const BoxDecoration(
              color: AppColors.roseLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: InHercueIcon(
                icon: InHercueIconType.heart,
                size: 35.0,
                color: AppColors.plum,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18.0),
        Text(
          _saved ? 'CHECK-IN SAVED' : 'CHECK-IN COMPLETE',
          textAlign: TextAlign.center,
          style: AppTextStyles.kicker,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Thank you for checking in.',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
            color: AppColors.plum,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          isAuthenticated
              ? 'Your check-in has been securely saved to your health history.'
              : 'Your entry is saved in your demo health history. You can edit it from Records.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 14.0,
            color: AppColors.muted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24.0),

        if (_safetyAssessment != null && _safetyAssessment!.isEmergency) ...[
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4F1),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.danger, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const InHercueIcon(
                      icon: InHercueIconType.alert,
                      color: AppColors.danger,
                      size: 22.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'CLINICAL SAFETY ALERT',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.0,
                          letterSpacing: 1.2,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  _safetyAssessment!.advice,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.0,
                    color: AppColors.ink,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'This assessment does not diagnose medical conditions and must not delay urgent medical care.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14.0),
                PrimaryButton(
                  label: 'Get Urgent Medical Care',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.urgent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),
        ],

        // Reflection Card
        Container(
          padding: const EdgeInsets.all(22.0),
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR RESULT',
                style: GoogleFonts.dmSans(
                  fontSize: 10.0,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sage,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                hasStress
                    ? 'Your check-in shows a mix of physical and emotional signals. Consider a small restorative pause and keep tracking what changes.'
                    : 'Your check-in creates a useful baseline for noticing patterns over time.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16.0,
                  color: AppColors.ink,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // Gentle plan card
        if (_plan == 'open')
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR GENTLE PLAN FOR TOMORROW',
                  style: GoogleFonts.dmSans(
                    fontSize: 10.0,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF55705A),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Make space for one restorative pause.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.plum,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'A short, comfortable break may support your wellbeing. Adjust or skip this suggestion based on what feels right for you.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13.0,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Checkbox(
                      value: _planReminder,
                      activeColor: AppColors.plum,
                      onChanged: (val) {
                        setState(() {
                          _planReminder = val ?? false;
                        });
                      },
                    ),
                    Text(
                      'Add a local demo reminder',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.0,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _plan = 'dismissed'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.plum),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: Text(
                          'Dismiss',
                          style: GoogleFonts.dmSans(
                            color: AppColors.plum,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _plan = 'saved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.plum,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: Text(
                          'Save plan',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(13.0),
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              borderRadius: BorderRadius.circular(11.0),
            ),
            child: Text(
              _plan == 'saved' ? 'Plan saved in this demo.' : 'Plan dismissed.',
              style: GoogleFonts.dmSans(
                color: const Color(0xFF3D6645),
                fontWeight: FontWeight.w600,
                fontSize: 13.0,
              ),
            ),
          ),

        const SizedBox(height: 24.0),
        SecondaryButton(
          label: 'Review answers',
          onPressed: () => setState(() => _step = _stepsData.length),
        ),
        const SizedBox(height: 10.0),
        PrimaryButton(
          label: 'View in health history',
          trailingIcon: const Text(
            '→',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.records),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
