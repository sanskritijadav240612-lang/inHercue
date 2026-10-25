import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/services/passport_api_service.dart';
import '../state/auth_state.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';

/// The official Profile Setup / Onboarding questionnaire for inHercue.
/// Directly mirrors the `ProfileSetup({ go })` component from the Figma React/CSS reference:
/// - Step 1: Health Focus ('What would you like to focus on?')
/// - Step 2: Cycle Description ('How would you describe your cycle?')
/// - Step 3: Success Confirmation ('You’re all set, Maya.')
/// - Animated progress bar matching Figma `.progress` and `.progress i`
/// - Interactive choice pills with circle check indicators matching `.choice`
/// - Sage completion card matching `.success-card`
/// - Graceful back navigation between steps or back to auth
class ProfileSetupScreen extends StatefulWidget {
  /// Optional user name override (defaults to authenticated user name, or "Maya" from Figma reference).
  final String? userName;

  /// Optional callback invoked when all steps are completed.
  /// Receives the selected focus area and cycle description.
  final void Function(String focusArea, String cycleType)? onCompleted;

  /// Optional callback when the back button is pressed from Step 1.
  final VoidCallback? onBackToAuth;

  /// Optional callback when "Urgent help" is pressed.
  final VoidCallback? onUrgent;

  const ProfileSetupScreen({
    super.key,
    this.userName,
    this.onCompleted,
    this.onBackToAuth,
    this.onUrgent,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 1;
  String _selectedFocus = '';
  String _selectedCycle = '';
  bool _isSaving = false;
  bool _initialFetchDone = false;
  String? _errorMessage;
  final PassportApiService _passportService = PassportApiService();

  // Options directly from Figma App.tsx:126-127
  static const List<String> _focusOptions = [
    'Understand my cycle',
    'Improve my energy',
    'Support my mental health',
    'Build healthier routines',
  ];

  static const List<String> _cycleOptions = [
    'Regular',
    'Sometimes irregular',
    'I don’t have periods',
    'Prefer not to say',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialFetchDone) {
      _initialFetchDone = true;
      _loadExistingPassport();
    }
  }

  Future<void> _loadExistingPassport() async {
    final authState = AuthStateScope.maybeOf(context);
    final token = authState?.token;
    if (token == null || token.isEmpty) return;

    try {
      final passport = await _passportService.getPassport(token);
      if (passport != null && mounted) {
        setState(() {
          if (passport.focus != null &&
              _focusOptions.contains(passport.focus)) {
            _selectedFocus = passport.focus!;
          }
          if (passport.cycleType != null &&
              _cycleOptions.contains(passport.cycleType)) {
            _selectedCycle = passport.cycleType!;
          }
        });
      }
    } catch (_) {
      // Non-fatal if passport does not exist yet
    }
  }

  String get _currentChoice {
    if (_step == 1) return _selectedFocus;
    if (_step == 2) return _selectedCycle;
    return '';
  }

  void _selectChoice(String choice) {
    setState(() {
      if (_step == 1) {
        _selectedFocus = choice;
      } else if (_step == 2) {
        _selectedCycle = choice;
      }
    });
  }

  void _handleBack() {
    if (_step > 1) {
      setState(() {
        _step--;
      });
    } else {
      if (widget.onBackToAuth != null) {
        widget.onBackToAuth!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
      }
    }
  }

  void _handleUrgent() {
    if (widget.onUrgent != null) {
      widget.onUrgent!();
    } else {
      Navigator.of(context).pushNamed(AppRoutes.urgent);
    }
  }

  Future<void> _handleContinue() async {
    if (_step < 3) {
      setState(() {
        _step++;
      });
      return;
    }

    final authState = AuthStateScope.maybeOf(context);
    final token = authState?.token;

    if (token != null && token.isNotEmpty) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        await _passportService.savePassport(
          token: token,
          focus: _selectedFocus.isNotEmpty ? _selectedFocus : null,
          cycleType: _selectedCycle.isNotEmpty ? _selectedCycle : null,
        );
        await authState?.markOnboardingCompleted();

        if (!mounted) return;
        if (widget.onCompleted != null) {
          widget.onCompleted!(_selectedFocus, _selectedCycle);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Could not save profile preferences. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.rose,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleContinue,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else {
      // Demo mode or unauthenticated
      if (widget.onCompleted != null) {
        widget.onCompleted!(_selectedFocus, _selectedCycle);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }

  String _resolveGreetingName() {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return widget.userName!.trim().split(' ').first;
    }

    final authState = AuthStateScope.maybeOf(context);
    final user = authState?.currentUser;
    if (user != null && user.name.isNotEmpty) {
      return user.name.trim().split(' ').first;
    }

    // Default name from Figma reference
    return 'Maya';
  }

  @override
  Widget build(BuildContext context) {
    final greetingName = _resolveGreetingName();
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = (screenWidth - 40.0).clamp(0.0, 520.0);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            // Topbar matching Figma: step > 1 ? setStep(step - 1) : go('auth')
            InHercueTopbar(onBack: _handleBack, onUrgent: _handleUrgent),

            // Scrollable questionnaire body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress Label: HEALTH PROFILE | {step} OF 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'HEALTH PROFILE',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.3,
                                  color: AppColors.muted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              '$_step of 3',
                              style: GoogleFonts.dmSans(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.3,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),

                        // Progress Bar (.progress and .progress i)
                        Container(
                          height: 4.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.line,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_step / 3.0).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.rose,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36.0),

                        // Kicker: PERSONALIZE YOUR CARE
                        Text(
                          'PERSONALIZE YOUR CARE',
                          style: AppTextStyles.kicker,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10.0),

                        // Dynamic H2 Title
                        Text(
                          _step == 1
                              ? 'What would you like to focus on?'
                              : _step == 2
                              ? 'How would you describe your cycle?'
                              : 'You’re all set, $greetingName.',
                          style: AppTextStyles.screenHeading.copyWith(
                            fontSize: 32.0,
                            height: 1.18,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10.0),

                        // Subtitle
                        Text(
                          'You can edit these answers anytime in your profile.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.muted,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 28.0),

                        // Steps 1 & 2: Choice List (.choice-list)
                        if (_step < 3) ...[
                          Column(
                            children:
                                (_step == 1 ? _focusOptions : _cycleOptions)
                                    .map((option) {
                                      final isSelected =
                                          _currentChoice == option;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10.0,
                                        ),
                                        child: _buildChoiceItem(
                                          label: option,
                                          isSelected: isSelected,
                                          onTap: () => _selectChoice(option),
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                          const SizedBox(height: 22.0),
                        ],

                        // Step 3: Success Card (.success-card)
                        if (_step == 3) ...[
                          Container(
                            // CSS: background: var(--sage-light); padding: 32px; border-radius: 20px; margin: 30px 0;
                            decoration: BoxDecoration(
                              color: AppColors.sageLight,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                // Success Check Circle (.success-icon)
                                Container(
                                  width: 46.0,
                                  height: 46.0,
                                  decoration: const BoxDecoration(
                                    color: AppColors.sage,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '✓',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),

                                // Title
                                Text(
                                  'Your wellness space is ready',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8.0),

                                // Subtitle
                                Text(
                                  'We’ll use your preferences to tailor your dashboard.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.0,
                                    color: AppColors.muted,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32.0),
                        ],

                        // Primary Action Button
                        PrimaryButton(
                          label: _isSaving
                              ? 'Saving profile...'
                              : (_step == 3
                                    ? 'Go to my dashboard'
                                    : 'Continue'),
                          showArrow: !_isSaving,
                          onPressed:
                              (_isSaving ||
                                  (_step < 3 && _currentChoice.isEmpty))
                              ? null
                              : _handleContinue,
                        ),
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

  Widget _buildChoiceItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            // CSS: .choice { background: var(--paper); border: 1px solid var(--line); border-radius: 15px; padding: 18px; }
            // CSS: .choice.selected { border-color: var(--rose); background: var(--rose-light); }
            decoration: BoxDecoration(
              color: isSelected ? AppColors.roseLight : AppColors.paper,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: isSelected ? AppColors.rose : AppColors.line,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 18.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 15.0,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? AppColors.plum : AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                // Indicator Circle (.choice i / .choice.selected i)
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.plum : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.plum : AppColors.line,
                      width: 1.0,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
