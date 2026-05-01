import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/place_extra_data.dart';
import '../data/places_data.dart';

class AiChatMessage {
  final String role;
  final String content;

  const AiChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {
        'role': role,
        'content': content,
      };
}

class AiChatResponse {
  final String answer;
  final List<AiChatSource> sources;

  const AiChatResponse({required this.answer, required this.sources});

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    final answer = json['answer'];
    final rawSources = json['sources'];
    return AiChatResponse(
      answer: answer is String && answer.trim().isNotEmpty
          ? answer
          : 'I could not generate an answer.',
      sources: rawSources is List
          ? rawSources
              .whereType<Map<dynamic, dynamic>>()
              .map(AiChatSource.fromJson)
              .toList()
          : const [],
    );
  }
}

class AiChatSource {
  final String title;
  final String url;

  const AiChatSource({required this.title, required this.url});

  factory AiChatSource.fromJson(Map<dynamic, dynamic> json) {
    final url = json['url']?.toString() ?? '';
    final title = json['title']?.toString();
    return AiChatSource(
      title: title == null || title.isEmpty ? url : title,
      url: url,
    );
  }
}

class AiChatService {
  static const String baseUrl = String.fromEnvironment(
    'AI_CHAT_API_URL',
    defaultValue: 'http://10.0.2.2:8000/chat',
  );

  static final Map<String, AiChatResponse> _responseCache = {};

  static Future<AiChatResponse> send(List<AiChatMessage> messages) async {
    final latestUserMessage = _latestUserMessage(messages);
    final normalized = _normalize(latestUserMessage);
    if (normalized.isEmpty) {
      return const AiChatResponse(
        answer:
            'Ask me about Sri Lanka places, routes, beaches, culture, or trip ideas.',
        sources: [],
      );
    }

    final instantReply = _buildInstantReply(normalized);
    if (instantReply != null) {
      _responseCache[normalized] = instantReply;
      return instantReply;
    }

    final cached = _responseCache[normalized];
    if (cached != null) {
      return cached;
    }

    try {
      final recentMessages =
          messages.length > 12 ? messages.sublist(messages.length - 12) : messages;

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'messages': recentMessages.map((message) => message.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final remoteResponse = AiChatResponse.fromJson(data);
          _responseCache[normalized] = remoteResponse;
          return remoteResponse;
        }
      }
    } catch (_) {}

