import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// Community peer support screen for inHERcue.
/// Directly mirrors `Community({ go })` from the React reference:
/// - Topbar with back, urgent, and alerts navigation
/// - Topic filter pills (All, Menstrual health, PCOS / hormonal health, Mental wellness, etc.)
/// - "Create post" button opening post composition form
/// - Community discussion feed with interactive Bookmark, Report, and Reply actions
/// - Report confirmation notice
/// - Bottom navigation (Learn active)
class CommunityScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CommunityScreen({
    super.key,
    this.onBack,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedTopic = 'All';
  bool _creating = false;
  String _postText = '';
  bool _pseudonym = false;
  bool _posted = false;
  String _bookmarked = '';
  String _reported = '';

  final TextEditingController _textController = TextEditingController();

  static const List<String> _topics = [
    'All',
    'Menstrual health',
    'PCOS / hormonal health',
    'Mental wellness',
    'Pregnancy / postpartum',
    'Menopause',
    'General wellbeing',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (_creating) {
      setState(() => _creating = false);
    } else if (widget.onBack != null) {
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
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
              title: 'Community',
              onBack: () => _handleBack(context),
              onUrgent: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
              onAlerts: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'DEMO COMMUNITY',
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Shared experiences, respectfully held.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Community discussion is not medical advice. Your private health records are never posted here.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Toolbar: Topics filter & Create post button
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _topics.map((t) {
                                  final isSelected = _selectedTopic == t;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: FilterChip(
                                      label: Text(t),
                                      selected: isSelected,
                                      onSelected: (_) => setState(() => _selectedTopic = t),
                                      backgroundColor: AppColors.paper,
                                      selectedColor: AppColors.plum,
                                      labelStyle: GoogleFonts.dmSans(
                                        color: isSelected ? Colors.white : AppColors.ink,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 13.0,
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
                            ElevatedButton(
                              onPressed: () => setState(() => _creating = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.plum,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
                              ),
                              child: Text('Create post', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),

                        // Create Post Form
                        if (_creating)
                          Container(
                            padding: const EdgeInsets.all(22.0),
                            margin: const EdgeInsets.only(bottom: 24.0),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Create a demo post',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                Text('Post', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.plum)),
                                const SizedBox(height: 6.0),
                                TextFormField(
                                  controller: _textController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Share an experience or ask the community',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0), borderSide: const BorderSide(color: AppColors.line)),
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _pseudonym,
                                      activeColor: AppColors.plum,
                                      onChanged: (v) => setState(() => _pseudonym = v ?? false),
                                    ),
                                    Text('Post with a pseudonym', style: GoogleFonts.dmSans(fontSize: 13.0, color: AppColors.ink)),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SecondaryButton(
                                        label: 'Cancel',
                                        onPressed: () => setState(() => _creating = false),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      flex: 2,
                                      child: PrimaryButton(
                                        label: 'Preview & post',
                                        onPressed: () {
                                          if (_textController.text.trim().isNotEmpty) {
                                            setState(() {
                                              _postText = _textController.text.trim();
                                              _posted = true;
                                              _creating = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Feed
                        if (_posted)
                          _buildPostCard(
                            kicker: 'JUST NOW · ${_selectedTopic.toUpperCase()}',
                            title: 'Your demo post',
                            body: _postText,
                            id: 'user_post',
                          ),

                        _buildPostCard(
                          kicker: 'DEMO POST · ${_selectedTopic == 'All' ? 'GENERAL WELLBEING' : _selectedTopic.toUpperCase()}',
                          title: 'Cycle day routines',
                          body: 'What helps you make room for rest on lower-energy days?',
                          id: 'cycle_post',
                        ),

                        _buildPostCard(
                          kicker: 'DEMO POST · ${_selectedTopic == 'All' ? 'GENERAL WELLBEING' : _selectedTopic.toUpperCase()}',
                          title: 'A small grounding win',
                          body: 'I tried the 5–4–3–2–1 activity today and appreciated having a pause.',
                          id: 'grounding_post',
                        ),

                        if (_reported.isNotEmpty) ...[
                          const SizedBox(height: 16.0),
                          Container(
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: AppColors.sageLight,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              'Report received in this demo. No external moderation service was contacted.',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF3D6645),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ],

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

  Widget _buildPostCard({
    required String kicker,
    required String title,
    required String body,
    required String id,
  }) {
    final isBookmarked = _bookmarked == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: GoogleFonts.dmSans(
              fontSize: 9.0,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
              color: AppColors.rose,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            body,
            style: GoogleFonts.dmSans(
              fontSize: 14.0,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _bookmarked = isBookmarked ? '' : id),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.ivory,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                ),
                child: Text(
                  isBookmarked ? 'Saved' : 'Bookmark',
                  style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.plum),
                ),
              ),
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: () => setState(() => _reported = id),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.ivory,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                ),
                child: Text(
                  'Report',
                  style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.plum),
                ),
              ),
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _creating = true;
                    _textController.text = 'Replying to: $title';
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.ivory,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                ),
                child: Text(
                  'Reply',
                  style: GoogleFonts.dmSans(fontSize: 12.0, color: AppColors.plum),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
