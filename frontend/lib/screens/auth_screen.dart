import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/user_model.dart';
import '../state/auth_state.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';

/// The official Authentication screen for inHercue.
/// Directly mirrors the `Auth({ go })` component from the Figma React/CSS reference:
/// - Linear gradient background: 120deg from ivory to rose-light
/// - Topbar with back navigation and urgent help action
/// - Centered card with 30px radius, soft shadow, and responsive clamp
/// - Dynamic kicker, heading, and subtitle for Login vs. Register
/// - Name field (Register only), Email address, and Password fields
/// - Inline error message banner matching `.error`
/// - Primary plum pill button with loading spinner
/// - Toggle text button to switch between Login and Register
class AuthScreen extends StatefulWidget {
  /// Optional injected [AuthState] (useful for tests or custom scope).
  final AuthState? authState;

  /// Initial mode (true = Login, false = Register). Defaults to false (Register).
  final bool initialIsLogin;

  /// Callback when the back button is pressed.
  final VoidCallback? onBack;

  /// Callback when "Urgent help" is pressed.
  final VoidCallback? onUrgent;

  /// Optional callback invoked upon successful authentication.
  /// Receives the authenticated [UserModel] and a boolean flag indicating if this was a new registration.
  final void Function(UserModel user, bool isNewRegistration)? onAuthenticated;

  const AuthScreen({
    super.key,
    this.authState,
    this.initialIsLogin = false,
    this.onBack,
    this.onUrgent,
    this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _clientError;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AuthState _resolveAuthState() {
    return widget.authState ?? AuthStateScope.maybeOf(context) ?? AuthState();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _clientError = null;
      _resolveAuthState().clearError();
    });
  }

  Future<void> _submit() async {
    setState(() {
      _clientError = null;
    });

    final authState = _resolveAuthState();
    authState.clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    // Client-side validations
    if (!_isLogin && (name.length < 2 || name.length > 60)) {
      setState(() {
        _clientError = 'Please enter your name (between 2 and 60 characters).';
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _clientError = 'Enter a valid email address.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _clientError = 'Password must be at least 6 characters long.';
      });
      return;
    }

    // Backend registration validation requires at least 8 chars, 1 number, 1 special char
    if (!_isLogin) {
      final hasNumber = RegExp(r'[0-9]').hasMatch(password);
      final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);

      if (password.length < 8 || !hasNumber || !hasSpecial) {
        setState(() {
          _clientError = 'Password must be at least 8 characters long, contain at least one number and one special character.';
        });
        return;
      }
    }

    bool success;
    if (_isLogin) {
      success = await authState.login(email: email, password: password);
    } else {
      success = await authState.register(
        name: name,
        email: email,
        password: password,
      );
    }

    if (!mounted) return;

    if (success && authState.currentUser != null) {
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!(authState.currentUser!, !_isLogin);
      } else {
        // Default navigation matching Figma App.tsx:95
        // Registration -> Profile Setup; Login -> Home Dashboard
        if (!_isLogin) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      }
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  void _handleUrgent() {
    if (widget.onUrgent != null) {
      widget.onUrgent!();
    } else {
      Navigator.of(context).pushNamed(AppRoutes.urgent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = _resolveAuthState();

    return ListenableBuilder(
      listenable: authState,
      builder: (context, _) {
        final activeError = _clientError ?? authState.errorMessage;
        final isLoading = authState.isLoading;

        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = (screenWidth - 40.0).clamp(0.0, 520.0);

        return Scaffold(
          backgroundColor: AppColors.ivory,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // CSS: .auth-screen { min-height: 100vh; background: linear-gradient(120deg,var(--ivory),var(--rose-light)); }
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ivory, AppColors.roseLight],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Topbar with Back button and Urgent Help
                  InHercueTopbar(onBack: _handleBack, onUrgent: _handleUrgent),

                  // Scrollable auth card
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: Center(
                        child: Container(
                          width: cardWidth,
                          // CSS: .auth-card { background: rgba(255,253,249,.88); padding: clamp(26px,6vw,50px); border-radius: 30px; box-shadow: 0 20px 70px rgba(67,43,61,.1); }
                          decoration: BoxDecoration(
                            color: AppColors.paper.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.plum.withValues(alpha: 0.10),
                                blurRadius: 70.0,
                                offset: const Offset(0.0, 20.0),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: (screenWidth * 0.06).clamp(20.0, 36.0),
                            vertical: 36.0,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Kicker
                                Text(
                                  _isLogin
                                      ? 'WELCOME BACK'
                                      : 'YOUR SPACE, YOUR PACE',
                                  style: AppTextStyles.kicker,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 10.0),

                                // H2 Title
                                Text(
                                  _isLogin
                                      ? 'Good to see you.'
                                      : 'Create your account',
                                  style: AppTextStyles.screenHeading.copyWith(
                                    fontSize: 32.0,
                                    height: 1.18,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 10.0),

                                // Subtitle Muted
                                Text(
                                  _isLogin ? 'Continue your wellness journey.' : 'A private place to understand your whole health.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.muted,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 24.0),

                                // First Name Field (Register only)
                                if (!_isLogin) ...[
                                  _buildFieldLabel('First name'),
                                  const SizedBox(height: 8.0),
                                  _buildTextInput(
                                    controller: _nameController,
                                    hintText: 'How should we greet you?',
                                    enabled: !isLoading,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: 18.0),
                                ],

                                // Email Address Field
                                _buildFieldLabel('Email address'),
                                const SizedBox(height: 8.0),
                                _buildTextInput(
                                  controller: _emailController,
                                  hintText: 'you@example.com',
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 18.0),

                                // Password Field
                                _buildFieldLabel('Password'),
                                const SizedBox(height: 8.0),
                                _buildTextInput(
                                  controller: _passwordController,
                                  hintText: _isLogin ? 'Enter your password' : 'At least 8 characters (1 number, 1 special)',
                                  enabled: !isLoading,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20.0,
                                      color: AppColors.muted,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18.0),

                                // Error Banner (.error)
                                if (activeError != null &&
                                    activeError.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAE8E7),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 16.0,
                                          color: AppColors.danger,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            activeError,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12.0,
                                              color: AppColors.danger,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18.0),
                                ],

                                // Submit Button
                                PrimaryButton(
                                  label: _isLogin ? 'Log in' : 'Create account',
                                  showArrow: true,
                                  isLoading: isLoading,
                                  onPressed: isLoading ? null : _submit,
                                ),
                                const SizedBox(height: 14.0),

                                // Mode Toggle Button (.text-button)
                                Semantics(
                                  button: true,
                                  label: _isLogin
                                      ? 'Switch to create an account'
                                      : 'Switch to log in',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isLoading ? null : _toggleMode,
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                        ),
                                        child: Text(
                                          _isLogin
                                              ? 'New here? Create an account'
                                              : 'Already have an account? Log in',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.plum,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: AppColors.plum,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: AppColors.plum,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14.0,
          color: AppColors.muted.withValues(alpha: 0.70),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 15.0,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.line, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.line, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.plum, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: BorderSide(
            color: AppColors.line.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
