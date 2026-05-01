import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'travel_shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AppUser user;

  const OnboardingScreen({super.key, required this.user});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _saving = false;

  final Set<TravelerInterest> _selectedInterests = {
    TravelerInterest.mixed,
  };
  BudgetPreference _budget = BudgetPreference.medium;
  TravelStyle _style = TravelStyle.exploreEverything;
  FoodPreference _food = FoodPreference.both;
  TravelMood _mood = TravelMood.chill;

  TravelerInterest get _primaryInterest {
    if (_selectedInterests.isEmpty) {
      return TravelerInterest.mixed;
    }
    if (_selectedInterests.contains(TravelerInterest.mixed) &&
        _selectedInterests.length == 1) {
      return TravelerInterest.mixed;
    }
    return _selectedInterests.firstWhere(
      (value) => value != TravelerInterest.mixed,
      orElse: () => TravelerInterest.mixed,
    );
  }

  List<TravelerInterest> get _extraInterests {
    return _selectedInterests
        .where((value) => value != _primaryInterest)
        .toList(growable: false);
  }

  void _toggleInterest(TravelerInterest value) {
    setState(() {
      if (value == TravelerInterest.mixed) {
        _selectedInterests
          ..clear()
          ..add(TravelerInterest.mixed);
        return;
      }

      _selectedInterests.remove(TravelerInterest.mixed);
      if (_selectedInterests.contains(value)) {
        _selectedInterests.remove(value);
      } else if (_selectedInterests.length < 3) {
        _selectedInterests.add(value);
      }

      if (_selectedInterests.isEmpty) {
        _selectedInterests.add(TravelerInterest.mixed);
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final updated = await AuthService.instance.completeOnboarding(
        userId: widget.user.id,
        preferences: TravelerPreferences(
          interest: _primaryInterest,
          extraInterests: _extraInterests,
          budget: _budget,
          style: _style,
          food: _food,
          mood: _mood,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TravelShellScreen(user: updated)),
        (_) => false,
      );
    } on AuthFlowException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _MultiInterestStep(
        title: 'What type of traveler are you?',
        subtitle:
            'Pick up to 3 interests. We will use them together for routes, recommendations, and AI guidance.',
        options: TravelerInterest.values,
        selected: _selectedInterests,
        labelBuilder: TravelerPreferences.labelForInterest,
        iconBuilder: (value) {
          switch (value) {
            case TravelerInterest.beach:
              return Icons.beach_access;
            case TravelerInterest.waterfalls:
              return Icons.waterfall_chart;
            case TravelerInterest.hiking:
              return Icons.terrain;
            case TravelerInterest.culture:
              return Icons.temple_buddhist;
            case TravelerInterest.mixed:
              return Icons.travel_explore;
          }
        },
        onSelected: _toggleInterest,
      ),
      _QuestionStep<BudgetPreference>(
        title: 'Budget preference?',
        subtitle:
            'This changes transport, stay style, and how aggressively the app filters options.',
        options: BudgetPreference.values,
        selected: _budget,
        labelBuilder: TravelerPreferences.labelForBudget,
        iconBuilder: (value) {
          switch (value) {
            case BudgetPreference.low:
              return Icons.wallet_outlined;
            case BudgetPreference.medium:
              return Icons.account_balance_wallet_outlined;
            case BudgetPreference.luxury:
              return Icons.diamond_outlined;
          }
        },
        onSelected: (value) => setState(() => _budget = value),
      ),
      _QuestionStep<TravelStyle>(
        title: 'Travel style?',
        subtitle: 'Choose the pacing you want when the app builds a route for you.',
        options: TravelStyle.values,
        selected: _style,
        labelBuilder: TravelerPreferences.labelForStyle,
        iconBuilder: (value) {
          switch (value) {
            case TravelStyle.relax:
              return Icons.spa_outlined;
            case TravelStyle.adventure:
              return Icons.hiking;
            case TravelStyle.exploreEverything:
              return Icons.explore;
          }
        },
        onSelected: (value) => setState(() => _style = value),
      ),
      _QuestionStep<FoodPreference>(
        title: 'Food preference?',
        subtitle: 'We will personalize dining stops and local-safe suggestions around this.',
        options: FoodPreference.values,
        selected: _food,
        labelBuilder: TravelerPreferences.labelForFood,
        iconBuilder: (value) {
          switch (value) {
            case FoodPreference.local:
              return Icons.restaurant;
            case FoodPreference.international:
              return Icons.public;
            case FoodPreference.both:
              return Icons.local_dining;
          }
        },
        onSelected: (value) => setState(() => _food = value),
      ),
      _QuestionStep<TravelMood>(
        title: 'What mood should guide the app?',
        subtitle: 'This powers the Travel Mood Engine for visuals, suggestions, and your day plan.',
        options: TravelMood.values,
        selected: _mood,
        labelBuilder: TravelerPreferences.labelForMood,
        iconBuilder: (value) {
          switch (value) {
            case TravelMood.chill:
              return Icons.deck_outlined;
            case TravelMood.adventure:
              return Icons.bolt;
            case TravelMood.luxury:
              return Icons.auto_awesome;
            case TravelMood.culture:
              return Icons.account_balance;
          }
        },
        onSelected: (value) => setState(() => _mood = value),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your travel profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This takes less than a minute and makes the app feel personal from the first screen.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (_step + 1) / pages.length,
                  minHeight: 10,
                  backgroundColor: Colors.black12,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: pages[_step],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => setState(() => _step--),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.midnight,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _saving
                          ? null
                          : _step == pages.length - 1
                              ? _finish
                              : () => setState(() => _step++),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.3),
                            )
                          : Text(_step == pages.length - 1 ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionStep<T extends Enum> extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<T> options;
  final T selected;
  final String Function(T value) labelBuilder;
  final IconData Function(T value) iconBuilder;
  final ValueChanged<T> onSelected;

  const _QuestionStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final value = options[index];
              final isSelected = value == selected;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(value),
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withAlpha(18)
                        : const Color(0xFF151D30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : Colors.white.withAlpha(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isSelected
                            ? AppColors.gold.withAlpha(38)
                            : Colors.white.withAlpha(10),
                        child: Icon(
                          iconBuilder(value),
                          color: isSelected
                              ? AppColors.goldSoft
                              : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          labelBuilder(value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : Colors.white,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.gold,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MultiInterestStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<TravelerInterest> options;
  final Set<TravelerInterest> selected;
  final String Function(TravelerInterest value) labelBuilder;
  final IconData Function(TravelerInterest value) iconBuilder;
  final ValueChanged<TravelerInterest> onSelected;

  const _MultiInterestStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final labels = selected.map(labelBuilder).toList(growable: false);
    return Column(
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: labels
              .map(
                (label) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.gold.withAlpha(42)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final value = options[index];
              final isSelected = selected.contains(value);
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(value),
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withAlpha(18)
                        : const Color(0xFF151D30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : Colors.white.withAlpha(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isSelected
                            ? AppColors.gold.withAlpha(38)
                            : Colors.white.withAlpha(10),
                        child: Icon(
                          iconBuilder(value),
                          color: isSelected ? AppColors.goldSoft : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          labelBuilder(value),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.gold
                            : Colors.white.withAlpha(35),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
