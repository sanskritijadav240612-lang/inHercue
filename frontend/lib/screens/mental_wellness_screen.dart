import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';

/// Mental Wellness screen for inHERcue.
/// Directly mirrors `MentalWellness({ go })` from the React reference:
/// - Topbar with back, urgent, and alerts navigation
/// - Dual column layout:
///   1. Today’s Reflection form (mood, stress, sleep & energy, private journal, save button)
///   2. inHERcue Support Assistant AI chat panel (plum container, canned responses, suggestion pills, send input, urgent resources link)
/// - Bottom navigation (Home active)
class MentalWellnessScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MentalWellnessScreen({
    super.key,
    this.onBack,
  });

  @override
  State<MentalWellnessScreen> createState() => _MentalWellnessScreenState();
}

class _MentalWellnessScreenState extends State<MentalWellnessScreen> {
  String _mood = '';
  String _stress = '';
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _journalController = TextEditingController();
  bool _saved = false;

  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text':
          'Hello, I’m the inHERcue Support Assistant — AI demo. I can offer predefined reflection prompts and point to resources. I’m not a therapist or diagnostic service.'
    }
  ];
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _sleepController.dispose();
    _journalController.dispose();
    _chatInputController.dispose();
    _scrollController.dispose();
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

  void _sendMessage([String? textOverride]) {
    final text = textOverride ?? _chatInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': 'You: $text'});
      final lower = text.toLowerCase();
      if (lower.contains('overwhelm')) {
        _messages.add({
          'sender': 'assistant',
          'text':
              'Demo assistant: It sounds like a lot is competing for your attention. Would a short grounding activity or support resource feel more useful?'
        });
      } else {
        _messages.add({
          'sender': 'assistant',
          'text':
              'Demo assistant: Thank you for sharing. You might reflect on what feels most important right now, or choose a gentle activity.'
        });
      }
    });

    _chatInputController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
              title: 'Mental wellness',
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
                        // Hub header
                        Text(
                          'PRIVATE REFLECTION',
                          style: AppTextStyles.kicker,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'How are you, really?',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Track your emotional wellbeing and choose support at your pace.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.0,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Form & Chat Panel
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720.0;
                            final formWidget = _buildReflectionForm(context);
                            final chatWidget = _buildChatPanel(context);

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: formWidget),
                                  const SizedBox(width: 20.0),
                                  Expanded(child: chatWidget),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  formWidget,
                                  const SizedBox(height: 20.0),
                                  chatWidget,
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
              currentDestination: InHercueNavDestination.home,
              onDestinationSelected: (dest) => _navigateDestination(context, dest),
              onNewEntry: () => Navigator.of(context).pushNamed(AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionForm(BuildContext context) {
    return Container(
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
            'Today’s reflection',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
            ),
          ),
          const SizedBox(height: 16.0),

          Text('Mood', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.plum)),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            initialValue: _mood.isNotEmpty ? _mood : null,
            hint: const Text('Choose'),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0), borderSide: const BorderSide(color: AppColors.line)),
            ),
            items: const [
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Okay', child: Text('Okay')),
              DropdownMenuItem(value: 'Good', child: Text('Good')),
            ],
            onChanged: (v) => setState(() => _mood = v ?? ''),
          ),
          const SizedBox(height: 14.0),

          Text('Stress', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.plum)),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            initialValue: _stress.isNotEmpty ? _stress : null,
            hint: const Text('Choose'),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0), borderSide: const BorderSide(color: AppColors.line)),
            ),
            items: const [
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
              DropdownMenuItem(value: 'High', child: Text('High')),
            ],
            onChanged: (v) => setState(() => _stress = v ?? ''),
          ),
          const SizedBox(height: 14.0),

          Text('Sleep and energy', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.plum)),
          const SizedBox(height: 6.0),
          TextFormField(
            controller: _sleepController,
            decoration: InputDecoration(
              hintText: 'e.g. Restful sleep, steady energy',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0), borderSide: const BorderSide(color: AppColors.line)),
            ),
          ),
          const SizedBox(height: 14.0),

          Text('Private journal', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.plum)),
          const SizedBox(height: 6.0),
          TextFormField(
            controller: _journalController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Optional reflection',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0), borderSide: const BorderSide(color: AppColors.line)),
            ),
          ),
          const SizedBox(height: 20.0),

          PrimaryButton(
            label: _saved ? 'Reflection saved' : 'Save reflection',
            onPressed: (_mood.isNotEmpty && _stress.isNotEmpty)
                ? () {
                    setState(() => _saved = true);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: AppColors.plum,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'PREDEFINED DEMO RESPONSES',
                  style: GoogleFonts.dmSans(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            'inHERcue Support Assistant — AI',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Not a therapist or diagnostic service. For immediate safety concerns, use Urgent Help now.',
            style: GoogleFonts.dmSans(
              fontSize: 12.0,
              color: const Color(0xFFE7DCE3),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16.0),

          // Messages box
          Container(
            height: 220.0,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.rose : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    constraints: const BoxConstraints(maxWidth: 320.0),
                    child: Text(
                      msg['text']!,
                      style: GoogleFonts.dmSans(fontSize: 13.0, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14.0),

          // Suggestion pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'I feel overwhelmed',
                'Show a grounding activity',
                'Find support resources',
              ].map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(p),
                    backgroundColor: Colors.transparent,
                    labelStyle: GoogleFonts.dmSans(color: Colors.white, fontSize: 11.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    onPressed: () => _sendMessage(p),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12.0),

          // Input + Send
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  style: GoogleFonts.dmSans(color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Write a message',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () => _sendMessage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
            child: Text(
              'Open safety-support resources',
              style: GoogleFonts.dmSans(
                color: const Color(0xFFF3CBCF),
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFF3CBCF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
