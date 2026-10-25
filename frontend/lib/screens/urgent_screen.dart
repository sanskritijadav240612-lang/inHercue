import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/config/emergency_config.dart';
import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/safety_triage_model.dart';
import '../data/services/safety_api_service.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';

/// Urgent medical assistance and crisis support screen for inHERcue.
/// Directly mirrors the `Urgent({ go })` screen in the React reference:
/// - Light emergency tinted background (#fbf4f1)
/// - Topbar with back navigation
/// - Centered narrow container
/// - Circular emergency alert icon (70px, background #f1d9d6, danger red icon)
/// - "URGENT HELP" kicker
/// - "You don’t have to handle this alone." Playfair Display heading
/// - "Call emergency services" prominent danger red button
/// - "Need someone to talk to?" crisis support box (988 hotline)
/// - Connected Deterministic Clinical Safety Triage assessment backed by POST /api/v1/safety/triage
/// - Explicit safety disclaimer: "inHERcue is not an emergency service and cannot provide medical care."
class UrgentScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? initialRegionCode;

  const UrgentScreen({super.key, this.onBack, this.initialRegionCode});

  @override
  State<UrgentScreen> createState() => _UrgentScreenState();
}

class _UrgentScreenState extends State<UrgentScreen> {
  final SafetyApiService _safetyService = SafetyApiService();
  late EmergencyRegion _selectedRegion;

  // Triage state
  bool _soakingPads = false;
  bool _severePelvicPain = false;
  bool _dizzinessOrFainting = false;
  bool _highFever = false;
  bool _pelvicTenderness = false;

