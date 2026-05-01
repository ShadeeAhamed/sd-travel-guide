import 'package:flutter/material.dart';

import '../data/place_photo_data.dart';
import '../services/place_image_service.dart';

class PlacePhoto extends StatelessWidget {
  final String placeName;
  final String assetPath;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? wikipediaTitle;
  final double? width;
  final double? height;
  final bool allowAssetFallback;

  const PlacePhoto({
    super.key,
    required this.placeName,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.wikipediaTitle,
    this.width,
    this.height,
    this.allowAssetFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    final localAsset = allowAssetFallback
        ? localCoverAssetForPlace(placeName) ?? assetPath
        : null;
    final hasLocalAsset =
        localAsset != null && hasDedicatedLocalPhotos(placeName);

    Widget child;
    if (hasLocalAsset) {
      child = Image.asset(
        localAsset,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      child = FutureBuilder<String?>(
        future: PlaceImageService.resolveImageUrl(
          placeName,
          wikipediaTitle: wikipediaTitle,
        ),
        builder: (context, snapshot) {
          final imageUrl = snapshot.data;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            return Image.network(
              imageUrl,
              fit: fit,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, image, loadingProgress) {
                if (loadingProgress == null) {
                  return image;
                }
                return _placeholder();
              },
              errorBuilder: (_, __, ___) => _fallback(),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _placeholder();
          }

          return _fallback();
        },
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    if (width != null || height != null) {
      child = SizedBox(
        width: width,
        height: height,
        child: child,
      );
    }

    return child;
  }

  Widget _fallback() {
    if (allowAssetFallback) {
      return Image.asset(
        assetPath,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xffDCE7E1),
      alignment: Alignment.center,
      child: const Icon(
        Icons.landscape,
        color: Color(0xff48645A),
        size: 34,
      ),
    );
  }
}
