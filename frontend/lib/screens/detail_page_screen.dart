import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/mini_chart_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

enum DetailType {
  physical,
  patterns,
  guidance,
  passport,
  doctors,
  summary,
  reminders,
  settings,
}

/// Dynamic detail feature screen for inHERcue.
/// Directly mirrors the `DetailPage({ screen, go })` component from the React reference:
/// - Supports all 8 feature modules with rich interactive fidelity:
///   1. physical (symptom & check-in shortcuts, recent physical records panel)
///   2. patterns (time range filters, sleep duration chart, observation insights)
///   3. guidance (daily wellness card carousel, references, takeaways, save & next actions)
///   4. passport (user-controlled conditions, allergies, medications, health records)
///   5. doctors (specialty search & filtering, sample verified providers)
///   6. summary (doctor-ready briefing launcher)
///   7. reminders (gentle notification prompts)
///   8. settings (privacy & data governance controls)
/// - Topbar, hero icon badge, kicker, Playfair Display heading, subtitle
/// - Standard medical disclaimer note
/// - Synced bottom navigation
class DetailPageScreen extends StatefulWidget {
  final DetailType type;
  final VoidCallback? onBack;

  const DetailPageScreen({
    super.key,
    required this.type,
    this.onBack,
  });

  @override
  State<DetailPageScreen> createState() => _DetailPageScreenState();
}

class _DetailPageScreenState extends State<DetailPageScreen> {
  // State for interactive modules
  bool _saved = false;
  String _selectedItem = '';
  String _range = 'Week';
  String _searchQuery = '';
  int _tipIndex = 0;

  static const List<List<String>> _wellnessTips = [
    [
      'Rest is a health habit',
      'Keeping a regular sleep and wake time may support sleep quality.',
      'NHS — How to get to sleep'
    ],
    [
      'Hydration is personal',
      'Fluid needs change with activity, weather, pregnancy and health conditions.',
      'NHS — Water, drinks and hydration'
    ],
    [
      'Movement can be gentle',
      'Short, comfortable activity still counts; choose movement that suits your body.',
      'WHO — Physical activity'
    ],
  ];