    final fallback = _buildFallbackReply(normalized);
    _responseCache[normalized] = fallback;
    return fallback;
  }

  static String _latestUserMessage(List<AiChatMessage> messages) {
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == 'user') {
        return messages[i].content.trim();
      }
    }
    return '';
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static AiChatResponse? _buildInstantReply(String query) {
    final structuredPlan = _buildStructuredPlanReply(query);
    if (structuredPlan != null) {
      return structuredPlan;
    }

    if (_containsAny(query, const [
      'best places to visit',
      'top places',
      'must visit',
      'where should i go',
    ])) {
      return AiChatResponse(answer: _bestPlacesAnswer(), sources: const []);
    }

    if (_containsAny(query, const [
      'what should i do now',
      'what to do now',
      'best sunset',
      'sunset spots',
    ])) {
      return const AiChatResponse(
        answer:
            'For a strong late-day Sri Lanka move, use sunset for Galle Fort ramparts, Colombo Galle Face Green, Mirissa beach, Trincomalee viewpoints, or Pidurangala if you are already near Sigiriya. If it is still morning, shift to hikes, temples, or major heritage climbs before the heat builds.',
        sources: [],
      );
    }

    if (_containsAny(query, const ['map', 'offline map', 'online map'])) {
      return const AiChatResponse(
        answer:
            'The Map screen now starts in auto online mode, switches to offline tiles if the internet drops, lets you search Sri Lanka locations, and builds a road route from your location when you are online. You can switch between drive and walk routing, force offline mode with the toggle, tap highlighted tourist destinations, and jump back to your current position with the location button.',
        sources: [],
      );
    }

    if (_containsAny(query, const [
      'emergency',
      'sos',
      'help line',
      'police',
      'ambulance',
      'fire',
    ])) {
      return const AiChatResponse(
        answer:
            'Use the Help / SOS screen for the emergency numbers stored inside the app. For urgent situations, open that screen immediately so you can call the right service without searching.',
        sources: [],
      );
    }

    if (_containsAny(query, const [
      '3 day itinerary',
      'three day itinerary',
      '3 day trip',
      'three day trip',
    ])) {
      return const AiChatResponse(
        answer:
            'A strong 3 day Sri Lanka plan is Colombo and Kandy on day 1, Sigiriya and Dambulla on day 2, then Ella or the south coast on day 3 depending on whether you want hills or beach time. If you like culture, choose Kandy, Sigiriya, and Galle. If you want scenery, choose Ella, Nuwara Eliya, and Mirissa.',
        sources: [],
      );
    }

    if (_containsAny(query, const [
      'train',
      'kandy to ella',
      'ella train',
      'scenic train',
    ])) {
      return const AiChatResponse(
        answer:
            'For the scenic hill-country rail experience, Kandy to Ella is the classic route. Reserve seats early when possible, keep one side free for views, and treat the ride as a daytime experience rather than just transport.',
        sources: [],
      );
    }

    if (_containsAny(query, const [
      'family trip',
      'family places',
      'kids',
      'child friendly',
    ])) {
      return const AiChatResponse(
        answer:
            'For a family-friendly Sri Lanka route, choose Bentota or Unawatuna for easier beach time, Kandy for culture without huge transfers, Nuwara Eliya for cool weather, and Udawalawe for wildlife. Ella is also good if your group can handle a little walking and train travel.',
        sources: [],
      );
    }

    if (_containsAny(query, const [
      'budget',
      'cheap',
      'low cost',
      'save money',
    ])) {
      return const AiChatResponse(
        answer:
            'For a better-value Sri Lanka trip, mix Kandy, Ella, Unawatuna, Hikkaduwa, and Colombo short stays. Use trains or intercity buses for the long legs, save safari or whale trips for the one big experience you care about most, and keep beach days and city walks as your free balance.',
        sources: [],
      );
    }

    final place = _matchPlace(query);
    if (place != null) {
      return AiChatResponse(
        answer: _placeAnswer(place.name),
        sources: const [],
      );
    }

    return null;
  }

  static AiChatResponse? _buildStructuredPlanReply(String query) {
    final place = _matchPlace(query);
    final days = _extractDays(query);
    final groupSize = _extractGroupSize(query);
    final budget = _extractBudget(query);
    final foodPreference = _foodPreference(query);

    final asksForPlan = _containsAny(query, const [
      'plan',
      'itinerary',
      'give us',
      'give me',
      'route',
      'trip',
    ]);

    if (place == null || !asksForPlan) {
      return null;
    }

    final extra = placeExtraData[place.name];
    final visitStops = (extra?.visitPlan ?? const []).take(3).toList();
    final dayCount = days ?? 1;
    final heading = groupSize == null
        ? 'Here is a strong ${place.name} plan'
        : 'Here is a strong ${place.name} plan for $groupSize people';
    final buffer = StringBuffer();

    buffer.writeln('$heading.');
    buffer.writeln();
    buffer.writeln(
      'Best shape: ${dayCount == 1 ? '1 day or 1 night' : '$dayCount days'} in ${place.name}.',
    );

    if (budget != null) {
      final perPerson = _isPerPersonBudget(query);
      final eachBudget = perPerson || groupSize == null
          ? budget
          : (budget / groupSize).round();
      final transportShare = (eachBudget * 0.25).round();
      final foodShare = (eachBudget * 0.35).round();
      final activityShare = (eachBudget * 0.25).round();
      final bufferShare = (eachBudget * 0.15).round();

      buffer.writeln(
        'Budget guide: about LKR $eachBudget ${perPerson || groupSize == null ? 'per person' : 'each if the total budget is shared evenly'}, with around LKR $transportShare for transport, LKR $foodShare for food, LKR $activityShare for entries, and LKR $bufferShare as a buffer.',
      );
    }

    buffer.writeln();
    buffer.writeln('Suggested flow:');
    if (visitStops.isNotEmpty) {
      for (final stop in visitStops) {
        buffer.writeln(
          '- ${stop.time}: ${stop.title}. ${stop.details} ${stop.costNote}.',
        );
      }
    } else {
      buffer.writeln('- Morning: start with the main ${place.type.toLowerCase()} highlight before heat and crowds build.');
      buffer.writeln('- Afternoon: slow down for lunch, a second viewpoint, and a flexible local stop.');
      buffer.writeln('- Evening: finish with your best photo window, food, and an easy return.');
    }

    buffer.writeln();
    buffer.writeln(
      'Food focus: ${_foodGuide(place.name, foodPreference)}',
    );

    if (extra != null) {
      buffer.writeln('Transport tip: ${extra.transportTip}');
      if (extra.nearbyPlaces.isNotEmpty) {
        buffer.writeln(
          'Good add-ons: ${extra.nearbyPlaces.take(3).join(', ')}.',
        );
      }
    }

    return AiChatResponse(
      answer: buffer.toString().trim(),
      sources: const [],
    );
  }

  static AiChatResponse _buildFallbackReply(String query) {
    if (_containsAny(query, const [
      'weather',
      'today',
      'open now',
      'opening hours',
      'ticket price',
      'current price',
      'latest',
    ])) {
      return const AiChatResponse(
        answer:
            'I can give you a fast local travel guide right now, but live weather, prices, and opening hours need the real AI backend running on your computer with internet access.',
        sources: [],
      );
    }

    if (_containsAny(query, const ['beach', 'sea', 'surf'])) {
      return const AiChatResponse(
        answer:
            'For beaches, start with Mirissa for whale watching and sunsets, Unawatuna for swimming and cafes, Hikkaduwa for snorkeling, Bentota for resort stays, Nilaveli or Pasikuda for calmer east-coast water, and Arugam Bay for surfing.',
        sources: [],
      );
    }

    if (_containsAny(query, const ['heritage', 'history', 'temple', 'culture'])) {
      return const AiChatResponse(
        answer:
            'For history and culture, focus on Kandy, Sigiriya, Dambulla, Anuradhapura, Polonnaruwa, Galle Fort, Kataragama, and Jaffna. That mix gives you royal cities, cave temples, colonial streets, and strong regional culture.',
        sources: [],
      );
    }

    if (_containsAny(query, const ['food', 'eat', 'restaurant', 'local food'])) {
      return const AiChatResponse(
        answer:
            'For food-focused stops, Colombo gives you the widest range, Jaffna gives you strong Northern Tamil flavors, Kandy is easy for classic rice and curry meals, and Mirissa or Galle are good for seafood by the coast.',
        sources: [],
      );
    }

    return const AiChatResponse(
      answer:
          'I can answer quickly from the app\'s Sri Lanka travel guide data even when the live backend is unavailable. Try asking about a place, a group size, a budget in LKR, a food preference, or a short itinerary.',
      sources: [],
    );
  }

  static bool _containsAny(String query, List<String> phrases) {
    return phrases.any(query.contains);
  }

  static _PlaceMatch? _matchPlace(String query) {
    final aliases = <String, String>{
      'nuwaraeliya': 'Nuwara Eliya',
      'nuwara eliya': 'Nuwara Eliya',
      'arugambay': 'Arugam Bay',
      'arugam bay': 'Arugam Bay',
      'adams peak': "Adam's Peak",
      'sigiriya rock': 'Sigiriya',
      'galle fort': 'Galle',
      'yala': 'Yala National Park',
      'udawalawe national park': 'Udawalawe',
      'wilpattu': 'Wilpattu National Park',
    };

    for (final entry in aliases.entries) {
      if (query.contains(entry.key)) {
        return _PlaceMatch(name: entry.value);
      }
    }

    for (final place in seedPlaces) {
      final normalizedName = _normalize(place.name);
      if (query.contains(normalizedName)) {
        return _PlaceMatch(name: place.name);
      }
    }
    return null;
  }

  static int? _extractDays(String query) {
    final match = RegExp(r'(\d+)\s*(day|days|night|nights)').firstMatch(query);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static int? _extractGroupSize(String query) {
    final match =
        RegExp(r'(\d+)\s*(people|person|pax|adult|adults)').firstMatch(query);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static int? _extractBudget(String query) {
    final match = RegExp(r'(\d{3,6})\s*(lkr|rs|rupees)?').firstMatch(query);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static bool _isPerPersonBudget(String query) {
    return _containsAny(query, const ['each', 'per person', 'one person']);
  }

  static String _foodPreference(String query) {
    if (_containsAny(query, const ['non veg', 'nonveg', 'chicken', 'seafood', 'halal'])) {
      return 'non-veg';
    }
    if (_containsAny(query, const ['veg', 'vegetarian'])) {
      return 'veg';
    }
    return 'mixed';
  }

  static String _bestPlacesAnswer() {
    const topNames = [
      'Sigiriya',
      'Ella',
      'Kandy',
      'Galle',
      'Mirissa',
      'Nuwara Eliya',
      'Yala National Park',
      'Trincomalee',
      'Jaffna',
      'Sinharaja Forest Reserve',
    ];

    final lines = topNames.map((name) {
      final place = seedPlaces.firstWhere((item) => item.name == name);
      return '- ${place.name}: ${place.description}';
    }).join('\n');

    return 'For a first Sri Lanka trip, these are strong picks:\n$lines';
  }

  static String _foodGuide(String placeName, String foodPreference) {
    final lowerName = placeName.toLowerCase();
    if (foodPreference == 'non-veg') {
      if (lowerName.contains('kandy')) {
        return 'Use lunch for rice and curry or biryani, then keep dinner for grilled chicken, kottu, or a stronger non-veg meal near the lake or town center.';
      }
      if (lowerName.contains('mirissa') || lowerName.contains('galle')) {
        return 'Seafood makes the most sense here: grilled fish, prawns, or a coastal curry near sunset.';
      }
      if (lowerName.contains('jaffna')) {
        return 'Northern-style crab curry, seafood, and spicy Tamil meals are the best non-veg direction here.';
      }
      return 'Keep lunch simple and use dinner for the stronger non-veg meal so your sightseeing window stays flexible.';
    }
    if (foodPreference == 'veg') {
      return 'A rice-and-curry lunch, hoppers, string hoppers, or cafe breakfast is the easiest vegetarian flow here.';
    }
    return 'Use one local Sri Lankan meal and one flexible cafe or seafood stop so the whole group stays comfortable.';
  }

  static String _placeAnswer(String placeName) {
    final place = seedPlaces.firstWhere((item) => item.name == placeName);
    final extra = placeExtraData[placeName];

    final buffer = StringBuffer();
    buffer.writeln(
      '${place.name} is one of Sri Lanka\'s main ${place.type.toLowerCase()} destinations.',
    );
    buffer.writeln();
    buffer.writeln(place.description);

    if (extra != null) {
      buffer.writeln();
      buffer.writeln(extra.headline);
      buffer.writeln();
      buffer.writeln('Best season: ${extra.bestSeason}');
      buffer.writeln('Best time to visit: ${extra.bestTime}');
      buffer.writeln('Ideal stay: ${extra.idealDuration}');
      buffer.writeln('Budget feel: ${extra.budget}');
      if (extra.thingsToDo.isNotEmpty) {
        buffer.writeln('Top things to do: ${extra.thingsToDo.take(3).join(', ')}.');
      }
      if (extra.visitPlan.isNotEmpty) {
        final firstStops = extra.visitPlan.take(3).map((stop) {
          return '${stop.time} - ${stop.title}: ${stop.details} (${stop.costNote})';
        }).join(' ');
        buffer.writeln('Suggested flow: $firstStops');
      }
      if (extra.quickTips.isNotEmpty) {
        buffer.writeln('Useful tips: ${extra.quickTips.take(2).join(' ')}');
      }
    } else {
      buffer.writeln();
      buffer.writeln(
        'This is a good stop if you want a ${place.type.toLowerCase()} experience without forcing the whole trip around one theme.',
      );
    }

    return buffer.toString().trim();
  }
}

class _PlaceMatch {
  final String name;

  const _PlaceMatch({
    required this.name,
  });
}
