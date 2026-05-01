import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/places_data.dart';
import '../models/place_model.dart';
import '../services/location_service.dart';
import '../services/map_service.dart';
import '../theme/app_theme.dart';
import '../utils/distance_utils.dart';
import '../widgets/place_photo.dart';

class SmartMapScreen extends StatefulWidget {
  const SmartMapScreen({super.key});

  @override
  State<SmartMapScreen> createState() => _SmartMapScreenState();
}

class _SmartMapScreenState extends State<SmartMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _searchDebounce;

  bool _hasConnection = true;
  bool _offlineMode = false;
  bool _isSearching = false;
  bool _isRouting = false;
  Position? userPosition;
  PlaceModel? selectedPlace;
  List<MapSearchResult> _searchResults = const [];
  MapRouteResult? _currentRoute;
  MapTravelMode _travelMode = MapTravelMode.driving;

  bool get _usesOnlineTiles => !_offlineMode && _hasConnection;

  @override
  void initState() {
    super.initState();
    selectedPlace = seedPlaces.isEmpty ? null : seedPlaces.first;
    _checkConnection();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnection);
    _loadLocation();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    _updateConnection(connectivity);
  }

  void _updateConnection(List<ConnectivityResult> results) {
    final offline =
        results.length == 1 && results.first == ConnectivityResult.none;
    if (!mounted) return;
    setState(() => _hasConnection = !offline);
    if (!offline && !_offlineMode) {
      _updateRoute();
    }
    if (offline) {
      setState(() => _currentRoute = null);
    }
  }

  Future<void> _loadLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => userPosition = position);
      _updateRoute();
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _selectPlace(PlaceModel place, {double zoom = 11}) async {
    setState(() => selectedPlace = place);
    _mapController.move(LatLng(place.lat, place.lng), zoom);
    await _updateRoute();
  }

  void _setOfflineMode(bool value) {
    setState(() {
      _offlineMode = value;
      if (value) {
        _currentRoute = null;
      }
    });
    if (value && _mapController.camera.zoom > 8) {
      _mapController.move(_mapController.camera.center, 7);
    }
    if (!value) {
      _checkConnection();
      _updateRoute();
    }
  }

  void _setTravelMode(MapTravelMode mode) {
    if (_travelMode == mode) return;
    setState(() => _travelMode = mode);
    _updateRoute();
  }

  void _centerSriLanka() {
    _mapController.move(LatLng(7.8731, 80.7718), 7);
  }

  void _centerUser() {
    final position = userPosition;
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current location is unavailable")),
      );
      return;
    }

    _mapController.move(LatLng(position.latitude, position.longitude), 13);
  }

  void _zoomBy(double amount) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + amount);
  }

  Future<void> _updateRoute() async {
    final position = userPosition;
    final place = selectedPlace;
    if (position == null || place == null || !_usesOnlineTiles) {
      if (!mounted) return;
      setState(() {
        _currentRoute = null;
        _isRouting = false;
      });
      return;
    }

    setState(() => _isRouting = true);

    final route = await MapService.fetchRoute(
      start: LatLng(position.latitude, position.longitude),
      end: LatLng(place.lat, place.lng),
      mode: _travelMode,
    );

    if (!mounted) return;
    setState(() {
      _currentRoute = route;
      _isRouting = false;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = const [];
      });
      return;
    }

    setState(() => _isSearching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 260), () async {
      final results = await MapService.searchLocations(query);
      if (!mounted || _searchController.text.trim() != query.trim()) {
        return;
      }
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _applySearchResult(MapSearchResult result) async {
    FocusScope.of(context).unfocus();
    _searchController.text = result.title;
    setState(() {
      _searchResults = const [];
      _isSearching = false;
    });
    final place = MapService.toPlaceModel(result);
    await _selectPlace(place, zoom: 13);
  }

  double? _distanceToSelected() {
    if (_currentRoute != null) {
      return _currentRoute!.distanceKm;
    }

    final position = userPosition;
    final place = selectedPlace;
    if (position == null || place == null) return null;

    return DistanceUtils.calculateDistance(
      position.latitude,
      position.longitude,
      place.lat,
      place.lng,
    );
  }

  int? _routeMinutes() {
    final route = _currentRoute;
    if (route == null) {
      return null;
    }
    final minutes = route.duration.inMinutes;
    return minutes <= 0 ? 1 : minutes;
  }

  List<LatLng> get _routePoints {
    if (_currentRoute != null && _currentRoute!.points.isNotEmpty) {
      return _currentRoute!.points;
    }

    final position = userPosition;
    final place = selectedPlace;
    if (position == null || place == null) return [];

    return [
      LatLng(position.latitude, position.longitude),
      LatLng(place.lat, place.lng),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final place = selectedPlace;
    final distance = _distanceToSelected();
    final showFloatingControls = _searchResults.isEmpty && !_isSearching;

    return Scaffold(
      backgroundColor: const Color(0xffEAF1EE),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(7.8731, 80.7718),
              initialZoom: 7,
              minZoom: 5,
              maxZoom: _usesOnlineTiles ? 18 : 9,
            ),
            children: [
              _usesOnlineTiles ? _onlineTiles() : _offlineTiles(),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: _currentRoute == null ? 4 : 5.5,
                      color: const Color(0xff1A73E8),
                    ),
                  ],
                ),
              MarkerLayer(markers: _markers()),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Column(
                  children: [
                    _MapHeader(
                      isOnline: _usesOnlineTiles,
                      offlineMode: _offlineMode,
                      hasConnection: _hasConnection,
                      onOfflineChanged: _setOfflineMode,
                      onBack: () => Navigator.pop(context),
                      onRefresh: _checkConnection,
                    ),
                    const SizedBox(height: 10),
                    _SearchCard(
                      controller: _searchController,
                      isSearching: _isSearching,
                      searchResults: _searchResults,
                      travelMode: _travelMode,
                      onChanged: _onSearchChanged,
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchResults = const []);
                      },
                      onSearchSelected: _applySearchResult,
                      onTravelModeChanged: _setTravelMode,
                    ),
                    if (_searchResults.isEmpty) ...[
                      const SizedBox(height: 10),
                      _PlaceSelector(
                        selectedPlace: selectedPlace,
                        onSelected: (place) => _selectPlace(place),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showFloatingControls)
            Positioned(
              right: 14,
              top: 296,
              child: Column(
                children: [
                  _MapButton(
                    tooltip: "My location",
                    icon: Icons.my_location,
                    onPressed: _centerUser,
                  ),
                  const SizedBox(height: 10),
                  _MapButton(
                    tooltip: "Zoom in",
                    icon: Icons.add,
                    onPressed: () => _zoomBy(1),
                  ),
                  const SizedBox(height: 10),
                  _MapButton(
                    tooltip: "Zoom out",
                    icon: Icons.remove,
                    onPressed: () => _zoomBy(-1),
                  ),
                  const SizedBox(height: 10),
                  _MapButton(
                    tooltip: "Reset compass",
                    icon: Icons.explore,
                    onPressed: _centerSriLanka,
                  ),
                ],
              ),
            ),
          if (showFloatingControls)
            Positioned(
              left: 14,
              top: 296,
              child: _ModeBadge(
                isOnline: _usesOnlineTiles,
                offlineMode: _offlineMode,
                hasConnection: _hasConnection,
              ),
            ),
          if (place != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SelectedPlaceCard(
                    place: place,
                    distanceKm: distance,
                    routeMinutes: _routeMinutes(),
                    hasRoute: _routePoints.isNotEmpty,
                    usingRoadRoute: _currentRoute != null,
                    isRouting: _isRouting,
                    travelMode: _travelMode,
                    onRoute: _updateRoute,
                    onMyLocation: _centerUser,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  TileLayer _onlineTiles() {
    return TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: 'com.example.tourist_guide',
    );
  }

  TileLayer _offlineTiles() {
    return TileLayer(
      tileProvider: AssetTileProvider(),
      urlTemplate: "assets/maps/sri_lanka_tiles_osm/tiles/{z}/{x}/{y}.png",
    );
  }

  List<Marker> _markers() {
    final markers = <Marker>[
      ...seedPlaces.map((place) {
        final selected = selectedPlace?.name == place.name;
        return Marker(
          point: LatLng(place.lat, place.lng),
          width: selected ? 58 : 48,
          height: selected ? 58 : 48,
          child: GestureDetector(
            onTap: () => _selectPlace(place),
            child: Tooltip(
              message: place.name,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: selected
                        ? const Color(0xff1A73E8)
                        : const Color(0xffEA4335),
                    size: selected ? 54 : 44,
                  ),
                  Positioned(
                    top: selected ? 12 : 10,
                    child: Icon(
                      _iconForPlace(place.type),
                      color: Colors.white,
                      size: selected ? 17 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ];

    final position = userPosition;
    if (position != null) {
      markers.add(
        Marker(
          point: LatLng(position.latitude, position.longitude),
          width: 52,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff1A73E8).withAlpha(35),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xff1A73E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Color(0x33000000),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  IconData _iconForPlace(String type) {
    switch (type.toLowerCase()) {
      case "beach":
        return Icons.beach_access;
      case "heritage":
        return Icons.account_balance;
      case "culture":
        return Icons.temple_buddhist;
      case "hill country":
        return Icons.landscape;
      case "wildlife":
        return Icons.park;
      case "city":
        return Icons.location_city;
      case "nature":
        return Icons.park;
      case "hiking":
        return Icons.terrain;
      case "search":
        return Icons.search;
      default:
        return Icons.place;
    }
  }
}

class _MapHeader extends StatelessWidget {
  final bool isOnline;
  final bool offlineMode;
  final bool hasConnection;
  final ValueChanged<bool> onOfflineChanged;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _MapHeader({
    required this.isOnline,
    required this.offlineMode,
    required this.hasConnection,
    required this.onOfflineChanged,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final status = isOnline
        ? "Online map"
        : offlineMode
            ? "Offline map"
            : "No internet - offline map";
    final destinationCount = seedPlaces.length;

    return Material(
      color: Colors.white,
      elevation: 5,
      shadowColor: Colors.black.withAlpha(35),
      borderRadius: BorderRadius.circular(26),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: "Back",
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xff1A73E8), Color(0xff16A34A)],
                ),
              ),
              child: const Icon(Icons.explore, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Map",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.midnight,
                    ),
                  ),
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasConnection || offlineMode
                          ? Colors.black54
                          : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "$destinationCount highlighted destinations",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: "Refresh connection",
              onPressed: onRefresh,
              icon: const Icon(Icons.sync),
            ),
            _MapSwitch(
              offlineMode: offlineMode,
              onChanged: onOfflineChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final List<MapSearchResult> searchResults;
  final MapTravelMode travelMode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<MapSearchResult> onSearchSelected;
  final ValueChanged<MapTravelMode> onTravelModeChanged;

  const _SearchCard({
    required this.controller,
    required this.isSearching,
    required this.searchResults,
    required this.travelMode,
    required this.onChanged,
    required this.onClear,
    required this.onSearchSelected,
    required this.onTravelModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 5,
      shadowColor: Colors.black.withAlpha(25),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.midnight),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search locations in Sri Lanka",
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: controller.text.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: "Clear search",
                        onPressed: onClear,
                        icon: const Icon(Icons.close, color: Colors.black54),
                      ),
                filled: true,
                fillColor: const Color(0xffF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Route mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnight,
                  ),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Drive"),
                  selected: travelMode == MapTravelMode.driving,
                  onSelected: (_) => onTravelModeChanged(MapTravelMode.driving),
                  labelStyle: TextStyle(
                    color: travelMode == MapTravelMode.driving
                        ? Colors.white
                        : AppColors.midnight,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedColor: const Color(0xff1A73E8),
                  backgroundColor: const Color(0xffE8EEF8),
                  side: BorderSide.none,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Walk"),
                  selected: travelMode == MapTravelMode.walking,
                  onSelected: (_) => onTravelModeChanged(MapTravelMode.walking),
                  labelStyle: TextStyle(
                    color: travelMode == MapTravelMode.walking
                        ? Colors.white
                        : AppColors.midnight,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedColor: const Color(0xff16A34A),
                  backgroundColor: const Color(0xffEAF5EE),
                  side: BorderSide.none,
                ),
              ],
            ),
            if (isSearching) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (searchResults.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...searchResults.take(3).map(
                (result) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: result.isKnownPlace
                        ? const Color(0xffE8F5E9)
                        : const Color(0xffE8F0FE),
                    child: Icon(
                      result.isKnownPlace
                          ? Icons.travel_explore
                          : Icons.location_on,
                      color: result.isKnownPlace
                          ? const Color(0xff166534)
                          : const Color(0xff1A73E8),
                      size: 18,
                    ),
                  ),
                  title: Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.midnight,
                    ),
                  ),
                  subtitle: Text(
                    result.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  onTap: () => onSearchSelected(result),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapSwitch extends StatelessWidget {
  final bool offlineMode;
  final ValueChanged<bool> onChanged;

  const _MapSwitch({
    required this.offlineMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: offlineMode ? const Color(0xffFFF4E5) : const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            offlineMode ? "Offline" : "Auto",
            style: TextStyle(
              color: offlineMode
                  ? const Color(0xffB45309)
                  : const Color(0xff166534),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Switch.adaptive(
            value: offlineMode,
            onChanged: onChanged,
            activeColor: const Color(0xffF59E0B),
          ),
        ],
      ),
    );
  }
}

class _PlaceSelector extends StatelessWidget {
  final PlaceModel? selectedPlace;
  final ValueChanged<PlaceModel> onSelected;

  const _PlaceSelector({
    required this.selectedPlace,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: seedPlaces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final place = seedPlaces[index];
          final selected = selectedPlace?.name == place.name;
          return ChoiceChip(
            avatar: Icon(
              Icons.travel_explore,
              size: 18,
              color: selected ? Colors.white : const Color(0xff166534),
            ),
            label: Text(place.name),
            selected: selected,
            onSelected: (_) => onSelected(place),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xff16A34A),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: selected ? const Color(0xff16A34A) : Colors.black12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          );
        },
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final bool isOnline;
  final bool offlineMode;
  final bool hasConnection;

  const _ModeBadge({
    required this.isOnline,
    required this.offlineMode,
    required this.hasConnection,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOnline
        ? const Color(0xff16A34A)
        : offlineMode
            ? const Color(0xffF59E0B)
            : const Color(0xffEA4335);
    final text = isOnline
        ? "Live"
        : offlineMode
            ? "Saved"
            : "Offline";

    return Material(
      color: color,
      elevation: 4,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasConnection && !offlineMode ? Icons.cloud_done : Icons.map,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withAlpha(45),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xff202124)),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  final PlaceModel place;
  final double? distanceKm;
  final int? routeMinutes;
  final bool hasRoute;
  final bool usingRoadRoute;
  final bool isRouting;
  final MapTravelMode travelMode;
  final Future<void> Function() onRoute;
  final VoidCallback onMyLocation;

  const _SelectedPlaceCard({
    required this.place,
    required this.distanceKm,
    required this.routeMinutes,
    required this.hasRoute,
    required this.usingRoadRoute,
    required this.isRouting,
    required this.travelMode,
    required this.onRoute,
    required this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceKm == null
        ? "Enable location for distance"
        : "${distanceKm!.toStringAsFixed(1)} km away";
    final routeText = isRouting
        ? "Finding road route..."
        : routeMinutes == null
            ? "Route preview"
            : "${routeMinutes!} min ${travelMode == MapTravelMode.driving ? 'drive' : 'walk'}";
    final routeStatus = usingRoadRoute
        ? "Road route ready"
        : hasRoute
            ? "Straight-line preview"
            : "Pick a destination";

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withAlpha(50),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                PlacePhoto(
                  placeName: place.name,
                  assetPath: place.image,
                  width: 86,
                  height: 86,
                  borderRadius: BorderRadius.circular(18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.midnight,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TypePill(type: place.type),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        place.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1.25,
                          color: AppColors.midnight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoChip(
                            icon: Icons.near_me,
                            text: distanceText,
                            color: const Color(0xff1A73E8),
                          ),
                          _InfoChip(
                            icon: travelMode == MapTravelMode.driving
                                ? Icons.directions_car
                                : Icons.directions_walk,
                            text: routeText,
                            color: const Color(0xff16A34A),
                          ),
                          _InfoChip(
                            icon: usingRoadRoute ? Icons.alt_route : Icons.route,
                            text: routeStatus,
                            color: const Color(0xffF59E0B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isRouting ? null : () => onRoute(),
                    icon: Icon(usingRoadRoute ? Icons.sync : Icons.alt_route),
                    label: Text(isRouting ? "Routing..." : "Route"),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff1A73E8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMyLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text("My location"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff166534),
                      side: const BorderSide(color: Color(0xff16A34A)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;

  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xff166534),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
