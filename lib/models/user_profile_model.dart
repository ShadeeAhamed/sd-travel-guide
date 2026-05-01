import 'dart:convert';

enum TravelerInterest { beach, waterfalls, hiking, culture, mixed }

enum BudgetPreference { low, medium, luxury }

enum TravelStyle { relax, adventure, exploreEverything }

enum FoodPreference { local, international, both }

enum TravelMood { chill, adventure, luxury, culture }

class TravelerPreferences {
  final TravelerInterest interest;
  final List<TravelerInterest> extraInterests;
  final BudgetPreference budget;
  final TravelStyle style;
  final FoodPreference food;
  final TravelMood mood;

  const TravelerPreferences({
    required this.interest,
    this.extraInterests = const [],
    required this.budget,
    required this.style,
    required this.food,
    required this.mood,
  });

  const TravelerPreferences.defaultProfile()
      : interest = TravelerInterest.mixed,
        extraInterests = const [],
        budget = BudgetPreference.medium,
        style = TravelStyle.exploreEverything,
        food = FoodPreference.both,
        mood = TravelMood.chill;

  TravelerPreferences copyWith({
    TravelerInterest? interest,
    List<TravelerInterest>? extraInterests,
    BudgetPreference? budget,
    TravelStyle? style,
    FoodPreference? food,
    TravelMood? mood,
  }) {
    return TravelerPreferences(
      interest: interest ?? this.interest,
      extraInterests: extraInterests ?? this.extraInterests,
      budget: budget ?? this.budget,
      style: style ?? this.style,
      food: food ?? this.food,
      mood: mood ?? this.mood,
    );
  }

  List<TravelerInterest> get allInterests {
    final values = <TravelerInterest>[interest];
    for (final item in extraInterests) {
      if (!values.contains(item)) {
        values.add(item);
      }
    }
    return values;
  }

