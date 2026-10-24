import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_topbar.dart';

/// Self-Care Studio screen for inHERcue.
/// Directly mirrors `SelfCare({ go })` from the React reference:
/// - Topbar with back, urgent, and alerts navigation
/// - Activity selector sidebar/list with 6 restorative practices
/// - Interactive player featuring animated timer orb, 3-step walkthrough, and playback controls (Favourite, Start/Pause, Restart, Complete)
/// - Bottom navigation (Learn active)
class SelfCareScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SelfCareScreen({
    super.key,
    this.onBack,
  });

  @override
  State<SelfCareScreen> createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends State<SelfCareScreen>
    with SingleTickerProviderStateMixin {
  static const List<List<String>> _activities = [
    [
      'Breathing reset',
      '3 min',
      'Breathe in slowly, pause gently, and breathe out at a comfortable pace.'
    ],
    [
      '5–4–3–2–1 grounding',
      '5 min',
      'Notice five things you see, four you feel, three you hear, two you smell and one you taste.'
    ],
    [
      'Evening wind-down',
      '10 min',
      'Lower stimulation and follow a familiar, comfortable sequence.'
    ],
    [
      'Gentle movement',
      '6 min',
      'Move within a comfortable range and stop if anything hurts.'
    ],
    [
      'Period comfort',
      '8 min',
      'Choose warmth, rest or another non-medical comfort that suits you.'
    ],
    [
      'Journal pause',
      '5 min',
      'Write without editing: what do I need less of, and more of?'
    ],
  ];

  int _selectedIndex = 0;
  String _status = 'ready'; // 'ready', 'running', 'paused', 'complete'
  int _step = 0;
  bool _favorite = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
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

  void _togglePlay() {
    setState(() {
      if (_status == 'running') {
        _status = 'paused';
        _animController.stop();
      } else {
        _status = 'running';
        _step = (_step < 2) ? _step + 1 : 2;
        _animController.repeat();
      }
    });
  }

  void _restart() {
    setState(() {
      _status = 'ready';
      _step = 0;
      _animController.reset();
    });
  }

  void _complete() {
    setState(() {
      _status = 'complete';
      _step = 2;
      _animController.stop();
    });
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
    final chosen = _activities[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
              title: 'Self-Care Studio',
              onBack: () => _handleBack(context),
              onUrgent: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
              onAlerts: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'SELF-CARE IS FOR DOING',
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'A small practice for right now.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Choose an activity, follow the steps, and stop whenever you need.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720.0;
                            final listWidget = _buildActivityList();
                            final playerWidget = _buildActivityPlayer(chosen);

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 280.0, child: listWidget),
                                  const SizedBox(width: 20.0),
                                  Expanded(child: playerWidget),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  listWidget,
                                  const SizedBox(height: 20.0),
                                  playerWidget,
                                ],
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            InHercueBottomNav(
              currentDestination: InHercueNavDestination.learn,
              onDestinationSelected: (dest) => _navigateDestination(context, dest),
              onNewEntry: () => Navigator.of(context).pushNamed(AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: List.generate(_activities.length, (i) {
        final a = _activities[i];
        final isActive = _selectedIndex == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = i;
                _restart();
              });
            },
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.plum : AppColors.paper,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: isActive ? AppColors.plum : AppColors.line),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      a[0],
                      style: GoogleFonts.dmSans(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.plum,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    a[1],
                    style: GoogleFonts.dmSans(
                      fontSize: 12.0,
                      color: isActive ? Colors.white.withValues(alpha: 0.7) : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActivityPlayer(List<String> chosen) {
    String orbText = 'Ready';
    if (_status == 'running') orbText = 'In progress';
    if (_status == 'paused') orbText = 'Paused';
    if (_status == 'complete') orbText = 'Done';

    return Container(
      padding: const EdgeInsets.all(26.0),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${chosen[1].toUpperCase()} · STEP ${_step + 1} OF 3',
            style: GoogleFonts.dmSans(
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: AppColors.rose,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            chosen[0],
            style: GoogleFonts.playfairDisplay(
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
            ),
          ),
          const SizedBox(height: 24.0),

          // Timer Orb
          Center(
            child: RotationTransition(
              turns: _status == 'running' ? _animController : const AlwaysStoppedAnimation(0),
              child: Container(
                width: 130.0,
                height: 130.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.roseLight, width: 10.0),
                ),
                child: Center(
                  child: Text(
                    orbText,
                    style: GoogleFonts.dmSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.plum,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          Text(
            chosen[2],
            style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 14.0),

          // Steps
          _buildStepRow(1, 'Get comfortable and check what your body needs.'),
          _buildStepRow(2, chosen[2]),
          _buildStepRow(3, 'Pause, notice, and finish when you are ready.'),

          const SizedBox(height: 24.0),

          // Controls
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _favorite = !_favorite),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    _favorite ? '★ Favourited' : '☆ Favourite',
                    style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.plum),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: _togglePlay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.plum,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    _status == 'running' ? 'Pause' : 'Start',
                    style: GoogleFonts.dmSans(fontSize: 12.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: OutlinedButton(
                  onPressed: _restart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    'Restart',
                    style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.plum),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: _complete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    'Complete',
                    style: GoogleFonts.dmSans(fontSize: 12.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          if (_status == 'complete') ...[
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                borderRadius: BorderRadius.circular(11.0),
              ),
              child: Text(
                'Activity complete. Your demo progress has been updated.',
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
    );
  }

  Widget _buildStepRow(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$num. ',
            style: GoogleFonts.dmSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 13.0,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
