import 'package:flutter/material.dart';

import '../data/places_data.dart';
import '../models/place_model.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/user_preference_engine.dart';
import '../theme/app_theme.dart';

class ItineraryBuilderScreen extends StatefulWidget {
  final AppUser user;

  const ItineraryBuilderScreen({super.key, required this.user});

  @override
  State<ItineraryBuilderScreen> createState() => _ItineraryBuilderScreenState();
}

class _ItineraryBuilderScreenState extends State<ItineraryBuilderScreen> {
  late TravelerPreferences _draft;
  late List<ItineraryDayPlan> _plan;
  late List<PlaceModel> _destinations;
  int _days = 3;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _draft = widget.user.preferences;
    _destinations = UserPreferenceEngine.suggestedDestinations(_draft, _days);
    _plan = List.generate(
      _destinations.length,
      (index) => UserPreferenceEngine.buildDayPlanForPlace(
        place: _destinations[index],
        preferences: _draft,
        dayNumber: index + 1,
      ),
    );
  }

  void _rebuildItinerary({bool trackEvent = true}) {
    if (trackEvent) {
      AuthService.instance.updateBehaviorCounter(
        widget.user.id,
        'itinerary_generations',
      );
    }

    final destinations = UserPreferenceEngine.suggestedDestinations(
      _draft,
      _days,
    );

    setState(() {
      _destinations = destinations;
      _plan = List.generate(
        destinations.length,
        (index) => UserPreferenceEngine.buildDayPlanForPlace(
          place: destinations[index],
          preferences: _draft,
          dayNumber: index + 1,
        ),
      );
      _selectedDay = (_selectedDay.clamp(0, _plan.length - 1)) as int;
    });
  }

  void _swapDestination(String placeName) {
    final place = seedPlaces.firstWhere((item) => item.name == placeName);
    setState(() {
      _destinations[_selectedDay] = place;
      _plan[_selectedDay] = UserPreferenceEngine.buildDayPlanForPlace(
        place: place,
        preferences: _draft,
        dayNumber: _selectedDay + 1,
      );
    });
  }

  void _reorderStops(int oldIndex, int newIndex) {
    final dayPlan = _plan[_selectedDay];
    final updatedStops = [...dayPlan.stops];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = updatedStops.removeAt(oldIndex);
    updatedStops.insert(newIndex, item);

    setState(() {
      _plan[_selectedDay] = ItineraryDayPlan(
        dayNumber: dayPlan.dayNumber,
        placeName: dayPlan.placeName,
        theme: dayPlan.theme,
        transportHint: dayPlan.transportHint,
        foodHint: dayPlan.foodHint,
        budgetHint: dayPlan.budgetHint,
        stops: updatedStops,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeDay = _plan[_selectedDay];
    final suggestions = UserPreferenceEngine.topMatches(_draft)
        .where((place) => place.name != activeDay.placeName)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        title: const Text('Dynamic itinerary'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                      children: [
                        Text(
                          'Zero-Stress Mode',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate a route that fits your mood, then swap each day to a different destination whenever you want.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withAlpha(170),
                                    height: 1.35,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Trip length: $_days day${_days == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Slider(
                          min: 1,
                          max: 7,
                          divisions: 6,
                          value: _days.toDouble(),
                          onChanged: (value) {
                            setState(() => _days = value.round());
                          },
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: TravelMood.values.map((mood) {
                            final selected = _draft.mood == mood;
                            return ChoiceChip(
                              label:
                                  Text(TravelerPreferences.labelForMood(mood)),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _draft = _draft.copyWith(mood: mood);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.midnight,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: _rebuildItinerary,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text(
                            'Generate itinerary',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_plan.length, (index) {
                      final day = _plan[index];
                      return ChoiceChip(
                        label: Text('Day ${day.dayNumber}'),
                        selected: _selectedDay == index,
                        onSelected: (_) {
                          setState(() => _selectedDay = index);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151D30),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeDay.theme,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Change the base stop for this day any time. Your route updates immediately.',
                          style: const TextStyle(
                            height: 1.35,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: activeDay.placeName,
                          dropdownColor: AppColors.obsidian,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Destination',
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(
                              Icons.place_outlined,
                              color: AppColors.gold,
                            ),
                          ),
                          items: seedPlaces
                              .map(
                                (place) => DropdownMenuItem<String>(
                                  value: place.name,
                                  child: Text(place.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            _swapDestination(value);
                          },
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Quick swaps',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: suggestions
                                .map(
                                  (place) => ActionChip(
                                    label: Text(place.name),
                                    onPressed: () => _swapDestination(place.name),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _RouteHintRow(
                          icon: Icons.route,
                          title: 'Transport',
                          body: activeDay.transportHint,
                        ),
                        const SizedBox(height: 12),
                        _RouteHintRow(
                          icon: Icons.restaurant,
                          title: 'Food',
                          body: activeDay.foodHint,
                        ),
                        const SizedBox(height: 12),
                        _RouteHintRow(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Budget feel',
                          body: activeDay.budgetHint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Drag the stops below into your preferred order. The day updates instantly if you switch from Colombo to Nuwara Eliya or anywhere else.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom + 96,
                ),
                itemCount: activeDay.stops.length,
                onReorder: _reorderStops,
                itemBuilder: (context, index) {
                  final stop = activeDay.stops[index];
                  return Container(
                    key: ValueKey(
                      '${activeDay.dayNumber}-${activeDay.placeName}-${stop.title}-$index',
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          color: Colors.black.withAlpha(14),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            stop.timing,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.midnight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.midnight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stop.summary,
                                style: const TextStyle(
                                  height: 1.35,
                                  color: AppColors.midnight,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                stop.cost,
                                style: const TextStyle(
                                  color: AppColors.pine,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.drag_handle, color: AppColors.midnight),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteHintRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _RouteHintRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.gold.withAlpha(16),
          child: Icon(icon, color: AppColors.gold, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
