import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'state/auth_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InHercueApp());
}

/// The official root application widget for inHercue.
/// Configures the unified Material 3 light theme, global authentication state scope,
/// and centralized navigation routing matching the Figma design reference.
class InHercueApp extends StatefulWidget {
  /// Optional [AuthState] for dependency injection (useful for tests and mocks).
  final AuthState? authState;

  /// Optional initial route override. Defaults to [AppRoutes.welcome].
  final String? initialRoute;

  const InHercueApp({
    super.key,
    this.authState,
    this.initialRoute,
  });

  @override
  State<InHercueApp> createState() => _InHercueAppState();
}

class _InHercueAppState extends State<InHercueApp> {
  late final AuthState _authState;

  @override
  void initState() {
    super.initState();
    _authState = widget.authState ?? AuthState();
    // Initialize session from local storage unless injected
    if (widget.authState == null) {
      _authState.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthStateScope(
      authState: _authState,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: widget.initialRoute ?? AppRoutes.welcome,
        routes: AppRoutes.getRoutes(_authState),
      ),
    );
  }
}

/// Backward-compatible alias for [InHercueApp].
typedef MyApp = InHercueApp;
