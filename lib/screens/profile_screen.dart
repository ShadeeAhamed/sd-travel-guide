import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth_welcome_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _savingMood = false;

  Future<void> _updateMood(TravelMood mood) async {
    setState(() => _savingMood = true);
    try {
      final updated = await AuthService.instance.updateMood(
        userId: widget.user.id,
        mood: mood,
      );
      widget.onUserUpdated(updated);
    } on AuthFlowException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _savingMood = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) {
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final prefs = user.preferences;
    final behavior = user.behaviorData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.midnight, AppColors.obsidian],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/branding/sd_travel_guide_icon.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.travelPersonality,
                        style: TextStyle(color: Colors.white.withAlpha(175)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InfoCard(
            title: 'Traveler settings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Email', value: user.email),
                _InfoRow(label: 'Contact', value: user.phone),
                _InfoRow(
                  label: 'Interest',
                  value: TravelerPreferences.labelForInterests(
                    prefs.allInterests,
                  ),
                ),
                _InfoRow(
                  label: 'Budget',
                  value: TravelerPreferences.labelForBudget(prefs.budget),
                ),
                _InfoRow(
                  label: 'Style',
                  value: TravelerPreferences.labelForStyle(prefs.style),
                ),
                _InfoRow(
                  label: 'Food',
                  value: TravelerPreferences.labelForFood(prefs.food),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Travel Mood Engine',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TravelMood.values.map((mood) {
                return ChoiceChip(
                  label: Text(TravelerPreferences.labelForMood(mood)),
                  selected: mood == prefs.mood,
                  onSelected: _savingMood ? null : (_) => _updateMood(mood),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Behavior data snapshot',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricChip(
                  label: 'Logins',
                  value: '${behavior['logins'] ?? 0}',
                ),
                _MetricChip(
                  label: 'AI chats',
                  value: '${behavior['assistant_messages'] ?? 0}',
                ),
                _MetricChip(
                  label: 'Map searches',
                  value: '${behavior['map_searches'] ?? 0}',
                ),
                _MetricChip(
                  label: 'Translator',
                  value: '${behavior['translator_uses'] ?? 0}',
                ),
                _MetricChip(
                  label: 'Plans',
                  value: '${behavior['itinerary_generations'] ?? 0}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.midnight,
              minimumSize: const Size.fromHeight(54),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalletScreen(user: user),
                ),
              );
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text(
              'Open travel wallet',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.redAlert,
              side: const BorderSide(color: AppColors.redAlert),
            ),
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.goldSoft,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
