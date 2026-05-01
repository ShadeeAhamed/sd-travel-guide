import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/place_extra_data.dart';
import '../data/place_photo_data.dart';
import '../database/places_db.dart';
import '../models/place_model.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/distance_utils.dart';
import '../utils/nearby_places_helper.dart';
import '../widgets/place_photo.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late PlaceModel place;
  Position? user;
  List<PlaceModel> nearby = [];

  List<String> get _gallery {
    return localGalleryAssetsForPlace(place.name);
  }

  @override
  void initState() {
    super.initState();
    place = widget.place;
    _init();
  }

  Future<void> _init() async {
    Position? pos;
    try {
      pos = await LocationService.getCurrentLocation();
    } catch (e) {
      debugPrint("Location error: $e");
    }

    final all = await PlacesDB.instance.getPlaces();
    final refreshedPlace = all.firstWhere(
      (p) => p.id == place.id || p.name == place.name,
      orElse: () => place,
    );
    final filtered = NearbyPlacesHelper.getNearbyPlaces(
      allPlaces: all,
      currentPlace: refreshedPlace,
      radiusKm: 120,
    ).take(3).toList();

    if (!mounted) return;
    setState(() {
      user = pos;
      place = refreshedPlace;
      nearby = filtered;
    });
  }

  Future<void> _toggleFavourite() async {
    if (place.id == null) return;

    final nextValue = !place.isFavourite;
    await PlacesDB.instance.toggleFavourite(place.id!, nextValue);

    if (!mounted) return;
    setState(() => place = place.copyWith(isFavourite: nextValue));
  }

  @override
  Widget build(BuildContext context) {
    final extra = placeExtraData[place.name];
    final km = user == null
        ? null
        : DistanceUtils.calculateDistance(
            user!.latitude,
            user!.longitude,
            place.lat,
            place.lng,
          );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            title: Text(place.name),
            actions: [
              IconButton(
                tooltip: place.isFavourite ? "Remove saved" : "Save place",
                onPressed: _toggleFavourite,
                icon: Icon(
                  place.isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: place.isFavourite ? Colors.redAccent : null,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PlacePhoto(
                    placeName: place.name,
                    assetPath: place.image,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  if (extra != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(95),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          extra.headline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummarySection(place: place, distanceKm: km, extra: extra),
                  if (_gallery.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _GallerySection(images: _gallery),
                  ],
                  const SizedBox(height: 20),
                  _MapSection(place: place, user: user),
                  if (extra != null) ...[
                    const SizedBox(height: 20),
                    _TripPlannerSection(extra: extra),
                    const SizedBox(height: 20),
                    _TipsSection(extra: extra),
                  ],
                  if (nearby.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _NearbySection(nearby: nearby),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final PlaceModel place;
  final double? distanceKm;
  final PlaceExtraInfo? extra;

  const _SummarySection({
    required this.place,
    required this.distanceKm,
    required this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _InfoChip(icon: Icons.travel_explore, label: place.type),
            if (distanceKm != null) ...[
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.place,
                label: "${distanceKm!.toStringAsFixed(1)} km away",
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Text(
          place.description,
          style: const TextStyle(fontSize: 16, height: 1.45),
        ),
        if (extra != null) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _GuideBadge(
                icon: Icons.schedule,
                title: "Ideal stay",
                value: extra!.idealDuration,
              ),
              _GuideBadge(
                icon: Icons.payments,
                title: "Budget",
                value: extra!.budget,
              ),
              _GuideBadge(
                icon: Icons.calendar_month,
                title: "Best season",
                value: extra!.bestSeason,
              ),
            ],
          ),
        ],
        if (distanceKm != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _EtaCard(
                  icon: Icons.directions_walk,
                  label: "Walk",
                  value: "${DistanceUtils.walkingETA(distanceKm!).round()} min",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EtaCard(
                  icon: Icons.directions_car,
                  label: "Drive",
                  value: "${DistanceUtils.drivingETA(distanceKm!).round()} min",
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GallerySection extends StatelessWidget {
  final List<String> images;

  const _GallerySection({required this.images});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Gallery"),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  images[index],
                  width: 128,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MapSection extends StatelessWidget {
  final PlaceModel place;
  final Position? user;

  const _MapSection({required this.place, required this.user});

  @override
  Widget build(BuildContext context) {
    final points = user == null
        ? <LatLng>[]
        : [
            LatLng(user!.latitude, user!.longitude),
            LatLng(place.lat, place.lng),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Map"),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 230,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(place.lat, place.lng),
                initialZoom: 11,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.tourist_guide',
                ),
                if (points.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        strokeWidth: 4,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (user != null)
                      Marker(
                        point: LatLng(user!.latitude, user!.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.person_pin_circle,
                          size: 38,
                          color: Colors.blue,
                        ),
                      ),
                    Marker(
                      point: LatLng(place.lat, place.lng),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TripPlannerSection extends StatelessWidget {
  final PlaceExtraInfo extra;

  const _TripPlannerSection({required this.extra});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Plan Your Visit"),
        const SizedBox(height: 10),
        _DetailRow(icon: Icons.wb_sunny_outlined, text: extra.bestTime),
        _DetailRow(icon: Icons.directions_bus, text: extra.transportTip),
        _DetailRow(icon: Icons.tips_and_updates, text: extra.localTip),
        const SizedBox(height: 12),
        const Text(
          "Suggested flow",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...extra.visitPlan.map(
          (stop) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _VisitStopCard(stop: stop),
          ),
        ),
      ],
    );
  }
}

class _TipsSection extends StatelessWidget {
  final PlaceExtraInfo extra;

  const _TipsSection({required this.extra});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Useful Tips"),
        const SizedBox(height: 10),
        ...extra.quickTips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(tip)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Nearby ideas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: extra.nearbyPlaces
              .map(
                (place) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    place,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _NearbySection extends StatelessWidget {
  final List<PlaceModel> nearby;

  const _NearbySection({required this.nearby});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Nearby Places"),
        const SizedBox(height: 10),
        ...nearby.map(
          (place) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PlacePhoto(
                  placeName: place.name,
                  assetPath: place.image,
                  width: 56,
                  height: 56,
                ),
              ),
              title: Text(
                place.name,
                style: const TextStyle(color: AppColors.midnight),
              ),
              subtitle: Text(
                place.type,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaceDetailsScreen(place: place),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.deepPurple),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _GuideBadge({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withAlpha(15),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.midnight,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EtaCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.midnight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _VisitStopCard extends StatelessWidget {
  final VisitStop stop;

  const _VisitStopCard({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withAlpha(10),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  stop.time,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stop.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.midnight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stop.details,
            style: const TextStyle(
              height: 1.35,
              color: AppColors.midnight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stop.costNote,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
