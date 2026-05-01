import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/place_extra_data.dart';
import '../data/places_data.dart';
import '../database/places_db.dart';
import '../models/place_model.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/distance_utils.dart';
import '../widgets/place_photo.dart';
import 'place_details_screen.dart';

enum _PlaceSortMode {
  featured,
  nearest,
  alphabetical,
}

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  List<PlaceModel> places = [];
  Position? userPosition;
  bool loading = true;
  bool showFavouritesOnly = false;
  String selectedType = "All";
  String query = "";
  _PlaceSortMode sortMode = _PlaceSortMode.featured;

  List<String> get _types {
    final types = places.map((p) => p.type).toSet().toList()..sort();
    return ["All", ...types];
  }

  List<PlaceModel> get _filteredPlaces {
    final normalizedQuery = query.trim().toLowerCase();

    final filtered = places.where((place) {
      final matchesSearch = normalizedQuery.isEmpty ||
          place.name.toLowerCase().contains(normalizedQuery) ||
          place.description.toLowerCase().contains(normalizedQuery) ||
          place.type.toLowerCase().contains(normalizedQuery);
      final matchesType = selectedType == "All" || place.type == selectedType;
      final matchesFavourite = !showFavouritesOnly || place.isFavourite;

      return matchesSearch && matchesType && matchesFavourite;
    }).toList();

    switch (sortMode) {
      case _PlaceSortMode.nearest:
        filtered.sort(
          (a, b) => _distanceSortValue(a).compareTo(_distanceSortValue(b)),
        );
        break;
      case _PlaceSortMode.alphabetical:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _PlaceSortMode.featured:
        filtered.sort((a, b) {
          final aRank = featuredPlaceNames.contains(a.name) ? 0 : 1;
          final bRank = featuredPlaceNames.contains(b.name) ? 0 : 1;
          if (aRank != bRank) return aRank.compareTo(bRank);
          return a.name.compareTo(b.name);
        });
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _loadLocation();
  }

  Future<void> _loadPlaces() async {
    final db = PlacesDB.instance;
    await db.seedPlaces(seedPlaces);
    final data = await db.getPlaces();

    if (!mounted) return;
    setState(() {
      places = data;
      loading = false;
    });
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => userPosition = pos);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _toggleFavourite(PlaceModel place) async {
    if (place.id == null) return;

    final nextValue = !place.isFavourite;
    await PlacesDB.instance.toggleFavourite(place.id!, nextValue);

    if (!mounted) return;
    setState(() {
      places = places
          .map((p) => p.id == place.id ? p.copyWith(isFavourite: nextValue) : p)
          .toList();
    });
  }

  double? _distanceFor(PlaceModel place) {
    final position = userPosition;
    if (position == null) return null;

    return DistanceUtils.calculateDistance(
      position.latitude,
      position.longitude,
      place.lat,
      place.lng,
    );
  }

  double _distanceSortValue(PlaceModel place) {
    final distance = _distanceFor(place);
    return distance ?? double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = _filteredPlaces;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Places"),
        actions: [
          IconButton(
            tooltip: showFavouritesOnly
                ? "Show all places"
                : "Show saved places only",
            onPressed: () {
              setState(() => showFavouritesOnly = !showFavouritesOnly);
            },
            icon: Icon(
              showFavouritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPlaces,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SearchField(
                    onChanged: (value) => setState(() => query = value),
                  ),
                  const SizedBox(height: 12),
                  _TypeFilters(
                    types: _types,
                    selectedType: selectedType,
                    onSelected: (type) => setState(() => selectedType = type),
                  ),
                  const SizedBox(height: 16),
                  _PlacesOverview(
                    totalCount: places.length,
                    visibleCount: filteredPlaces.length,
                    favouriteCount:
                        places.where((place) => place.isFavourite).length,
                  ),
                  const SizedBox(height: 12),
                  _SortBar(
                    sortMode: sortMode,
                    onChanged: (mode) => setState(() => sortMode = mode),
                  ),
                  const SizedBox(height: 12),
                  if (filteredPlaces.isEmpty)
                    const _EmptyState()
                  else
                    ...filteredPlaces.map(
                      (place) => _PlaceCard(
                        place: place,
                        distanceKm: _distanceFor(place),
                        extra: placeExtraData[place.name],
                        featured: featuredPlaceNames.contains(place.name),
                        onFavourite: () => _toggleFavourite(place),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailsScreen(place: place),
                            ),
                          );
                          _loadPlaces();
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.midnight),
      decoration: InputDecoration(
        hintText: "Search places, beaches, heritage...",
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _TypeFilters extends StatelessWidget {
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onSelected;

  const _TypeFilters({
    required this.types,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          return ChoiceChip(
            label: Text(type),
            selected: selectedType == type,
            onSelected: (_) => onSelected(type),
          );
        },
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final double? distanceKm;
  final PlaceExtraInfo? extra;
  final bool featured;
  final VoidCallback onFavourite;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.place,
    required this.distanceKm,
    required this.extra,
    required this.featured,
    required this.onFavourite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PlacePhoto(
                  placeName: place.name,
                  assetPath: place.image,
                  width: double.infinity,
                  height: 170,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: place.isFavourite ? "Saved" : "Save place",
                      onPressed: onFavourite,
                      icon: Icon(
                        place.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: place.isFavourite ? Colors.red : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (featured) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Must visit",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              place.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.midnight,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _TypePill(type: place.type),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.35,
                      color: AppColors.midnight,
                    ),
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top highlight",
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            extra!.headline,
                            style: const TextStyle(
                              height: 1.3,
                              color: AppColors.midnight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.place,
                            size: 18,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceKm == null
                                ? "Location unavailable"
                                : "${distanceKm!.toStringAsFixed(1)} km away",
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (extra != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              extra!.bestSeason,
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
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

class _PlacesOverview extends StatelessWidget {
  final int totalCount;
  final int visibleCount;
  final int favouriteCount;

  const _PlacesOverview({
    required this.totalCount,
    required this.visibleCount,
    required this.favouriteCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.travel_explore, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sri Lanka highlights",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$visibleCount shown now - $totalCount total places - $favouriteCount saved",
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.3,
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

class _SortBar extends StatelessWidget {
  final _PlaceSortMode sortMode;
  final ValueChanged<_PlaceSortMode> onChanged;

  const _SortBar({
    required this.sortMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Sort by",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text("Featured"),
                selected: sortMode == _PlaceSortMode.featured,
                onSelected: (_) => onChanged(_PlaceSortMode.featured),
              ),
              ChoiceChip(
                label: const Text("Nearest"),
                selected: sortMode == _PlaceSortMode.nearest,
                onSelected: (_) => onChanged(_PlaceSortMode.nearest),
              ),
              ChoiceChip(
                label: const Text("A-Z"),
                selected: sortMode == _PlaceSortMode.alphabetical,
                onSelected: (_) => onChanged(_PlaceSortMode.alphabetical),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;

  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: const [
          Icon(Icons.travel_explore, size: 64, color: Colors.deepPurple),
          SizedBox(height: 12),
          Text("No places match your search"),
        ],
      ),
    );
  }
}
