import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FairTravelPricesScreen extends StatefulWidget {
  const FairTravelPricesScreen({super.key});

  @override
  State<FairTravelPricesScreen> createState() => _FairTravelPricesScreenState();
}

class _FairTravelPricesScreenState extends State<FairTravelPricesScreen> {
  String _zone = 'Colombo city';

  static const List<_PriceGuide> _guides = [
    _PriceGuide(
      zone: 'Colombo city',
      route: 'Short city tuk-tuk hop',
      price: 'LKR 300 - 700',
      note:
          'Use for short city moves. Confirm the fare before starting if the meter is not used.',
      icon: Icons.electric_rickshaw,
    ),
    _PriceGuide(
      zone: 'Colombo city',
      route: 'App taxi inside Colombo',
      price: 'LKR 900 - 2,200',
      note:
          'Best for comfort, rain, or late evening. Compare one app quote before accepting a street ride.',
      icon: Icons.local_taxi,
    ),
    _PriceGuide(
      zone: 'Airport',
      route: 'Airport to Colombo',
      price: 'LKR 4,500 - 7,500',
      note:
          'Ask whether expressway tolls are included. This route is one of the most common places for overcharging.',
      icon: Icons.flight_land,
    ),
    _PriceGuide(
      zone: 'Kandy',
      route: 'Lake area tuk-tuk',
      price: 'LKR 300 - 800',
      note:
          'Keep central rides short and walk the lake zone when traffic is heavy.',
      icon: Icons.electric_rickshaw,
    ),
    _PriceGuide(
      zone: 'Kandy',
      route: 'Kandy to Peradeniya',
      price: 'LKR 1,000 - 1,800',
      note:
          'Good if you are combining the gardens with a city day. Keep a return price clear too.',
      icon: Icons.route,
    ),
    _PriceGuide(
      zone: 'Ella',
      route: 'Town to Nine Arch Bridge',
      price: 'LKR 600 - 1,500',
      note:
          'Walking is possible for some travelers, but a short tuk-tuk saves time if the weather changes.',
      icon: Icons.alt_route,
    ),
    _PriceGuide(
      zone: 'Ella',
      route: 'Ella to Ravana Falls',
      price: 'LKR 1,000 - 2,000',
      note:
          'Bundle several stops in one ride instead of paying separately for each viewpoint.',
      icon: Icons.waterfall_chart,
    ),
    _PriceGuide(
      zone: 'South coast',
      route: 'Galle to Unawatuna',
      price: 'LKR 800 - 1,500',
      note:
          'This is a short coastal hop. A much higher quote usually means tourist pricing.',
      icon: Icons.directions_car,
    ),
    _PriceGuide(
      zone: 'South coast',
      route: 'Mirissa whale harbor transfer',
      price: 'LKR 500 - 1,200',
      note:
          'Arrange early and keep the return sorted if you are leaving before sunrise.',
      icon: Icons.sailing,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _guides.where((guide) => guide.zone == _zone).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        title: const Text('Fair travel prices'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Use these as guide ranges, not fixed prices.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'The safest travel move is to compare one app quote, one local quote, and then agree clearly before the ride starts.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Colombo city', 'Airport', 'Kandy', 'Ella', 'South coast']
                .map(
                  (zone) => ChoiceChip(
                    label: Text(zone),
                    selected: _zone == zone,
                    onSelected: (_) {
                      setState(() => _zone = zone);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ...filtered.map(
            (guide) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.gold.withAlpha(16),
                          child: Icon(guide.icon, color: AppColors.gold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            guide.route,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          guide.price,
                          style: const TextStyle(
                            color: AppColors.goldSoft,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      guide.note,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.gold.withAlpha(30)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick anti-scam checklist',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1. Ask the total before the ride if the meter is off.\n2. Avoid agreeing while your bags are still being loaded.\n3. Save the hotel or destination on the map so you can follow the route.\n4. For longer rides, compare one taxi app quote first.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.4,
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

class _PriceGuide {
  final String zone;
  final String route;
  final String price;
  final String note;
  final IconData icon;

  const _PriceGuide({
    required this.zone,
    required this.route,
    required this.price,
    required this.note,
    required this.icon,
  });
}
