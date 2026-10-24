import 'package:flutter/widgets.dart';
import '../core/network/api_exceptions.dart';
import '../core/storage/session_storage.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_api_service.dart';

/// Manages authentication state, user session, and error messaging.
/// Implements [ChangeNotifier] so UI widgets can reactively rebuild on state changes
/// without embedding API request logic into presentation code.
class AuthState extends ChangeNotifier {
  final AuthApiService _authService;
  final SessionStorage _storage;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthState({
    AuthApiService? authService,
    SessionStorage? storage,
  })  : _authService = authService ?? AuthApiService(),
        _storage = storage ?? InMemorySessionStorage();

  /// Current authenticated user profile, or null if unauthenticated.
  UserModel? get currentUser => _currentUser;

  /// Active JWT authentication token.
  String? get token => _token;

  /// True when an authentication request is in flight.
  bool get isLoading => _isLoading;

  /// User-friendly error message from the most recent failed operation.
  String? get errorMessage => _errorMessage;

  /// True if the user has an active session token.
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Initializes the session from local storage.
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _token = await _storage.getToken();
      if (_token != null) {
        try {
          _currentUser = await _authService.getMe(_token!);
          await _storage.saveUser(_currentUser!);
        } on UnauthorizedException {
          // Token expired or invalid on server
          await logout();
        } catch (_) {
          // Fall back to cached user if offline
          _currentUser = await _storage.getUser();
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user with the inHercue backend.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    int? age,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        age: age,
      );

      _token = response.token;
      _currentUser = response.user;

      await _storage.saveToken(_token!);
      await _storage.saveUser(_currentUser!);

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logs in an existing user with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _token = response.token;
      _currentUser = response.user;

      await _storage.saveToken(_token!);
      await _storage.saveUser(_currentUser!);

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logs out the user, clearing the active token and session cache.
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _clearError();
    await _storage.clearAll();
    notifyListeners();
  }

  /// Clears any active error message.
  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

/// Provides [AuthState] down the widget tree using Flutter's built-in [InheritedNotifier].
class AuthStateScope extends InheritedNotifier<AuthState> {
  const AuthStateScope({
    super.key,
    required AuthState authState,
    required super.child,
  }) : super(notifier: authState);

  /// Retrieves the active [AuthState] from the ancestor [AuthStateScope].
  static AuthState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthStateScope>();
    assert(scope != null, 'No AuthStateScope found in context');
    return scope!.notifier!;
  }

  /// Retrieves the active [AuthState] if present, otherwise returns null.
  static AuthState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthStateScope>()?.notifier;
  }
}
