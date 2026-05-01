import 'package:flutter/material.dart';

import '../data/place_extra_data.dart';
import '../data/places_data.dart';
import '../theme/app_theme.dart';

class ArExplorerScreen extends StatefulWidget {
  const ArExplorerScreen({super.key});

  @override
  State<ArExplorerScreen> createState() => _ArExplorerScreenState();
}

class _ArExplorerScreenState extends State<ArExplorerScreen> {
  String _selectedPlaceName = 'Sigiriya';

  @override
  Widget build(BuildContext context) {
    final extra = placeExtraData[_selectedPlaceName];
    final nearby = extra == null
        ? 'Nearby gems load here.'
        : extra.nearbyPlaces.take(3).join(', ');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        title: const Text('AR explorer'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.obsidian, AppColors.midnight],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Icon(Icons.view_in_ar, color: AppColors.gold, size: 60),
                const SizedBox(height: 12),
                const Text(
                  'Landmark scan beta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preview how the AR overlay will guide you at famous Sri Lanka landmarks, then use the local tips even without internet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withAlpha(175)),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPlaceName,
                  dropdownColor: AppColors.obsidian,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Preview a landmark',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.place_outlined, color: AppColors.gold),
                  ),
                  items: seedPlaces
                      .take(16)
                      .map(
                        (place) => DropdownMenuItem<String>(
                          value: place.name,
                          child: Text(place.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedPlaceName = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ArItem(
            title: 'What the overlay tells you',
            subtitle: extra == null
                ? 'This landmark will show place context, a short guide, and the best time to explore it.'
                : '${extra.headline} Best time: ${extra.bestTime}. Ideal stay: ${extra.idealDuration}.',
          ),
          const SizedBox(height: 12),
          _ArItem(
            title: 'Hidden gems nearby',
            subtitle: nearby,
          ),
          const SizedBox(height: 12),
          _ArItem(
            title: 'Offline label pack',
            subtitle: extra == null
                ? 'Distance hint, safety note, and place type stay visible when your connection drops.'
                : 'Transport: ${extra.transportTip} Local tip: ${extra.localTip}',
          ),
        ],
      ),
    );
  }
}

class _ArItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ArItem({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
