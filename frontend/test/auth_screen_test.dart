import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/data/models/auth_response_model.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/services/auth_api_service.dart';
import 'package:frontend/screens/auth_screen.dart';
import 'package:frontend/state/auth_state.dart';

class FakeAuthApiService extends AuthApiService {
  AuthResponseModel? registerResponse;
  AuthResponseModel? loginResponse;
  Exception? errorToThrow;
  int registerCallCount = 0;
  int loginCallCount = 0;

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    int? age,
  }) async {
    registerCallCount++;
    if (errorToThrow != null) throw errorToThrow!;
    return registerResponse ??
        AuthResponseModel(
          token: 'fake-register-jwt',
          user: UserModel(
            userId: 'user-new',
            email: email,
            name: name,
            onboardingCompleted: false,
          ),
          message: 'User registered successfully',
        );
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (errorToThrow != null) throw errorToThrow!;
    return loginResponse ??
        AuthResponseModel(
          token: 'fake-login-jwt',
          user: UserModel(
            userId: 'user-existing',
            email: email,
            name: 'Maya Patel',
            onboardingCompleted: true,
          ),
          message: 'Login successful',
        );
  }
}

void main() {
  Future<void> pumpAuthScreen(
    WidgetTester tester, {
    required AuthState authState,
    bool initialIsLogin = false,
    VoidCallback? onBack,
    VoidCallback? onUrgent,
    void Function(UserModel, bool)? onAuthenticated,
  }) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.welcome) {
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Welcome Screen')));
          }
          if (settings.name == AppRoutes.profileSetup) {
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Profile Setup Screen')));
          }
          if (settings.name == AppRoutes.home) {
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home Dashboard Screen')));
          }
          if (settings.name == AppRoutes.urgent) {
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Urgent Screen')));
          }
          return null;
        },
        home: AuthScreen(
          authState: authState,
          initialIsLogin: initialIsLogin,
          onBack: onBack,
          onUrgent: onUrgent,
          onAuthenticated: onAuthenticated,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AuthScreen UI & Mode Toggle Tests', () {
    testWidgets('renders register mode by default matching Figma copy', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(tester, authState: authState);

      // Register mode kicker, title, and description
      expect(find.text('YOUR SPACE, YOUR PACE'), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('A private place to understand your whole health.'), findsOneWidget);

      // Name field exists
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Submit button
      expect(find.text('Create account'), findsOneWidget);

      // Toggle text
      expect(find.text('Already have an account? Log in'), findsOneWidget);
    });

    testWidgets('toggles to login mode when toggle button is tapped', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(tester, authState: authState);

      // Tap toggle to switch to Login
      await tester.ensureVisible(find.text('Already have an account? Log in'));
      await tester.tap(find.text('Already have an account? Log in'));
      await tester.pumpAndSettle();

      // Login mode kicker, title, description
      expect(find.text('WELCOME BACK'), findsOneWidget);
      expect(find.text('Good to see you.'), findsOneWidget);
      expect(find.text('Continue your wellness journey.'), findsOneWidget);

      // First name should now be hidden
      expect(find.text('First name'), findsNothing);

      // Submit button label
      expect(find.text('Log in'), findsOneWidget);

      // Toggle text
      expect(find.text('New here? Create an account'), findsOneWidget);
    });
  });

  group('AuthScreen Client Validation Tests', () {
    testWidgets('displays error on empty name during registration', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(tester, authState: authState);

      // Leave name empty and tap Create account
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Please enter your name'), findsOneWidget);
      expect(fakeService.registerCallCount, equals(0));
    });

    testWidgets('displays error on invalid email address', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(tester, authState: authState);

      // Enter valid name, invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'Maya');
      await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(2), 'Pass123!@#');

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(fakeService.registerCallCount, equals(0));
    });

    testWidgets('displays error when registration password lacks special character or number', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(tester, authState: authState);

      await tester.enterText(find.byType(TextFormField).at(0), 'Maya');
      await tester.enterText(find.byType(TextFormField).at(1), 'maya@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'simplepassword');

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.textContaining('contain at least one number and one special character'), findsOneWidget);
      expect(fakeService.registerCallCount, equals(0));
    });
  });

  group('AuthScreen API Integration & Navigation Tests', () {
    testWidgets('successfully registers and navigates to Profile Setup', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);
      UserModel? authenticatedUser;
      bool? isNew;

      await pumpAuthScreen(
        tester,
        authState: authState,
        onAuthenticated: (u, n) {
          authenticatedUser = u;
          isNew = n;
        },
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Maya');
      await tester.enterText(find.byType(TextFormField).at(1), 'maya@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass123!');

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(fakeService.registerCallCount, equals(1));
      expect(authenticatedUser, isNotNull);
      expect(authenticatedUser!.name, equals('Maya'));
      expect(isNew, isTrue);
    });

    testWidgets('displays DuplicateEmailException error from API', (tester) async {
      final fakeService = FakeAuthApiService();
      fakeService.errorToThrow = const DuplicateEmailException(
        message: 'An account with this email address already exists.',
      );
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(tester, authState: authState);

      await tester.enterText(find.byType(TextFormField).at(0), 'Maya');
      await tester.enterText(find.byType(TextFormField).at(1), 'existing@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass123!');

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(fakeService.registerCallCount, equals(1));
      expect(find.text('An account with this email address already exists.'), findsOneWidget);
    });

    testWidgets('successfully logs in and navigates to Home', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);
      UserModel? loggedInUser;
      bool? isNew;

      await pumpAuthScreen(
        tester,
        authState: authState,
        initialIsLogin: true,
        onAuthenticated: (u, n) {
          loggedInUser = u;
          isNew = n;
        },
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'maya@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'ValidPass123!');

      await tester.ensureVisible(find.text('Log in'));
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(fakeService.loginCallCount, equals(1));
      expect(loggedInUser, isNotNull);
      expect(isNew, isFalse);
    });

    testWidgets('displays InvalidCredentialsException error on failed login', (tester) async {
      final fakeService = FakeAuthApiService();
      fakeService.errorToThrow = const InvalidCredentialsException(
        message: 'Invalid email or password.',
      );
      final authState = AuthState(authService: fakeService);

      await pumpAuthScreen(
        tester,
        authState: authState,
        initialIsLogin: true,
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'WrongPassword123!');

      await tester.ensureVisible(find.text('Log in'));
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(fakeService.loginCallCount, equals(1));
      expect(find.text('Invalid email or password.'), findsOneWidget);
    });
  });

  group('AuthScreen Navigation & Actions', () {
    testWidgets('triggers onBack callback when topbar back button is pressed', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);
      bool backTapped = false;

      await pumpAuthScreen(
        tester,
        authState: authState,
        onBack: () => backTapped = true,
      );

      await tester.tap(find.bySemanticsLabel('Go back'));
      await tester.pumpAndSettle();

      expect(backTapped, isTrue);
    });

    testWidgets('triggers onUrgent callback when urgent help is pressed', (tester) async {
      final fakeService = FakeAuthApiService();
      final authState = AuthState(authService: fakeService);
      bool urgentTapped = false;

      await pumpAuthScreen(
        tester,
        authState: authState,
        onUrgent: () => urgentTapped = true,
      );

      await tester.tap(find.text('Urgent help'));
      await tester.pumpAndSettle();

      expect(urgentTapped, isTrue);
    });
  });
}
