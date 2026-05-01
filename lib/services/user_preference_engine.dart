import 'package:flutter/material.dart';

import '../data/place_extra_data.dart';
import '../data/places_data.dart';
import '../models/place_model.dart';
import '../models/user_profile_model.dart';
import '../theme/app_theme.dart';

class DashboardInsight {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const DashboardInsight({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class ItineraryStop {
  final String title;
  final String timing;
  final String summary;
  final String cost;

  const ItineraryStop({
    required this.title,
    required this.timing,
    required this.summary,
    required this.cost,
  });
}

class ItineraryDayPlan {
  final int dayNumber;
  final String placeName;
  final String theme;
  final String transportHint;
  final String foodHint;
  final String budgetHint;
  final List<ItineraryStop> stops;

  const ItineraryDayPlan({
    required this.dayNumber,
    required this.placeName,
    required this.theme,
    required this.transportHint,
    required this.foodHint,
    required this.budgetHint,
    required this.stops,
  });
}

class UserPreferenceEngine {
  static String personalityLabel(TravelerPreferences preferences) {
    if (preferences.allInterests.contains(TravelerInterest.beach) &&
        preferences.style == TravelStyle.relax) {
      return 'Coastal Dreamer';
    }

    if (preferences.allInterests.contains(TravelerInterest.hiking) &&
        preferences.style == TravelStyle.adventure) {
      return 'Summit Seeker';
    }

    if (preferences.allInterests.contains(TravelerInterest.culture)) {
      return 'Heritage Hunter';
    }

    if (preferences.allInterests.contains(TravelerInterest.waterfalls)) {
      return 'Mist Chaser';
    }

    if (preferences.budget == BudgetPreference.luxury) {
      return 'Signature Voyager';
    }

    return 'Island Explorer';
  }

  static Color moodAccent(TravelMood mood) {
    switch (mood) {
      case TravelMood.chill:
        return AppColors.pine;
      case TravelMood.adventure:
        return AppColors.sunset;
      case TravelMood.luxury:
        return AppColors.gold;
      case TravelMood.culture:
        return AppColors.sand;
    }
  }

  static String timeAwarePrompt(TravelerPreferences preferences, DateTime now) {
    final hour = now.hour;
    final interest =
        TravelerPreferences.labelForInterests(preferences.allInterests);
    if (hour < 11) {
      return 'Good morning. This is a strong window for your $interest-style start before the crowds build.';
    }
    if (hour < 16) {
      return 'Midday is better for slower stops, food, and indoor breaks. Save exposed viewpoints for later.';
    }
    return 'This is your golden-hour window. Use it for coastal walks, fort views, or a relaxed scenic finish.';
  }

  static List<PlaceModel> topMatches(TravelerPreferences preferences) {
    final sorted = [...seedPlaces];
    sorted.sort((left, right) {
      final leftScore = _scorePlace(left, preferences);
      final rightScore = _scorePlace(right, preferences);
      return rightScore.compareTo(leftScore);
    });
    return sorted.take(6).toList();
  }

  static List<PlaceModel> suggestedDestinations(
    TravelerPreferences preferences,
    int days,
  ) {
    final matches = topMatches(preferences);
    if (matches.isEmpty) {
      return const [];
    }
    return List.generate(days, (index) => matches[index % matches.length]);
  }

  static List<DashboardInsight> buildInsights(
    TravelerPreferences preferences,
  ) {
    return [
      DashboardInsight(
        title: 'Plan my day',
        subtitle:
            'Auto-build a ${TravelerPreferences.labelForMood(preferences.mood).toLowerCase()} route with food, transport, and timing.',
        icon: Icons.auto_awesome,
        accent: moodAccent(preferences.mood),
      ),
      DashboardInsight(
        title: 'Fair travel prices',
        subtitle:
            'Check tuk, taxi, and rail guidance before you accept a ride.',
        icon: Icons.price_check,
        accent: AppColors.gold,
      ),
      DashboardInsight(
        title: 'Offline survival',
        subtitle:
            'Keep maps, itinerary, emergency phrases, and key places ready without signal.',
        icon: Icons.travel_explore,
        accent: AppColors.sunset,
      ),
    ];
  }

  static List<ItineraryDayPlan> buildItinerary({
    required TravelerPreferences preferences,
    required int days,
  }) {
    final matches = suggestedDestinations(preferences, days);
    return List.generate(
      matches.length,
      (index) => buildDayPlanForPlace(
        place: matches[index],
        preferences: preferences,
        dayNumber: index + 1,
      ),
    );
  }

  static ItineraryDayPlan buildDayPlanForPlace({
    required PlaceModel place,
    required TravelerPreferences preferences,
    required int dayNumber,
  }) {
    final extra = placeExtraData[place.name];
    final stops = <ItineraryStop>[];

    if (extra != null && extra.visitPlan.isNotEmpty) {
      for (final stop in extra.visitPlan.take(4)) {
        stops.add(
          ItineraryStop(
            title: stop.title,
            timing: stop.time,
            summary: stop.details,
            cost: stop.costNote,
          ),
        );
      }
    } else {
      stops.addAll(_genericStopsForPlace(place, preferences));
    }

    return ItineraryDayPlan(
      dayNumber: dayNumber,
      placeName: place.name,
      theme: '${place.name} ${_themeSuffix(preferences)}',
      transportHint:
          extra?.transportTip ?? _defaultTransportHint(place, preferences),
      foodHint: _foodHint(place, preferences.food),
      budgetHint: extra?.budget ?? _budgetHint(place, preferences.budget),
      stops: stops,
    );
  }

  static int _scorePlace(PlaceModel place, TravelerPreferences preferences) {
    var score = 0;
    final type = place.type.toLowerCase();
    final name = place.name.toLowerCase();

    for (final interest in preferences.allInterests) {
      switch (interest) {
        case TravelerInterest.beach:
          if (type.contains('beach')) {
            score += 6;
          }
          if (name.contains('bay') || name.contains('mirissa')) {
            score += 3;
          }
          break;
        case TravelerInterest.waterfalls:
          if (name.contains('ella') ||
              type.contains('hill') ||
              type.contains('waterfall') ||
              name.contains('diyaluma') ||
              name.contains('bambarakanda')) {
            score += 5;
          }
          break;
        case TravelerInterest.hiking:
          if (type.contains('hiking') ||
              type.contains('hill') ||
              type.contains('nature') ||
              type.contains('adventure') ||
              name.contains('pidurangala') ||
              name.contains('adam') ||
              name.contains('knuckles')) {
            score += 6;
          }
          break;
        case TravelerInterest.culture:
          if (type.contains('heritage') || type.contains('culture')) {
            score += 6;
          }
          break;
        case TravelerInterest.mixed:
          score += 2;
          break;
      }
    }

    switch (preferences.style) {
      case TravelStyle.relax:
        if (type.contains('beach') || name.contains('bentota')) {
          score += 3;
        }
        break;
      case TravelStyle.adventure:
        if (type.contains('wildlife') || type.contains('hiking')) {
          score += 3;
        }
        break;
      case TravelStyle.exploreEverything:
        score += 2;
        break;
    }

    switch (preferences.budget) {
      case BudgetPreference.low:
        if (name.contains('ella') || name.contains('galle')) {
          score += 2;
        }
        break;
      case BudgetPreference.medium:
        score += 2;
        break;
      case BudgetPreference.luxury:
        if (name.contains('bentota') || name.contains('colombo')) {
          score += 3;
        }
        break;
    }

    return score;
  }

  static String _themeSuffix(TravelerPreferences preferences) {
    switch (preferences.mood) {
      case TravelMood.chill:
        return 'slow-travel day';
      case TravelMood.adventure:
        return 'adventure route';
      case TravelMood.luxury:
        return 'signature day';
      case TravelMood.culture:
        return 'culture route';
    }
  }

  static List<ItineraryStop> _genericStopsForPlace(
    PlaceModel place,
    TravelerPreferences preferences,
  ) {
    return [
      ItineraryStop(
        title: 'Arrive in ${place.name}',
        timing: '8:00 AM',
        summary:
            'Start early so you can use the calmest part of the day for your main ${place.type.toLowerCase()} experience.',
        cost: _budgetHint(place, preferences.budget),
      ),
      ItineraryStop(
        title: 'Core ${place.type.toLowerCase()} experience',
        timing: '11:00 AM',
        summary: place.description,
        cost: 'Mixed cost',
      ),
      ItineraryStop(
        title: 'Local food and scenic pause',
        timing: '2:30 PM',
        summary: _foodHint(place, preferences.food),
        cost: 'Food budget varies',
      ),
      ItineraryStop(
        title: 'Golden-hour finish',
        timing: '5:30 PM',
        summary:
            'Use the late afternoon for your best photos, a relaxed walk, and the easiest transfer to your next stay.',
        cost: 'Free to low cost',
      ),
    ];
  }

  static String _defaultTransportHint(
    PlaceModel place,
    TravelerPreferences preferences,
  ) {
    final type = place.type.toLowerCase();
    if (type.contains('beach')) {
      return 'Use one longer transfer into the coast, then keep local tuk-tuk trips short to avoid overpaying.';
    }
    if (type.contains('heritage') || type.contains('culture')) {
      return 'Pair a car or tuk-tuk with one walkable core zone so you avoid wasting time in short hops.';
    }
    if (type.contains('hill') || type.contains('hiking')) {
      return 'Start early, keep a weather buffer, and use one driver or tuk-tuk for multiple viewpoints instead of booking each leg separately.';
    }
    if (preferences.style == TravelStyle.relax) {
      return 'Keep transfers simple with one main ride in and one flexible return.';
    }
    return 'Use rail or intercity buses for long legs and switch to a local tuk-tuk only for your final short stretch.';
  }

  static String _foodHint(PlaceModel place, FoodPreference foodPreference) {
    final lowerName = place.name.toLowerCase();
    if (foodPreference == FoodPreference.local) {
      if (lowerName.contains('jaffna')) {
        return 'Prioritize local crab curry, seafood, and Northern Tamil meals instead of generic hotel menus.';
      }
      if (lowerName.contains('kandy')) {
        return 'Mix a local rice-and-curry lunch with one evening stop for Kandy-style street food or grilled meat.';
      }
      return 'Keep one meal local so the day feels grounded: rice and curry for lunch, and a lighter regional dinner later.';
    }
    if (foodPreference == FoodPreference.international) {
      return 'Stay near the main visitor strip so you can mix your sightseeing with cafes, bakeries, and easier international menus.';
    }
    return 'Use lunch for a local Sri Lankan meal, then keep dinner flexible so the group can choose between seafood, grills, or cafe food.';
  }

  static String _budgetHint(
    PlaceModel place,
    BudgetPreference budgetPreference,
  ) {
    final type = place.type.toLowerCase();
    switch (budgetPreference) {
      case BudgetPreference.low:
        if (type.contains('heritage') || type.contains('wildlife')) {
          return 'Budget carefully: core entry fees matter more than food here.';
        }
        return 'Best value if you keep transport shared and choose one paid activity.';
      case BudgetPreference.medium:
        return 'Balanced budget: one main paid highlight, comfortable meals, and flexible local transport.';
      case BudgetPreference.luxury:
        return 'Comfort budget: private transfers, scenic cafes, and a premium stay still fit this route well.';
    }
  }
}