  bool _isEvaluating = false;
  SafetyTriageResult? _triageResult;
  String? _triageError;

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialRegionCode != null
        ? EmergencyConfig.getByCode(widget.initialRegionCode!)
        : EmergencyConfig.defaultRegion;
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _showCallingNotice(BuildContext context, String service, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.plum,
        content: Text(
          'Connecting to $service ($number)... Please use your device phone dialer.',
          style: GoogleFonts.dmSans(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _evaluateTriage() async {
    setState(() {
      _isEvaluating = true;
      _triageError = null;
    });

    try {
      final acuteSymptoms = <String>[];
      if (_soakingPads) acuteSymptoms.add('soaking_two_pads_an_hour');
      if (_severePelvicPain) acuteSymptoms.add('acute_pelvic_pain');
      if (_dizzinessOrFainting) acuteSymptoms.add('fainting_dizziness');
      if (_highFever) acuteSymptoms.add('high_fever');
      if (_pelvicTenderness) acuteSymptoms.add('pelvic_tenderness');

      // Adhere strictly to the backend contract:
      // Only supply fields that were affirmatively reported; do not assume dummy or normal values.
      final result = await _safetyService.evaluateTriage(
        acuteSymptoms: acuteSymptoms.isNotEmpty ? acuteSymptoms : null,
        painScale: _severePelvicPain ? 9 : null,
        bleedingRate: _soakingPads ? 'soaking_two_pads_an_hour' : null,
        feverTemperatureC: _highFever ? 39.0 : null,
        hasFainting: _dizzinessOrFainting ? true : null,
        hasSevereDizziness: _dizzinessOrFainting ? true : null,
        hasPelvicTenderness: _pelvicTenderness ? true : null,
      );

      if (!mounted) return;
      setState(() {
        _triageResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _triageError =
            'Could not evaluate symptoms. If experiencing an emergency, call ${_selectedRegion.emergencyNumber} immediately.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isEvaluating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4F1),
      body: SafeArea(
        child: Column(
          children: [
            InHercueTopbar(
              onBack: _handleBack,
              onUrgent: () {}, // Already on urgent screen
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12.0),
                        // 70px circular alert icon
                        Container(
                          width: 70.0,
                          height: 70.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1D9D6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: InHercueIcon(
                              icon: InHercueIconType.alert,
                              size: 34.0,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Kicker
                        Text(
                          'URGENT HELP',
                          style: AppTextStyles.kicker.copyWith(
                            color: AppColors.danger,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 10.0),

                        // Heading
                        Text(
                          'You don’t have to handle this alone.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14.0),

                        // Paragraph
                        Text(
                          'If you or someone else is in immediate danger, call your local emergency number now.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 18.0),

                        // Prominent Clinical Notice
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: const Color(0xFFF0A8A8)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.danger,
                                size: 20.0,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  'MEDICAL NOTICE: inHERcue / HerSignal is a self-monitoring tool and does NOT diagnose medical conditions or substitute for clinical medical evaluation. It must not delay urgent medical care. If you are experiencing sudden, severe, or worsening symptoms, contact emergency services immediately.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7A1C1C),
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18.0),

                        // Configurable Emergency Country/Region Selector
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18.0,
                                color: AppColors.plum,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Region:',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.plum,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedRegion.code,
                                    isDense: true,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18.0,
                                    ),
                                    items: EmergencyConfig.supportedRegions.map((
                                      region,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: region.code,
                                        child: Text(
                                          '${region.flag} ${region.displayName}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.ink,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (code) {
                                      if (code != null) {
                                        setState(() {
                                          _selectedRegion =
                                              EmergencyConfig.getByCode(code);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Emergency Call button
                        SizedBox(
                          width: double.infinity,
                          height: 54.0,
                          child: ElevatedButton(
                            onPressed: () => _showCallingNotice(
                              context,
                              _selectedRegion.emergencyLabel,
                              _selectedRegion.emergencyNumber,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const InHercueIcon(
                                  icon: InHercueIconType.alert,
                                  size: 20.0,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  'Call emergency services',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    _selectedRegion.emergencyNumber,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Interactive Clinical Safety Triage Tool
                        _buildSafetyTriageSection(context),

                        const SizedBox(height: 24.0),

                        // Urgent crisis box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.0),
                            border: Border.all(color: const Color(0xFFEFD8D4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need someone to talk to?',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                _selectedRegion.crisisDescription,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.0,
                                  color: AppColors.muted,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 14.0),
                              InkWell(
                                onTap: () => _showCallingNotice(
                                  context,
                                  _selectedRegion.crisisLabel,
                                  _selectedRegion.crisisNumber.isNotEmpty
                                      ? _selectedRegion.crisisNumber
                                      : _selectedRegion.emergencyNumber,
                                ),
                                child: Text(
                                  _selectedRegion.crisisActionText,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Disclaimer
                        Text(
                          'inHERcue is not an emergency service and cannot provide medical care.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.0,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'This tool does not diagnose medical conditions and must not delay urgent medical care.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24.0),
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

  Widget _buildSafetyTriageSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const InHercueIcon(
                icon: InHercueIconType.shield,
                size: 20.0,
                color: AppColors.plum,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'CLINICAL SAFETY TRIAGE CHECK',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: AppColors.plum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            'Check for red-flag warning signs requiring urgent medical evaluation:',
            style: GoogleFonts.dmSans(fontSize: 13.0, color: AppColors.muted),
          ),
          const SizedBox(height: 14.0),

          // Symptom Checkboxes
          _buildSymptomCheckbox(
            label: 'Soaking 2+ maxi pads/hr for consecutive hours',
            value: _soakingPads,
            onChanged: (v) => setState(() => _soakingPads = v ?? false),
          ),
          _buildSymptomCheckbox(
            label: 'Sudden, severe pelvic or abdominal pain (≥ 8/10)',
            value: _severePelvicPain,
            onChanged: (v) => setState(() => _severePelvicPain = v ?? false),
          ),
          _buildSymptomCheckbox(
            label: 'Dizziness, lightheadedness, or fainting',
            value: _dizzinessOrFainting,
            onChanged: (v) => setState(() => _dizzinessOrFainting = v ?? false),
          ),
          _buildSymptomCheckbox(
            label: 'High fever (≥ 38.5°C / 101.3°F)',
            value: _highFever,
            onChanged: (v) => setState(() => _highFever = v ?? false),
          ),
          _buildSymptomCheckbox(
            label: 'Severe abdominal or pelvic tenderness',
            value: _pelvicTenderness,
            onChanged: (v) => setState(() => _pelvicTenderness = v ?? false),
          ),

          const SizedBox(height: 16.0),

          // Evaluate Button
          PrimaryButton(
            label: _isEvaluating
                ? 'Evaluating clinical triage...'
                : 'Check safety guidelines',
            onPressed: _isEvaluating ? null : _evaluateTriage,
          ),

          if (_triageError != null) ...[
            const SizedBox(height: 12.0),
            Text(
              _triageError!,
              style: GoogleFonts.dmSans(
                fontSize: 13.0,
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          if (_triageResult != null) ...[
            const SizedBox(height: 20.0),
            _buildTriageResultCard(_triageResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          title: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13.0,
              fontWeight: value ? FontWeight.w600 : FontWeight.w400,
              color: value ? AppColors.ink : AppColors.muted,
            ),
          ),
          value: value,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.danger,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }

  Widget _buildTriageResultCard(SafetyTriageResult result) {
    final isEmergency = result.isRedFlag;
    final badgeColor = isEmergency
        ? AppColors.danger
        : (result.triageLevel == 'URGENT_EVALUATION'
              ? AppColors.gold
              : AppColors.sage);
    final bgColor = isEmergency
        ? const Color(0xFFFBF4F1)
        : (result.triageLevel == 'URGENT_EVALUATION'
              ? AppColors.goldLight
              : AppColors.sageLight);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  result.triageLevel,
                  style: GoogleFonts.dmSans(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            result.alertHeadline,
            style: GoogleFonts.dmSans(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            result.explanation,
            style: GoogleFonts.dmSans(
              fontSize: 13.0,
              color: AppColors.ink,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Action required: ${result.actionRequired}',
            style: GoogleFonts.dmSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: isEmergency ? AppColors.danger : AppColors.plum,
            ),
          ),
          if (result.recommendedSteps.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Text(
              'Recommended clinical steps:',
              style: GoogleFonts.dmSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 4.0),
            ...result.recommendedSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.muted)),
                    Expanded(
                      child: Text(
                        step,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.0,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
