import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../data/models/user_model.dart';
import '../state/auth_state.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/urgent_card.dart';

/// The official Home Dashboard screen for inHercue.
/// Faithfully reproduces the `Dashboard({ go })` component from the Figma React/CSS reference:
/// - Brand topbar with `inHERcue` logo, notification bell with unread badge, and urgent help link
/// - Responsive greeting banner with time of day, user name / demo fallback, and profile avatar
/// - Explicit demo mode indicator when operating without an active authenticated session
/// - Daily check-in prompt card with plum gradient, orb badge, and five-minute check-in call to action
/// - Section headings with editorial kicker and status pill
/// - Daily actions grid (Symptom Tracker, Period Tracker, Alerts count)
/// - 4-module pastel feature grid (Physical Health, Mental Wellness, Period Tracker, Health Patterns)
/// - Sage botanical wellness note card ("Your body isn't asking for perfection.")
/// - 7 horizontal resource cards (Self-Care Studio, Myth vs Fact, Find a Doctor, etc.)
/// - Urgent help card banner
/// - Frosted translucent bottom navigation with elevated New Entry (+) button
class HomeDashboardScreen extends StatelessWidget {
  /// Optional injected [AuthState] (useful for tests or custom scope).
  final AuthState? authState;

  /// Explicit flag indicating if the screen is in demo mode.
  /// If null, inspected from route arguments or inferred from session state.
  final bool? isDemo;

  /// Optional date string override for deterministic display in tests.
  final String? dateString;

  /// Optional navigation callback override for testing.
  final void Function(String routeName)? onNavigate;

  const HomeDashboardScreen({
    super.key,
    this.authState,
    this.isDemo,
    this.dateString,
    this.onNavigate,
  });