  Map<String, dynamic> toJson() {
    return {
      'interest': interest.name,
      'extraInterests': extraInterests.map((value) => value.name).toList(),
      'budget': budget.name,
      'style': style.name,
      'food': food.name,
      'mood': mood.name,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory TravelerPreferences.fromJson(Map<String, dynamic> json) {
    final rawExtraInterests = json['extraInterests'];
    final rawInterests = json['interests'];
    final primaryInterest = _enumFromName(
      TravelerInterest.values,
      json['interest'],
      TravelerInterest.mixed,
    );
    final derivedExtraInterests = <TravelerInterest>[
      ..._enumListFromNames(
        TravelerInterest.values,
        rawExtraInterests,
      ),
      ..._enumListFromNames(
        TravelerInterest.values,
        rawInterests,
      ).where((value) => value != primaryInterest),
    ].toSet().toList();

    return TravelerPreferences(
      interest: primaryInterest,
      extraInterests: derivedExtraInterests,
      budget: _enumFromName(
        BudgetPreference.values,
        json['budget'],
        BudgetPreference.medium,
      ),
      style: _enumFromName(
        TravelStyle.values,
        json['style'],
        TravelStyle.exploreEverything,
      ),
      food: _enumFromName(
        FoodPreference.values,
        json['food'],
        FoodPreference.both,
      ),
      mood: _enumFromName(
        TravelMood.values,
        json['mood'],
        TravelMood.chill,
      ),
    );
  }

  factory TravelerPreferences.fromJsonString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const TravelerPreferences.defaultProfile();
    }
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return TravelerPreferences.fromJson(decoded);
    }
    return const TravelerPreferences.defaultProfile();
  }

  static String labelForInterest(TravelerInterest value) {
    switch (value) {
      case TravelerInterest.beach:
        return 'Beach';
      case TravelerInterest.waterfalls:
        return 'Waterfalls';
      case TravelerInterest.hiking:
        return 'Hiking';
      case TravelerInterest.culture:
        return 'Culture';
      case TravelerInterest.mixed:
        return 'Mixed';
    }
  }

  static String labelForInterests(List<TravelerInterest> values) {
    if (values.isEmpty) {
      return labelForInterest(TravelerInterest.mixed);
    }
    return values.map(labelForInterest).join(', ');
  }

  static String labelForBudget(BudgetPreference value) {
    switch (value) {
      case BudgetPreference.low:
        return 'Low';
      case BudgetPreference.medium:
        return 'Medium';
      case BudgetPreference.luxury:
        return 'Luxury';
    }
  }

  static String labelForStyle(TravelStyle value) {
    switch (value) {
      case TravelStyle.relax:
        return 'Relax';
      case TravelStyle.adventure:
        return 'Adventure';
      case TravelStyle.exploreEverything:
        return 'Explore everything';
    }
  }

  static String labelForFood(FoodPreference value) {
    switch (value) {
      case FoodPreference.local:
        return 'Local';
      case FoodPreference.international:
        return 'International';
      case FoodPreference.both:
        return 'Both';
    }
  }

  static String labelForMood(TravelMood value) {
    switch (value) {
      case TravelMood.chill:
        return 'Chill';
      case TravelMood.adventure:
        return 'Adventure';
      case TravelMood.luxury:
        return 'Luxury';
      case TravelMood.culture:
        return 'Culture';
    }
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String passwordHash;
  final TravelerPreferences preferences;
  final String travelPersonality;
  final Map<String, dynamic> historyData;
  final Map<String, dynamic> behaviorData;
  final bool isOnboardingComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.preferences,
    required this.travelPersonality,
    required this.historyData,
    required this.behaviorData,
    required this.isOnboardingComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? passwordHash,
    TravelerPreferences? preferences,
    String? travelPersonality,
    Map<String, dynamic>? historyData,
    Map<String, dynamic>? behaviorData,
    bool? isOnboardingComplete,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      preferences: preferences ?? this.preferences,
      travelPersonality: travelPersonality ?? this.travelPersonality,
      historyData: historyData ?? this.historyData,
      behaviorData: behaviorData ?? this.behaviorData,
      isOnboardingComplete:
          isOnboardingComplete ?? this.isOnboardingComplete,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'preferences_json': preferences.toJsonString(),
      'travel_personality': travelPersonality,
      'history_json': jsonEncode(historyData),
      'behavior_json': jsonEncode(behaviorData),
      'is_onboarding_complete': isOnboardingComplete ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      passwordHash: map['password_hash'] as String,
      preferences: TravelerPreferences.fromJsonString(
        map['preferences_json'] as String?,
      ),
      travelPersonality: map['travel_personality'] as String? ?? 'Explorer',
      historyData: _decodeMap(map['history_json'] as String?),
      behaviorData: _decodeMap(map['behavior_json'] as String?),
      isOnboardingComplete: (map['is_onboarding_complete'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  factory AppUser.fromApiJson(Map<String, dynamic> json) {
    final preferences = json['preferences'];
    final history = json['history'];
    final behavior = json['behavior'];
    final onboardingValue = json['isOnboardingComplete'];
    return AppUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      passwordHash: json['passwordHash']?.toString() ?? '',
      preferences: preferences is Map<String, dynamic>
          ? TravelerPreferences.fromJson(preferences)
          : const TravelerPreferences.defaultProfile(),
      travelPersonality:
          json['travelPersonality']?.toString() ?? 'Island Explorer',
      historyData: _normalizeHistory(history),
      behaviorData: _normalizeBehavior(behavior),
      isOnboardingComplete: onboardingValue == true ||
          (onboardingValue == null &&
              (json['travelPersonality']?.toString() ?? '') !=
                  'New Explorer'),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String get maskedEmail {
    if (!email.contains('@')) {
      return email;
    }
    final parts = email.split('@');
    final local = parts.first;
    final visible = local.length <= 2 ? local : '${local[0]}${local[1]}';
    return '$visible***@${parts.last}';
  }

  String get maskedPhone {
    if (phone.length <= 4) {
      return phone;
    }
    return '${phone.substring(0, 3)}*****${phone.substring(phone.length - 2)}';
  }

  static Map<String, dynamic> _decodeMap(String? value) {
    if (value == null || value.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  static Map<String, dynamic> _normalizeHistory(dynamic value) {
    if (value is Map<String, dynamic>) {
      return {
        'recent_places': value['recent_places'] ?? value['savedPlaces'] ?? [],
        'saved_itineraries':
            value['saved_itineraries'] ?? value['itineraries'] ?? [],
      };
    }
    return <String, dynamic>{
      'recent_places': <String>[],
      'saved_itineraries': <String>[],
    };
  }

  static Map<String, dynamic> _normalizeBehavior(dynamic value) {
    if (value is Map<String, dynamic>) {
      return {
        'logins': value['logins'] ?? 0,
        'assistant_messages':
            value['assistant_messages'] ?? value['assistantMessages'] ?? 0,
        'map_searches': value['map_searches'] ?? value['mapSearches'] ?? 0,
        'translator_uses':
            value['translator_uses'] ?? value['translatorUses'] ?? 0,
        'itinerary_generations': value['itinerary_generations'] ??
            value['itineraryGenerations'] ??
            0,
      };
    }
    return <String, dynamic>{
      'logins': 0,
      'assistant_messages': 0,
      'map_searches': 0,
      'translator_uses': 0,
      'itinerary_generations': 0,
    };
  }
}

T _enumFromName<T extends Enum>(List<T> values, dynamic raw, T fallback) {
  for (final value in values) {
    if (value.name == raw) {
      return value;
    }
  }
  return fallback;
}

List<T> _enumListFromNames<T extends Enum>(List<T> values, dynamic raw) {
  if (raw is! List) {
    return const [];
  }

  final parsed = <T>[];
  for (final item in raw) {
    for (final value in values) {
      if (value.name == item) {
        parsed.add(value);
        break;
      }
    }
  }
  return parsed;
}
