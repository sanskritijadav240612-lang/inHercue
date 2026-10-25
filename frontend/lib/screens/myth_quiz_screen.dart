import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/navigation/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/in_hercue_bottom_nav.dart';
import '../widgets/in_hercue_icon.dart';
import '../widgets/in_hercue_topbar.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

/// Myth vs Fact interactive quiz screen for inHERcue.
/// Directly mirrors `MythQuiz({ go })` from the React reference:
/// - 7 clinical categories: Period Myths, PCOS & Hormonal Health, Pregnancy & Fertility, Mental Wellness, Nutrition & Self-Care, Menopause, General Women's Health
/// - Progress tracking per category
/// - Interactive Myth vs Fact question selector with "I'm not sure" option
/// - Clinician-validated citations and feedback cards
/// - Category score review and completion screens
/// - Bottom navigation (Learn active)
class MythQuizScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MythQuizScreen({super.key, this.onBack});

  @override
  State<MythQuizScreen> createState() => _MythQuizScreenState();
}

class _MythQuizScreenState extends State<MythQuizScreen> {
  int? _selectedCategory;
  int _questionIndex = 0;
  String _currentAnswer = '';
  bool _revealed = false;
  bool _finished = false;
  final Map<String, String> _userAnswers = {};

  static const List<Map<String, dynamic>> _quizData = [
    {
      'name': 'Period Myths',
      'description': 'Cycles, bleeding and period comfort.',
      'questions': [
        [
          'Severe period pain is something everyone must simply tolerate.',
          'Myth',
          'Pain that disrupts daily activities deserves discussion with a qualified clinician.',
          'ACOG — Dysmenorrhea: Painful Periods',
        ],
        [
          'Menstrual cycles can vary in length from person to person.',
          'Fact',
          'Cycle length varies, and an individual cycle can also change over time.',
          'Office on Women’s Health — Menstrual Cycle',
        ],
        [
          'Eating sour foods during your period is harmful.',
          'Myth',
          'Sour foods are generally safe during menstruation. Personal food tolerance can vary.',
          'NHS — Periods and nutrition guidance',
        ],
        [
          'Period products should be changed according to their instructions and your flow.',
          'Fact',
          'Regular changes support comfort and hygiene; follow product guidance.',
          'NHS — Periods and sanitary products',
        ],
      ],
    },
    {
      'name': 'PCOS & Hormonal Health',
      'description': 'Common hormonal-health claims.',
      'questions': [
        [
          'PCOS can affect people differently.',
          'Fact',
          'Symptoms and their impact vary, so care should be individualized.',
          'WHO — Polycystic ovary syndrome',
        ],
        [
          'A single symptom is enough to diagnose PCOS.',
          'Myth',
          'Diagnosis requires clinical assessment and multiple findings.',
          'WHO — Polycystic ovary syndrome',
        ],
        [
          'PCOS has only one management option.',
          'Myth',
          'Options depend on symptoms, needs and personal goals.',
          'NHS — Polycystic ovary syndrome',
        ],
        [
          'PCOS can affect menstrual cycles.',
          'Fact',
          'Irregular or absent periods are among the possible features of PCOS.',
          'WHO — Polycystic ovary syndrome',
        ],
      ],
    },
    {
      'name': 'Pregnancy & Fertility',
      'description': 'Careful reproductive-health basics.',
      'questions': [
        [
          'Pregnancy tests are most reliable when used as instructed.',
          'Fact',
          'Timing and following instructions affect accuracy.',
          'NHS — Doing a pregnancy test',
        ],
        [
          'Fertility is identical for every person of the same age.',
          'Myth',
          'Age is one factor, but fertility differs between individuals.',
          'ACOG — Evaluating Infertility',
        ],
        [
          'A missed period always confirms pregnancy.',
          'Myth',
          'Periods can be late for several reasons.',
          'NHS — Missed or late periods',
        ],
        [
          'Preconception health questions can be discussed with a clinician.',
          'Fact',
          'A clinician can provide guidance based on individual health and medicines.',
          'Office on Women’s Health — Preconception health',
        ],
      ],
    },
    {
      'name': 'Mental Wellness',
      'description': 'Mood, stress and getting support.',
      'questions': [
        [
          'Seeking mental-health support is a sign of weakness.',
          'Myth',
          'Reaching out is a practical health action, not a personal failure.',
          'WHO — Mental health',
        ],
        [
          'Sleep can influence mood and stress.',
          'Fact',
          'Sleep and emotional wellbeing are related, though experiences vary.',
          'NIH — Sleep Health',
        ],
        [
          'A mood score alone can rule out a crisis.',
          'Myth',
          'A score cannot determine safety. Immediate danger needs human support.',
          'WHO — Mental health in emergencies',
        ],
        [
          'Grounding exercises replace professional mental-health care.',
          'Myth',
          'Grounding may support coping but does not replace care when it is needed.',
          'NHS — Mental wellbeing',
        ],
      ],
    },
    {
      'name': 'Nutrition & Self-Care',
      'description': 'Wellbeing without quick fixes.',
      'questions': [
        [
          'One food can cure every health concern.',
          'Myth',
          'No single food replaces individualized healthcare.',
          'WHO — Healthy diet',
        ],
        [
          'Hydration needs can differ with climate and activity.',
          'Fact',
          'Fluid needs are influenced by personal and environmental factors.',
          'NHS — Water, drinks and hydration',
        ],
        [
          'Self-care should replace urgent medical attention.',
          'Myth',
          'Self-care is not a substitute for urgent or professional care.',
          'NHS — Getting medical help',
        ],
        [
          'Small, sustainable habit changes can support wellbeing.',
          'Fact',
          'Realistic routines can be easier to maintain than drastic short-term changes.',
          'WHO — Healthy diet',
        ],
      ],
    },
    {
      'name': 'Menopause',
      'description': 'Changes, symptoms and support.',
      'questions': [
        [
          'Menopause experiences are the same for everyone.',
          'Myth',
          'The type, intensity and duration of symptoms vary widely.',
          'WHO — Menopause',
        ],
        [
          'Menopause can affect sleep and mood.',
          'Fact',
          'Sleep and mood changes are symptoms some people experience.',
          'WHO — Menopause',
        ],
        [
          'Support is available for bothersome symptoms.',
          'Fact',
          'A clinician can discuss suitable options.',
          'NHS — Menopause',
        ],
        [
          'Menopause is diagnosed from one universal laboratory test.',
          'Myth',
          'Assessment depends on age, symptoms and individual circumstances.',
          'NHS — Menopause diagnosis',
        ],
      ],
    },
    {
      'name': 'General Women’s Health',
      'description': 'Everyday health information.',
      'questions': [
        [
          'One symptom log can confirm a diagnosis.',
          'Myth',
          'A log can support a conversation, but cannot diagnose a condition.',
          'MedlinePlus — Talking With Your Doctor',
        ],
        [
          'Preventive-care needs can change over time.',
          'Fact',
          'Recommended care depends on age, history and individual risk.',
          'Office on Women’s Health — Health screenings',
        ],
        [
          'Sudden severe symptoms should wait for the next check-in.',
          'Myth',
          'Severe or alarming symptoms may require urgent assessment.',
          'NHS — When to get medical help',
        ],
        [
          'Preparing questions can help a healthcare conversation.',
          'Fact',
          'Writing down priorities can help you cover what matters during an appointment.',
          'MedlinePlus — Talking With Your Doctor',
        ],
      ],
    },
  ];