  bool _resolveIsDemo(BuildContext context, AuthState? resolvedAuthState) {
    if (isDemo != null) return isDemo!;
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map && routeArgs['isDemo'] == true) return true;
    final isAuthenticated = resolvedAuthState?.isAuthenticated ?? false;
    return !isAuthenticated;
  }

  UserModel? _resolveUser(BuildContext context, AuthState? resolvedAuthState) {
    return resolvedAuthState?.currentUser;
  }

  String _formatTodayDate() {
    if (dateString != null && dateString!.isNotEmpty) return dateString!;
    final now = DateTime.now();
    const weekdays = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY'
    ];
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month';
  }

  void _navigateTo(BuildContext context, String routeName) {
    if (onNavigate != null) {
      onNavigate!(routeName);
    } else {
      Navigator.of(context).pushNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAuthState = authState ?? AuthStateScope.maybeOf(context);
    final user = _resolveUser(context, resolvedAuthState);
    final isDemoMode = _resolveIsDemo(context, resolvedAuthState);

    // Displayed name logic:
    // - Demo mode: "Maya" (from Figma reference dataset)
    // - Authenticated: First name from user record
    // - Unauthenticated fallback: "friend"
    final displayName = isDemoMode
        ? 'Maya'
        : (user != null && user.name.trim().isNotEmpty
            ? user.name.trim().split(' ').first
            : 'friend');

    final avatarInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'M';

    final dateDisplay = _formatTodayDate();

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Topbar matching Figma: onUrgent and onAlerts, stylized logo on left
            InHercueTopbar(
              onUrgent: () => _navigateTo(context, AppRoutes.urgent),
              onAlerts: () => _navigateTo(context, AppRoutes.alerts),
              alertCount: 2,
            ),

            // Scrollable Dashboard Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 32.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;
                        final isNarrow = screenWidth < 620.0;
                        final isWide = screenWidth >= 760.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Explicit Mode Indicator Banner
                            if (isDemoMode)
                              _buildDemoBanner(context)
                            else
                              _buildAuthenticatedBanner(context, user),

                            const SizedBox(height: 12.0),

                            // 2. Greeting Header
                            _buildGreeting(
                              context,
                              dateDisplay: dateDisplay,
                              displayName: displayName,
                              avatarInitial: avatarInitial,
                              isNarrow: isNarrow,
                            ),

                            const SizedBox(height: 24.0),

                            // 3. Five-minute Check-In Card
                            _buildCheckinCard(context, isNarrow: isNarrow),

                            const SizedBox(height: 36.0),

                            // 4. Section Heading: "YOUR WELLBEING"
                            _buildSectionHeading(
                              kicker: 'YOUR WELLBEING',
                              title: 'Explore your health',
                              badgeText: isDemoMode ? 'Demo data' : 'Active record',
                            ),

                            const SizedBox(height: 14.0),

                            // 5. Daily Actions (Symptom, Period, Alerts)
                            _buildDailyActions(
                              context,
                              isNarrow: isNarrow,
                              isDemo: isDemoMode,
                            ),

                            const SizedBox(height: 18.0),

                            // 6. 4-Module Feature Grid
                            _buildFeatureGrid(
                              context,
                              isWide: isWide,
                              isNarrow: isNarrow,
                              isDemo: isDemoMode,
                            ),

                            const SizedBox(height: 18.0),

                            // 7. Botanical Wellness Note Card
                            _buildWellnessCard(context, isNarrow: isNarrow),

                            const SizedBox(height: 36.0),

                            // 8. Section Heading: "JUST FOR YOU"
                            _buildSectionHeading(
                              kicker: 'JUST FOR YOU',
                              title: 'Care for your whole self',
                            ),

                            const SizedBox(height: 14.0),

                            // 9. Horizontal Resource Cards
                            _buildHorizontalCards(context, screenWidth: screenWidth),

                            const SizedBox(height: 18.0),

                            // 10. Urgent Medical Help Card
                            UrgentCard(
                              onUrgent: () => _navigateTo(context, AppRoutes.urgent),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation matching Figma
            InHercueBottomNav(
              currentDestination: InHercueNavDestination.home,
              onDestinationSelected: (destination) {
                switch (destination) {
                  case InHercueNavDestination.home:
                    break;
                  case InHercueNavDestination.records:
                    _navigateTo(context, AppRoutes.records);
                    break;
                  case InHercueNavDestination.newEntry:
                    _navigateTo(context, AppRoutes.entry);
                    break;
                  case InHercueNavDestination.learn:
                    _navigateTo(context, AppRoutes.learn);
                    break;
                  case InHercueNavDestination.profile:
                    _navigateTo(context, AppRoutes.profile);
                    break;
                }
              },
              onNewEntry: () => _navigateTo(context, AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Mode Status Banners
  // ---------------------------------------------------------------------------

  Widget _buildDemoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.gold, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, size: 16.0, color: AppColors.gold),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'DEMO MODE • SAMPLE DATA ONLY • NO ACCOUNT LINKED',
              style: GoogleFonts.dmSans(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedBanner(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.sage, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 16.0, color: AppColors.sage),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              user != null && user.email.isNotEmpty
                  ? 'PRIVATE SESSION • ${user.email.toUpperCase()}'
                  : 'AUTHENTICATED SESSION ACTIVE',
              style: GoogleFonts.dmSans(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.sage,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Greeting
  // ---------------------------------------------------------------------------

  Widget _buildGreeting(
    BuildContext context, {
    required String dateDisplay,
    required String displayName,
    required String avatarInitial,
    required bool isNarrow,
  }) {
    final titleFontSize = isNarrow ? 30.0 : 38.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateDisplay,
                style: GoogleFonts.dmSans(
                  fontSize: 10.0,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.rose,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Good morning, $displayName.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plum,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'How are you arriving today?',
                style: GoogleFonts.dmSans(
                  fontSize: 13.0,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14.0),
        // Avatar button matching Figma .avatar
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: () => _navigateTo(context, AppRoutes.profile),
            borderRadius: BorderRadius.circular(45.0),
            child: Container(
              width: 45.0,
              height: 45.0,
              decoration: const BoxDecoration(
                color: AppColors.plum,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatarInitial,
                  style: GoogleFonts.dmSans(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Five-minute Check-In Card
  // ---------------------------------------------------------------------------

  Widget _buildCheckinCard(BuildContext context, {required bool isNarrow}) {
    return Semantics(
      button: true,
      label: "Start today's check-in",
      child: InkWell(
        onTap: () => _navigateTo(context, AppRoutes.checkin),
        borderRadius: BorderRadius.circular(26.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.0),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.plum,
                Color(0xFF68475E),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.plum.withValues(alpha: 0.18),
                blurRadius: 40.0,
                offset: const Offset(0.0, 16.0),
              ),
            ],
          ),
          padding: EdgeInsets.all(isNarrow ? 22.0 : 32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        "TODAY'S MOMENT",
                        style: GoogleFonts.dmSans(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Text(
                      'Five minutes for you.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isNarrow ? 26.0 : 32.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Check in with your body, mind and daily experiences.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.0,
                        color: const Color(0xFFE4D8DF),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'About 5 minutes • Skip any optional question',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.0,
                        color: const Color(0xFFD4C7CF),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      "Start today's check-in →",
                      style: GoogleFonts.dmSans(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF2C7C7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 20.0),
                // Glowing Orb with heart icon
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                  child: const Center(
                    child: InHercueIcon(
                      icon: InHercueIconType.heart,
                      size: 29.0,
                      color: Color(0xFFEDC6C6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Section Heading
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeading({
    required String kicker,
    required String title,
    String? badgeText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker,
                style: GoogleFonts.dmSans(
                  fontSize: 10.0,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.rose,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plum,
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null) ...[
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: AppColors.line, width: 1.0),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.dmSans(
                fontSize: 10.0,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Daily Actions
  // ---------------------------------------------------------------------------

  Widget _buildDailyActions(
    BuildContext context, {
    required bool isNarrow,
    required bool isDemo,
  }) {
    final actions = [
      _DailyActionData(
        title: 'Symptom Tracker',
        subtitle: 'Log or review symptoms',
        icon: InHercueIconType.plus,
        route: AppRoutes.symptoms,
      ),
      _DailyActionData(
        title: 'Period Tracker',
        subtitle: isDemo
            ? 'Day 18 • Next period estimate in 10 days'
            : 'Track your cycle & phases',
        icon: InHercueIconType.calendar,
        route: AppRoutes.period,
      ),
      _DailyActionData(
        title: 'Alerts',
        subtitle: '2 reminders and safety guidance',
        icon: InHercueIconType.bell,
        route: AppRoutes.alerts,
        badgeCount: 2,
      ),
    ];

    if (isNarrow) {
      return Column(
        children: actions
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildDailyActionCard(context, item),
                ))
            .toList(),
      );
    }

    return Row(
      children: actions
          .map((item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildDailyActionCard(context, item),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDailyActionCard(BuildContext context, _DailyActionData item) {
    return Semantics(
      button: true,
      label: '${item.title}: ${item.subtitle}',
      child: InkWell(
        onTap: () => _navigateTo(context, item.route),
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: AppColors.line, width: 1.0),
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                child: Center(
                  child: InHercueIcon(
                    icon: item.icon,
                    size: 20.0,
                    color: AppColors.plum,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.plum,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              // Trailing: Badge or Chevron
              if (item.badgeCount != null)
                Container(
                  width: 23.0,
                  height: 23.0,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${item.badgeCount}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                const InHercueIcon(
                  icon: InHercueIconType.chevron,
                  size: 16.0,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Feature Grid
  // ---------------------------------------------------------------------------

  Widget _buildFeatureGrid(
    BuildContext context, {
    required bool isWide,
    required bool isNarrow,
    required bool isDemo,
  }) {
    final features = [
      _FeatureCardData(
        title: 'Physical Health',
        text: 'Track symptoms & energy',
        icon: InHercueIconType.heart,
        bgColor: AppColors.roseLight,
        route: AppRoutes.physical,
      ),
      _FeatureCardData(
        title: 'Mental Wellness',
        text: 'Mood, stress & reflection',
        icon: InHercueIconType.moon,
        bgColor: const Color(0xFFE8E0E6), // Plum pastel from Figma
        route: AppRoutes.mental,
      ),
      _FeatureCardData(
        title: 'Period Tracker',
        text: isDemo ? 'Cycle day 18 • 10 days to go' : 'Cycle day -- • Tap to log',
        icon: InHercueIconType.calendar,
        bgColor: AppColors.sageLight,
        route: AppRoutes.period,
      ),
      _FeatureCardData(
        title: 'Health Patterns',
        text: 'See trends across your wellbeing',
        icon: InHercueIconType.chart,
        bgColor: AppColors.goldLight,
        route: AppRoutes.patterns,
      ),
    ];

    if (isWide) {
      // 4 columns on wide screens
      return Row(
        children: features
            .map((item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: _buildFeatureCard(context, item),
                  ),
                ))
            .toList(),
      );
    }

    // 2x2 grid on medium & mobile
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFeatureCard(context, features[0])),
            const SizedBox(width: 12.0),
            Expanded(child: _buildFeatureCard(context, features[1])),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(child: _buildFeatureCard(context, features[2])),
            const SizedBox(width: 12.0),
            Expanded(child: _buildFeatureCard(context, features[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureCardData item) {
    return Semantics(
      button: true,
      label: '${item.title}: ${item.text}',
      child: InkWell(
        onTap: () => _navigateTo(context, item.route),
        borderRadius: BorderRadius.circular(19.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 154.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: item.bgColor,
            borderRadius: BorderRadius.circular(19.0),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 39.0,
                    height: 39.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    child: Center(
                      child: InHercueIcon(
                        icon: item.icon,
                        size: 20.0,
                        color: AppColors.plum,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    item.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.plum,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    item.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 12.0,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              const Positioned(
                top: 0.0,
                right: 0.0,
                child: InHercueIcon(
                  icon: InHercueIconType.chevron,
                  size: 16.0,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Botanical Wellness Note Card
  // ---------------------------------------------------------------------------

  Widget _buildWellnessCard(BuildContext context, {required bool isNarrow}) {
    return Semantics(
      button: true,
      label: "Read today's wellness note",
      child: InkWell(
        onTap: () => _navigateTo(context, AppRoutes.guidance),
        borderRadius: BorderRadius.circular(22.0),
        child: Container(
          padding: const EdgeInsets.all(26.0),
          decoration: BoxDecoration(
            color: AppColors.sage,
            borderRadius: BorderRadius.circular(22.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isNarrow) ...[
                Text(
                  '❦',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 54.0,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 20.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELLNESS NOTE',
                      style: GoogleFonts.dmSans(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Your body isn't asking for perfection.",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isNarrow ? 20.0 : 23.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "It's asking to be heard. Explore gentle guidance for restorative sleep.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Text(
                      "Read today's note →",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Horizontal Resource Cards
  // ---------------------------------------------------------------------------

  Widget _buildHorizontalCards(BuildContext context, {required double screenWidth}) {
    final items = [
      _ResourceCardData(
        title: 'Self-Care Studio',
        subtitle: '3-minute reset',
        icon: InHercueIconType.sparkle,
        route: AppRoutes.selfcare,
      ),
      _ResourceCardData(
        title: 'Myth vs Fact',
        subtitle: 'Know your body',
        icon: InHercueIconType.learn,
        route: AppRoutes.myths,
      ),
      _ResourceCardData(
        title: 'Find a Doctor',
        subtitle: 'Care that listens',
        icon: InHercueIconType.search,
        route: AppRoutes.doctors,
      ),
      _ResourceCardData(
        title: 'Health History',
        subtitle: 'Demo trends & entries',
        icon: InHercueIconType.chart,
        route: AppRoutes.records,
      ),
      _ResourceCardData(
        title: 'Health Reports',
        subtitle: 'Preview and export',
        icon: InHercueIconType.records,
        route: AppRoutes.reports,
      ),
      _ResourceCardData(
        title: 'Health Passport',
        subtitle: 'Portable overview',
        icon: InHercueIconType.shield,
        route: AppRoutes.passport,
      ),
      _ResourceCardData(
        title: 'Community',
        subtitle: 'Demo peer discussions',
        icon: InHercueIconType.user,
        route: AppRoutes.community,
      ),
    ];

    if (screenWidth < 520.0) {
      // 1 column on mobile screens
      return Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: _buildHorizontalCard(context, item, isWideView: false),
                ))
            .toList(),
      );
    } else if (screenWidth < 760.0) {
      // 2 columns on tablet
      final rows = <Widget>[];
      for (var i = 0; i < items.length; i += 2) {
        final first = items[i];
        final second = (i + 1 < items.length) ? items[i + 1] : null;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(child: _buildHorizontalCard(context, first)),
                const SizedBox(width: 12.0),
                if (second != null)
                  Expanded(child: _buildHorizontalCard(context, second))
                else
                  const Spacer(),
              ],
            ),
          ),
        );
      }
      return Column(children: rows);
    } else {
      // 3 columns on desktop
      final rows = <Widget>[];
      for (var i = 0; i < items.length; i += 3) {
        final a = items[i];
        final b = (i + 1 < items.length) ? items[i + 1] : null;
        final c = (i + 2 < items.length) ? items[i + 2] : null;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(child: _buildHorizontalCard(context, a)),
                const SizedBox(width: 12.0),
                if (b != null)
                  Expanded(child: _buildHorizontalCard(context, b))
                else
                  const Spacer(),
                const SizedBox(width: 12.0),
                if (c != null)
                  Expanded(child: _buildHorizontalCard(context, c))
                else
                  const Spacer(),
              ],
            ),
          ),
        );
      }
      return Column(children: rows);
    }
  }

  Widget _buildHorizontalCard(
    BuildContext context,
    _ResourceCardData item, {
    bool isWideView = true,
  }) {
    return Semantics(
      button: true,
      label: '${item.title}: ${item.subtitle}',
      child: InkWell(
        onTap: () => _navigateTo(context, item.route),
        borderRadius: BorderRadius.circular(17.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88.0),
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(17.0),
            border: Border.all(color: AppColors.line, width: 1.0),
          ),
          child: isWideView
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InHercueIcon(
                      icon: item.icon,
                      size: 22.0,
                      color: AppColors.plum,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      item.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.0,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    InHercueIcon(
                      icon: item.icon,
                      size: 22.0,
                      color: AppColors.plum,
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.plum,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            item.subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 12.0,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const InHercueIcon(
                      icon: InHercueIconType.chevron,
                      size: 16.0,
                      color: AppColors.muted,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Data Classes
// ---------------------------------------------------------------------------

class _DailyActionData {
  final String title;
  final String subtitle;
  final InHercueIconType icon;
  final String route;
  final int? badgeCount;

  const _DailyActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.badgeCount,
  });
}

class _FeatureCardData {
  final String title;
  final String text;
  final InHercueIconType icon;
  final Color bgColor;
  final String route;

  const _FeatureCardData({
    required this.title,
    required this.text,
    required this.icon,
    required this.bgColor,
    required this.route,
  });
}

class _ResourceCardData {
  final String title;
  final String subtitle;
  final InHercueIconType icon;
  final String route;

  const _ResourceCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