  Map<String, dynamic> _getHeroData() {
    switch (widget.type) {
      case DetailType.physical:
        return {
          'title': 'Physical Health',
          'eyebrow': 'LISTEN TO YOUR BODY',
          'text': 'Log symptoms, energy and movement to notice what supports your wellbeing.',
          'icon': InHercueIconType.heart,
          'nav': InHercueNavDestination.home,
        };
      case DetailType.patterns:
        return {
          'title': 'Health Patterns',
          'eyebrow': 'DEMO INSIGHTS',
          'text': 'Your energy tends to be higher on days after 7+ hours of sleep.',
          'icon': InHercueIconType.chart,
          'nav': InHercueNavDestination.records,
        };
      case DetailType.guidance:
        return {
          'title': 'Wellness Card',
          'eyebrow': 'LEARN AT YOUR PACE',
          'text': 'One practical, clearly sourced wellbeing idea at a time.',
          'icon': InHercueIconType.learn,
          'nav': InHercueNavDestination.learn,
        };
      case DetailType.passport:
        return {
          'title': 'Health Passport',
          'eyebrow': 'YOUR HEALTH, TOGETHER',
          'text': 'A portable overview of your conditions, medications, allergies and care team.',
          'icon': InHercueIconType.shield,
          'nav': InHercueNavDestination.records,
        };
      case DetailType.doctors:
        return {
          'title': 'Find a Doctor',
          'eyebrow': 'CARE THAT LISTENS',
          'text': 'Browse verified women’s health professionals who align with your needs.',
          'icon': InHercueIconType.search,
          'nav': InHercueNavDestination.profile,
        };
      case DetailType.summary:
        return {
          'title': 'Doctor-Ready Summary',
          'eyebrow': 'PREPARE WITH CONFIDENCE',
          'text': 'Turn your tracked history into a concise overview for your next appointment.',
          'icon': InHercueIconType.records,
          'nav': InHercueNavDestination.records,
        };
      case DetailType.reminders:
        return {
          'title': 'Reminders',
          'eyebrow': 'SUPPORTIVE, NOT PUSHY',
          'text': 'Choose gentle prompts for check-ins, medication, hydration and appointments.',
          'icon': InHercueIconType.bell,
          'nav': InHercueNavDestination.profile,
        };
      case DetailType.settings:
        return {
          'title': 'Settings & Privacy',
          'eyebrow': 'YOU ARE IN CONTROL',
          'text': 'Manage privacy, data, notifications and accessibility.',
          'icon': InHercueIconType.shield,
          'nav': InHercueNavDestination.profile,
        };
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

  @override
  Widget build(BuildContext context) {
    final hero = _getHeroData();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
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
                        // Detail hero
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
                                icon: hero['icon'] as InHercueIconType,
                                size: 30.0,
                                color: AppColors.plum,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          hero['eyebrow'] as String,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          hero['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          hero['text'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Module Content
                        _buildModuleContent(context),

                        const SizedBox(height: 28.0),
                        Text(
                          'inHERcue supports reflection and preparation, not diagnosis or treatment. Speak with a qualified professional for medical guidance.',
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
              currentDestination: hero['nav'] as InHercueNavDestination,
              onDestinationSelected: (dest) => _navigateDestination(context, dest),
              onNewEntry: () => Navigator.of(context).pushNamed(AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleContent(BuildContext context) {
    switch (widget.type) {
      case DetailType.physical:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.symptoms),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.roseLight,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const InHercueIcon(icon: InHercueIconType.plus, size: 22.0, color: AppColors.plum),
                          const SizedBox(height: 10.0),
                          Text('Log a symptom', style: GoogleFonts.playfairDisplay(fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                          const SizedBox(height: 4.0),
                          Text('Record severity, timing, frequency and context.', style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.muted)),
                          const SizedBox(height: 12.0),
                          Text('Open symptom form →', style: GoogleFonts.dmSans(fontSize: 12.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.checkin),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.sageLight,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const InHercueIcon(icon: InHercueIconType.heart, size: 22.0, color: AppColors.plum),
                          const SizedBox(height: 10.0),
                          Text('Daily body check', style: GoogleFonts.playfairDisplay(fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                          const SizedBox(height: 4.0),
                          Text('Add today’s physical signals to your full check-in.', style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.muted)),
                          const SizedBox(height: 12.0),
                          Text('Start check-in →', style: GoogleFonts.dmSans(fontSize: 12.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            Container(
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RECENT PHYSICAL RECORDS · DEMO', style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.rose)),
                  const SizedBox(height: 8.0),
                  Text('Your latest entries', style: GoogleFonts.playfairDisplay(fontSize: 22.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                  const SizedBox(height: 12.0),
                  _buildRecordRow('Headache', '24 May · Mild · Resolved'),
                  _buildRecordRow('Energy', '25 May · Steady'),
                ],
              ),
            ),
          ],
        );

      case DetailType.patterns:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Week', 'Month', 'Custom range'].map((r) {
                  final isSelected = _range == r;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(r),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _range = r),
                      backgroundColor: AppColors.paper,
                      selectedColor: AppColors.plum,
                      labelStyle: GoogleFonts.dmSans(
                        color: isSelected ? Colors.white : AppColors.ink,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(color: AppColors.line),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            MiniChartWidget(
              title: 'Sleep duration',
              subtitle: '$_range · sample data',
            ),
            const SizedBox(height: 18.0),

            Container(
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBSERVATION · SAMPLE DATA', style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.rose)),
                  const SizedBox(height: 8.0),
                  Text('Sleep and energy', style: GoogleFonts.playfairDisplay(fontSize: 22.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                  const SizedBox(height: 8.0),
                  Text(
                    'Higher energy was recorded on three days following 7+ hours of sleep. This is an observation, not a confirmed cause.',
                    style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 18.0),
                  SecondaryButton(
                    label: 'View supporting entries',
                    onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.records),
                  ),
                ],
              ),
            ),
          ],
        );

      case DetailType.guidance:
        final tip = _wellnessTips[_tipIndex];
        return Container(
          padding: const EdgeInsets.all(26.0),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DAILY WELLNESS CARD · ${_tipIndex + 1} OF ${_wellnessTips.length}',
                style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.rose),
              ),
              const SizedBox(height: 10.0),
              Text(
                tip[0],
                style: GoogleFonts.playfairDisplay(fontSize: 26.0, fontWeight: FontWeight.w600, color: AppColors.plum),
              ),
              const SizedBox(height: 10.0),
              Text(
                tip[1],
                style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted, height: 1.6),
              ),
              const SizedBox(height: 18.0),

              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Practical takeaway', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppColors.plum)),
                    const SizedBox(height: 4.0),
                    Text(
                      'Choose one small action that feels realistic today, and adjust it to your needs.',
                      style: GoogleFonts.dmSans(fontSize: 13.0, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Text('Reference: ${tip[2]}', style: GoogleFonts.dmSans(fontSize: 11.0, color: AppColors.muted)),
              const SizedBox(height: 24.0),

              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: _saved ? 'Saved for later' : 'Save tip',
                      onPressed: () => setState(() => _saved = !_saved),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Next tip →',
                      onPressed: () {
                        setState(() {
                          _tipIndex = (_tipIndex + 1) % _wellnessTips.length;
                          _saved = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case DetailType.passport:
        final passportItems = [
          ['Confirmed conditions', 'No conditions added'],
          ['Allergies & reactions', 'Pollen · user-entered'],
          ['Current medications', 'No current medications added'],
          ['Previous medications', 'No history added'],
          ['Medical documents', '0 uploaded documents'],
          ['Health notes', '2 demo notes'],
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                color: AppColors.plum,
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEALTH PASSPORT · USER-ENTERED', style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.roseLight)),
                  const SizedBox(height: 8.0),
                  Text('Your health information, in one place.', style: GoogleFonts.playfairDisplay(fontSize: 22.0, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 6.0),
                  Text('Unknown information stays unknown until you add or confirm it.', style: GoogleFonts.dmSans(fontSize: 13.0, color: const Color(0xFFDED1DA))),
                ],
              ),
            ),
            const SizedBox(height: 18.0),

            ...passportItems.map((item) {
              final isSelected = _selectedItem == item[0];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedItem = item[0]),
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    padding: const EdgeInsets.all(17.0),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: isSelected ? AppColors.rose : AppColors.line),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item[0], style: GoogleFonts.dmSans(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                            const SizedBox(height: 2.0),
                            Text(item[1], style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.muted)),
                          ],
                        ),
                        Text(isSelected ? 'Selected' : 'View / edit →', style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.rose, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (_selectedItem.isNotEmpty) ...[
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(color: AppColors.sageLight, borderRadius: BorderRadius.circular(12.0)),
                child: Text('$_selectedItem selected. Add, edit and delete controls are available in this prototype section.', style: GoogleFonts.dmSans(color: const Color(0xFF3D6645), fontSize: 13.0)),
              ),
            ],

            const SizedBox(height: 18.0),
            PrimaryButton(
              label: _saved ? 'Manual entry form ready' : 'Add health information',
              onPressed: () => setState(() => _saved = true),
            ),
          ],
        );

      case DetailType.doctors:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const InHercueIcon(icon: InHercueIconType.search, size: 20.0, color: AppColors.muted),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search specialty or concern',
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'General Physician',
                  'Gynecologist',
                  'Obstetrician',
                  'Endocrinologist',
                  'Dermatologist',
                  'Psychiatrist',
                  'Nutritionist',
                ].map((spec) {
                  final isSelected = _selectedItem == spec || (_selectedItem.isEmpty && spec == 'All');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedItem = spec),
                      backgroundColor: AppColors.paper,
                      selectedColor: AppColors.plum,
                      labelStyle: GoogleFonts.dmSans(color: isSelected ? Colors.white : AppColors.ink, fontSize: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: const BorderSide(color: AppColors.line)),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20.0),

            Text('SAMPLE PROVIDERS · VERIFY DETAILS BEFORE BOOKING', style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: AppColors.rose)),
            const SizedBox(height: 12.0),

            if (_searchQuery.toLowerCase().contains('zzz'))
              Container(
                padding: const EdgeInsets.all(35.0),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Text('No sample providers found', style: GoogleFonts.playfairDisplay(fontSize: 20.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                    const SizedBox(height: 6.0),
                    Text('Try another specialty or clear your search.', style: GoogleFonts.dmSans(fontSize: 13.0, color: AppColors.muted)),
                  ],
                ),
              )
            else ...[
              _buildDoctorCard('Dr. Amina Malik', 'AM', 'Women’s Health · Virtual visits'),
              _buildDoctorCard('Dr. Elena Ramos', 'ER', 'Gynecology · In-person consultations'),
            ],
          ],
        );

      case DetailType.summary:
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('DOCTOR-READY REPORTS', style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.rose)),
              const SizedBox(height: 8.0),
              Text('Prepare a clear health conversation.', style: GoogleFonts.playfairDisplay(fontSize: 24.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
              const SizedBox(height: 8.0),
              Text('Select records, review the wording and control what is shared.', style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted, height: 1.5)),
              const SizedBox(height: 20.0),
              PrimaryButton(
                label: 'Create a health report',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.reports),
              ),
            ],
          ),
        );

      case DetailType.reminders:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...[
              'Daily check-in · 8:00 PM',
              'Medication reminders · Off',
              'Appointment reminders · On',
            ].map((rem) {
              final isSel = _selectedItem == rem;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedItem = isSel ? '' : rem),
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rem, style: GoogleFonts.dmSans(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                            const SizedBox(height: 3.0),
                            Text('Notification text hides sensitive health details.', style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.muted)),
                          ],
                        ),
                        Text(isSel ? 'Updated' : 'Manage →', style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.rose, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      case DetailType.settings:
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('PRIVACY & CONTROL', style: GoogleFonts.dmSans(fontSize: 10.0, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.rose)),
              const SizedBox(height: 8.0),
              Text('Your information stays under your control.', style: GoogleFonts.playfairDisplay(fontSize: 24.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
              const SizedBox(height: 8.0),
              Text('Manage language, notification privacy, account security, export and deletion.', style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted, height: 1.5)),
              const SizedBox(height: 18.0),
              _buildRecordRow('Notification privacy', 'Sensitive details hidden'),
              _buildRecordRow('Data export', 'Available on request'),
              const SizedBox(height: 20.0),
              SecondaryButton(
                label: _saved ? 'Settings saved' : 'Review privacy settings',
                onPressed: () => setState(() => _saved = true),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildRecordRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.ink)),
          Text(value, style: GoogleFonts.dmSans(fontSize: 13.0, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(String name, String initials, String meta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: const BoxDecoration(
              color: AppColors.roseLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.plum,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.playfairDisplay(fontSize: 17.0, fontWeight: FontWeight.w600, color: AppColors.plum)),
                const SizedBox(height: 2.0),
                Text('Sample provider · credentials not connected', style: GoogleFonts.dmSans(fontSize: 11.0, color: AppColors.muted)),
                const SizedBox(height: 2.0),
                Text(meta, style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.ink)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.plum,
                  content: Text('Sample provider profile: $name', style: GoogleFonts.dmSans(color: Colors.white)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.plum,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            ),
            child: const Text('View profile'),
          ),
        ],
      ),
    );
  }
}
