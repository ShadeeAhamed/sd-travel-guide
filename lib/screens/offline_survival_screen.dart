import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OfflineSurvivalScreen extends StatelessWidget {
  const OfflineSurvivalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        title: const Text('Offline survival'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.midnight, AppColors.obsidian],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep the essentials ready even with no signal.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This pack keeps your key places, map mode, emergency words, and route habits ready before you lose internet.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _OfflineStatusCard(
            icon: Icons.map_outlined,
            title: 'Maps ready',
            subtitle:
                'Tourist places stay visible, and the map can switch itself into offline mode when the network drops.',
          ),
          const SizedBox(height: 12),
          const _OfflineStatusCard(
            icon: Icons.route_outlined,
            title: 'Itinerary saved',
            subtitle:
                'Your generated day plan remains readable without internet, so you can still follow your timings and stops.',
          ),
          const SizedBox(height: 12),
          const _OfflineStatusCard(
            icon: Icons.translate_outlined,
            title: 'Emergency phrases ready',
            subtitle:
                'Keep quick Sinhala, Tamil, and English phrases ready for transport, water, medicine, police, and hotel help.',
          ),
          const SizedBox(height: 12),
          const _OfflineStatusCard(
            icon: Icons.shield_outlined,
            title: 'Safety tools ready',
            subtitle:
                'Emergency numbers, hotel address notes, and survival steps are still visible even when coverage is weak.',
          ),
          const SizedBox(height: 18),
          const _PhraseSection(),
          const SizedBox(height: 18),
          const _ChecklistSection(),
        ],
      ),
    );
  }
}

class _OfflineStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OfflineStatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.gold.withAlpha(16),
            child: Icon(icon, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhraseSection extends StatelessWidget {
  const _PhraseSection();

  @override
  Widget build(BuildContext context) {
    final phrases = const [
      MapEntry('Need water', 'Water / Wathura / Thanni'),
      MapEntry('Where is my hotel?', 'Hotel eka koheda? / En hotel enga?'),
      MapEntry(
        'Please call police',
        'Police call karanna / Police-kku call pannunga',
      ),
      MapEntry('I need a doctor', 'Doctor one / Maruthuvar venum'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency phrase pack',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...phrases.map(
            (phrase) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.record_voice_over,
                      color: AppColors.gold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${phrase.key}: ${phrase.value}',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistSection extends StatelessWidget {
  const _ChecklistSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withAlpha(24)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Before leaving the hotel',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '1. Screenshot your hotel name and map pin.\n2. Save one emergency contact and hotel phone number.\n3. Keep enough water and cash for one extra ride.\n4. Download your next destination mentally too: nearest town, not just the attraction name.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
