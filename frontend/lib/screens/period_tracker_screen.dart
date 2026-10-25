import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';

/// Period & cycle tracking screen for inHERcue.
/// Directly mirrors `PeriodTracker({ go })` from the React reference:
/// - Topbar with back, urgent, and alerts navigation
/// - Detail hero ("Cycle day 18 · Next period estimate: 5 June")
/// - 4-phase interactive cycle selector panel with distinct rounded corners
/// - Calendar month card with interactive month switcher, period day markers, and day selector
/// - Period logging form (start/end dates, bleeding level, cramps, additional symptoms)
/// - Historical cycle summary card ("Last three cycles: 28–31 days")
/// - Persistent bottom navigation (Records active)
class PeriodTrackerScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PeriodTrackerScreen({super.key, this.onBack});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  int _selectedDay = 18;
  int _monthOffset = 0; // 0 = May 2025, -1 = April 2025, 1 = June 2025
  int _phaseIndex =
      3; // 0 = Menstruation, 1 = Follicular, 2 = Ovulation, 3 = Luteal
  bool _logged = false;

  String _bleedingLevel = '';
  String _cramps = 'None';
  final TextEditingController _symptomsController = TextEditingController();

  static const List<List<String>> _phases = [
    [
      'Menstruation',
      'Days 1–5',
      'Energy may feel lower. Rest and comfortable routines can be supportive.',
    ],
    [
      'Follicular',
      'Days 6–13',
      'Energy may gradually shift. Notice what movement and meals feel supportive.',
    ],
    [
      'Ovulation',
      'Around day 14',
      'Timing varies between people and cycles; this is a demo estimate.',
    ],
    [
      'Luteal',
      'Days 15–28',
      'You may notice changing energy or appetite. Track your own experience.',
    ],
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  BorderRadius _getPhaseBorderRadius(int index) {
    switch (index) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(80.0),
          topRight: Radius.circular(16.0),
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        );
      case 1:
        return const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(80.0),
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        );
      case 2:
        return const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
          bottomLeft: Radius.circular(80.0),
          bottomRight: Radius.circular(16.0),
        );
      case 3:
      default:
        return const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(80.0),
        );
    }
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

  String get _monthTitle {
    if (_monthOffset == 0) return 'May 2025';
    if (_monthOffset < 0) return 'April 2025';
    return 'June 2025';
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
              title: 'Period tracker',
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
                    constraints: const BoxConstraints(maxWidth: 760.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero
                        Center(
                          child: Container(
                            width: 62.0,
                            height: 62.0,
                            decoration: const BoxDecoration(
                              color: AppColors.roseLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: InHercueIcon(
                                icon: InHercueIconType.calendar,
                                size: 30.0,
                                color: AppColors.plum,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'DEMO CYCLE · ESTIMATES',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Cycle day 18',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Next period estimate: 5 June. Predictions are estimates and may change as you add data.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Phase Panel
                        Container(
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 540.0;

                              final phaseSelector = Transform.rotate(
                                angle: -0.035, // ~ -2 degrees tilt matching Figma reference
                                child: GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.1,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  children: List.generate(4, (index) {
                                    final p = _phases[index];
                                    final isActive = _phaseIndex == index;
                                    final borderRadius = _getPhaseBorderRadius(
                                      index,
                                    );

                                    return AnimatedScale(
                                      scale: isActive ? 1.03 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOut,
                                      child: InkWell(
                                        onTap: () =>
                                            setState(() => _phaseIndex = index),
                                        borderRadius: borderRadius,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14.0,
                                            vertical: 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.plum
                                                : AppColors.ivory,
                                            borderRadius: borderRadius,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'PHASE ${index + 1}',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 9.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: isActive
                                                      ? Colors.white.withValues(
                                                          alpha: 0.7,
                                                        )
                                                      : AppColors.muted,
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              Text(
                                                p[0],
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: isActive
                                                      ? Colors.white
                                                      : AppColors.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );

                              final phaseInfo = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'PHASE ${_phaseIndex + 1} · DEMO ESTIMATE',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.rose,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  Text(
                                    _phases[_phaseIndex][0],
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    _phases[_phaseIndex][1],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  Text(
                                    _phases[_phaseIndex][2],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13.0,
                                      color: AppColors.muted,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              );

                              if (isWide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(flex: 11, child: phaseSelector),
                                    const SizedBox(width: 18.0),
                                    Container(
                                      width: 1.0,
                                      height: 160.0,
                                      color: AppColors.line,
                                    ),
                                    const SizedBox(width: 18.0),
                                    Expanded(flex: 10, child: phaseInfo),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  phaseSelector,
                                  const SizedBox(height: 18.0),
                                  const Divider(
                                    color: AppColors.line,
                                    height: 1.0,
                                  ),
                                  const SizedBox(height: 14.0),
                                  phaseInfo,
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Calendar Month Card
                        Container(
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Text(
                                      '‹',
                                      style: TextStyle(
                                        fontSize: 26.0,
                                        color: AppColors.plum,
                                      ),
                                    ),
                                    onPressed: () =>
                                        setState(() => _monthOffset--),
                                  ),
                                  Text(
                                    _monthTitle,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.plum,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Text(
                                      '›',
                                      style: TextStyle(
                                        fontSize: 26.0,
                                        color: AppColors.plum,
                                      ),
                                    ),
                                    onPressed: () =>
                                        setState(() => _monthOffset++),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                                    .map((day) {
                                      return Text(
                                        day,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.muted,
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                              const SizedBox(height: 10.0),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 7,
                                mainAxisSpacing: 6.0,
                                crossAxisSpacing: 6.0,
                                children: List.generate(31, (index) {
                                  final day = index + 1;
                                  final isSelected = day == _selectedDay;
                                  final isPeriodDay =
                                      _monthOffset == 0 && day <= 5;
                                  return InkWell(
                                    onTap: () =>
                                        setState(() => _selectedDay = day),
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.plum
                                            : (isPeriodDay
                                                  ? AppColors.roseLight
                                                  : Colors.transparent),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$day',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13.0,
                                          fontWeight:
                                              (isSelected || isPeriodDay)
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? Colors.white
                                              : (isPeriodDay
                                                    ? AppColors.plum
                                                    : AppColors.ink),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Log Period Form
                        Container(
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Log May $_selectedDay',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.plum,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Bleeding level',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.plum,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              DropdownButtonFormField<String>(
                                initialValue: _bleedingLevel.isNotEmpty
                                    ? _bleedingLevel
                                    : null,
                                hint: const Text('Select level'),
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
                                items: const [
                                  DropdownMenuItem(
                                    value: 'None',
                                    child: Text('None'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Light',
                                    child: Text('Light'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Medium',
                                    child: Text('Medium'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Heavy',
                                    child: Text('Heavy'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _bleedingLevel = v ?? ''),
                              ),
                              const SizedBox(height: 16.0),

                              Text(
                                'Cramps',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.plum,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              DropdownButtonFormField<String>(
                                initialValue: _cramps,
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
                                items: const [
                                  DropdownMenuItem(
                                    value: 'None',
                                    child: Text('None'),
                                  ),
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
                                onChanged: (v) =>
                                    setState(() => _cramps = v ?? 'None'),
                              ),
                              const SizedBox(height: 16.0),

                              Text(
                                'Other symptoms',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.plum,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              TextFormField(
                                controller: _symptomsController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. fatigue, headache, bloating',
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
                              const SizedBox(height: 20.0),

                              PrimaryButton(
                                label: _logged
                                    ? 'Update period log'
                                    : 'Save period log',
                                onPressed: () {
                                  setState(() => _logged = true);
                                },
                              ),
                              if (_logged) ...[
                                const SizedBox(height: 14.0),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.sageLight,
                                    borderRadius: BorderRadius.circular(11.0),
                                  ),
                                  child: Text(
                                    'Saved to your cycle history.',
                                    style: GoogleFonts.dmSans(
                                      color: const Color(0xFF3D6645),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Cycle History Insight Card
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
                                'CYCLE HISTORY · DEMO DATA',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10.0,
                                  letterSpacing: 1.6,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.sage,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Last three cycles: 28–31 days',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.plum,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Apr 8–12 · Mar 10–14 · Feb 9–13. Cycle estimates are not contraception or medical advice.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.0,
                                  color: AppColors.muted,
                                  height: 1.5,
                                ),
                              ),
                            ],
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
}
