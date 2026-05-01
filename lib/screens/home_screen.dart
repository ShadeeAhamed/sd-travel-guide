import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/place_model.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/user_preference_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/place_photo.dart';
import 'ai_translator_screen.dart';
import 'ar_explorer_screen.dart';
import 'fair_travel_prices_screen.dart';
import 'offline_survival_screen.dart';
import 'place_details_screen.dart';
import 'places_screen.dart';
import 'sos_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onOpenAssistant;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenItinerary;
  final VoidCallback onOpenProfile;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onOpenAssistant,
    required this.onOpenMap,
    required this.onOpenItinerary,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final recommendations = UserPreferenceEngine.topMatches(user.preferences);
    final insights = UserPreferenceEngine.buildInsights(user.preferences);
    final greeting = UserPreferenceEngine.timeAwarePrompt(
      user.preferences,
      DateTime.now(),
    );
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide = width >= 760;
          final placeCardWidth = isWide
              ? 280.0
              : math.max(220, math.min(width * 0.7, 280)).toDouble();
          final insightCardWidth = isWide
              ? (width - 60) / 3
              : math.max(160, (width - 50) / 2).toDouble();

          return ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 110,
            ),
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.midnight,
                      AppColors.obsidian,
                      Color(0xFF1B1325),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.gold.withAlpha(28),
                            ),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/branding/sd_travel_guide_icon.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user.firstName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.travelPersonality,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(170),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onOpenProfile,
                          color: Colors.white,
                          icon: const Icon(Icons.tune),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your premium Sri Lanka travel co-pilot.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withAlpha(175),
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.midnight,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: onOpenItinerary,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Plan my day',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 14),
                    GridView(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 4 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: isWide ? 170 : 182,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ActionCard(
                          title: 'Travel AI',
                          subtitle:
                              'Context-aware guidance and stronger local answers',
                          icon: Icons.smart_toy,
                          accent: AppColors.gold,
                          onTap: onOpenAssistant,
                        ),
                        _ActionCard(
                          title: 'Smart map',
                          subtitle:
                              'Routes, search, highlighted places, and offline support',
                          icon: Icons.explore,
                          accent: AppColors.pine,
                          onTap: onOpenMap,
                        ),
                        _ActionCard(
                          title: 'Translator',
                          subtitle:
                              'Instant voice help for Sinhala, Tamil, and English',
                          icon: Icons.translate,
                          accent: AppColors.sunset,
                          onTap: () {
                            AuthService.instance.updateBehaviorCounter(
                              user.id,
                              'translator_uses',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AiTranslatorScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Safety SOS',
                          subtitle:
                              'Fast help, emergency numbers, and survival tools',
                          icon: Icons.shield_moon,
                          accent: AppColors.redAlert,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SosScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Built for your style',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: insights
                          .map(
                            (insight) => _InsightCard(
                              insight: insight,
                              width: insightCardWidth,
                              onTap: () => _openInsight(context, insight.title),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recommended places',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlacesScreen(),
                              ),
                            );
                          },
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 256,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final place = recommendations[index];
                          return _PlaceCard(
                            place: place,
                            width: placeCardWidth,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Premium modules',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _ModuleBanner(
                      title: 'AR Explorer',
                      subtitle:
                          'Preview landmark intelligence, hidden gems, and offline labels in a cleaner beta flow.',
                      icon: Icons.view_in_ar,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArExplorerScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ModuleBanner(
                      title: 'Travel Wallet',
                      subtitle:
                          'Track your daily spend, remaining balance, and category pressure in one place.',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletScreen(user: user),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openInsight(BuildContext context, String title) {
    switch (title) {
      case 'Plan my day':
        onOpenItinerary();
        return;
      case 'Fair travel prices':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FairTravelPricesScreen(),
          ),
        );
        return;
      case 'Offline survival':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const OfflineSurvivalScreen(),
          ),
        );
        return;
    }
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151D30),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withAlpha(10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withAlpha(18),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.3,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final DashboardInsight insight;
  final double width;
  final VoidCallback onTap;

  const _InsightCard({
    required this.insight,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151D30),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: insight.accent.withAlpha(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(insight.icon, color: insight.accent),
            const SizedBox(height: 12),
            Text(
              insight.title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              insight.subtitle,
              style: const TextStyle(
                height: 1.35,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final double width;

  const _PlaceCard({
    required this.place,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaceDetailsScreen(place: place),
          ),
        );
      },
      child: Ink(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF151D30),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: PlacePhoto(
                placeName: place.name,
                assetPath: place.image,
                width: width,
                height: 126,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.type,
                    style: const TextStyle(
                      color: AppColors.pine,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha(8),
              Colors.white.withAlpha(4),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.gold.withAlpha(16),
              child: Icon(icon, color: AppColors.gold),
            ),
            const SizedBox(width: 14),
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
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