  void _handleBack() {
    if (_selectedCategory == null) {
      if (widget.onBack != null) {
        widget.onBack!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.learn);
      }
    } else {
      setState(() {
        _selectedCategory = null;
        _finished = false;
        _currentAnswer = '';
        _revealed = false;
      });
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
    final hasCategory = _selectedCategory != null;
    final cat = hasCategory ? _quizData[_selectedCategory!] : null;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            InHercueTopbar(
              title: hasCategory ? cat!['name'] as String : 'Myth vs Fact',
              onBack: _handleBack,
              onUrgent: () => Navigator.of(context).pushNamed(AppRoutes.urgent),
              onAlerts: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860.0),
                    child: !hasCategory
                        ? _buildCategorySelectionView()
                        : (_finished
                              ? _buildScoreView(cat!)
                              : _buildQuestionView(cat!)),
                  ),
                ),
              ),
            ),

            InHercueBottomNav(
              currentDestination: InHercueNavDestination.learn,
              onDestinationSelected: (dest) =>
                  _navigateDestination(context, dest),
              onNewEntry: () =>
                  Navigator.of(context).pushNamed(AppRoutes.entry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('LEARN AT YOUR PACE', style: AppTextStyles.kicker),
        const SizedBox(height: 8.0),
        Text(
          'Let’s bust some myths!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 34.0,
            fontWeight: FontWeight.w600,
            color: AppColors.plum,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Explore what’s fact and fiction about women’s health.',
          style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),

        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth >= 600.0 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 14.0,
                mainAxisSpacing: 14.0,
                childAspectRatio: crossCount == 1 ? 1.6 : 1.35,
              ),
              itemCount: _quizData.length,
              itemBuilder: (context, idx) {
                final c = _quizData[idx];
                final qList = c['questions'] as List<List<String>>;
                final doneCount = qList.where((q) {
                  final key = '${c['name']}-${qList.indexOf(q)}';
                  return _userAnswers.containsKey(key);
                }).length;

                final bgColors = [
                  AppColors.roseLight,
                  AppColors.plumLight,
                  AppColors.sageLight,
                  AppColors.goldLight,
                ];
                final cardBg = bgColors[idx % bgColors.length];

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = idx;
                      _questionIndex = 0;
                      _currentAnswer = '';
                      _revealed = false;
                      _finished = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(22.0),
                  child: Container(
                    padding: const EdgeInsets.all(22.0),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: InHercueIcon(
                              icon: idx.isEven
                                  ? InHercueIconType.sparkle
                                  : InHercueIconType.learn,
                              size: 20.0,
                              color: AppColors.plum,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          '${qList.length} QUESTIONS',
                          style: GoogleFonts.dmSans(
                            fontSize: 10.0,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          c['name'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Expanded(
                          child: Text(
                            c['description'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.0,
                              color: AppColors.muted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Container(
                            height: 4.0,
                            color: Colors.white.withValues(alpha: 0.6),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final progress = (doneCount / qList.length)
                                    .clamp(0.0, 1.0);
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    width: constraints.maxWidth * progress,
                                    height: 4.0,
                                    color: AppColors.plum,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          doneCount > 0
                              ? '$doneCount of ${qList.length} complete →'
                              : 'Start category →',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.plum,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 32.0),
      ],
    );
  }

  Widget _buildQuestionView(Map<String, dynamic> cat) {
    final qList = cat['questions'] as List<List<String>>;
    final q = qList[_questionIndex];
    final key = '${cat['name']}-$_questionIndex';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_questionIndex + 1}',
                style: GoogleFonts.dmSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.muted,
                ),
              ),
              Text(
                '${_questionIndex + 1} of ${qList.length}',
                style: GoogleFonts.dmSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: (_questionIndex + 1) / qList.length,
              backgroundColor: AppColors.line,
              color: AppColors.rose,
              minHeight: 4.0,
            ),
          ),
          const SizedBox(height: 24.0),

          Text(
            (cat['name'] as String).toUpperCase(),
            style: AppTextStyles.kicker,
          ),
          const SizedBox(height: 10.0),
          Text(
            q[0],
            style: GoogleFonts.playfairDisplay(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28.0),

          // Myth vs Fact Buttons
          Row(
            children: ['Myth', 'Fact'].map((choice) {
              final isSelected = _currentAnswer == choice;
              final isCorrectAnswer = _revealed && choice == q[1];

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: InkWell(
                    onTap: _revealed
                        ? null
                        : () => setState(() => _currentAnswer = choice),
                    borderRadius: BorderRadius.circular(18.0),
                    child: Container(
                      height: 88.0,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.plum : AppColors.paper,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: isCorrectAnswer
                              ? AppColors.sage
                              : (isSelected ? AppColors.plum : AppColors.line),
                          width: isCorrectAnswer ? 2.5 : 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        choice,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.plum,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20.0),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: !_revealed
                ? KeyedSubtree(
                    key: const ValueKey('unrevealed'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                setState(() => _currentAnswer = "I'm not sure"),
                            child: Text(
                              'I’m not sure',
                              style: GoogleFonts.dmSans(
                                fontSize: 13.0,
                                color: AppColors.plum,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        PrimaryButton(
                          label: 'Submit & reveal answer',
                          onPressed: _currentAnswer.isNotEmpty
                              ? () {
                                  setState(() {
                                    _revealed = true;
                                    _userAnswers[key] = _currentAnswer;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('revealed'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Feedback Card
                        Container(
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: _currentAnswer == q[1]
                                ? AppColors.sageLight
                                : AppColors.goldLight,
                            borderRadius: BorderRadius.circular(17.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_currentAnswer == q[1] ? 'Correct' : 'Not quite'} — this is ${q[1]}.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                q[2],
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.0,
                                  color: AppColors.ink,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                'Reference: ${q[3]}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.0,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Back to categories',
                                onPressed: () =>
                                    setState(() => _selectedCategory = null),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              flex: 2,
                              child: PrimaryButton(
                                label: _questionIndex == qList.length - 1
                                    ? 'View results'
                                    : 'Next question',
                                trailingIcon: const Text(
                                  '→',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: () {
                                  if (_questionIndex == qList.length - 1) {
                                    setState(() => _finished = true);
                                  } else {
                                    setState(() {
                                      _questionIndex++;
                                      final nextKey =
                                          '${cat['name']}-$_questionIndex';
                                      _currentAnswer =
                                          _userAnswers[nextKey] ?? '';
                                      _revealed = _userAnswers.containsKey(
                                        nextKey,
                                      );
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
          ),
        ],
      ),
    );
  }

  Widget _buildScoreView(Map<String, dynamic> cat) {
    final qList = cat['questions'] as List<List<String>>;
    final correctScore = qList.where((q) {
      final key = '${cat['name']}-${qList.indexOf(q)}';
      return _userAnswers[key] == q[1];
    }).length;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520.0),
      child: Column(
        children: [
          Container(
            width: 78.0,
            height: 78.0,
            decoration: const BoxDecoration(
              color: AppColors.roseLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: InHercueIcon(
                icon: InHercueIconType.learn,
                size: 34.0,
                color: AppColors.plum,
              ),
            ),
          ),
          const SizedBox(height: 18.0),
          Text('CATEGORY COMPLETE', style: AppTextStyles.kicker),
          const SizedBox(height: 8.0),
          Text(
            '$correctScore of ${qList.length} correct',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Revisiting an answer won’t add to your score.',
            style: GoogleFonts.dmSans(fontSize: 14.0, color: AppColors.muted),
          ),
          const SizedBox(height: 28.0),

          SecondaryButton(
            label: 'Review answers',
            onPressed: () {
              setState(() {
                _questionIndex = 0;
                _finished = false;
                final key = '${cat['name']}-0';
                _currentAnswer = _userAnswers[key] ?? '';
                _revealed = true;
              });
            },
          ),
          const SizedBox(height: 12.0),
          PrimaryButton(
            label: 'Try another category',
            onPressed: () => setState(() => _selectedCategory = null),
          ),
        ],
      ),
    );
  }
}
