const Map<String, String> wikipediaPlaceTitles = {
  'Ella': 'Nine Arch Bridge',
  'Sigiriya': 'Sigiriya',
  'Kandy': 'Temple of the Tooth',
  'Galle': 'Galle Fort',
  'Mirissa': 'Weligama',
  'Nuwara Eliya': 'Hakgala Botanical Garden',
  'Yala National Park': 'Yala National Park',
  'Trincomalee': 'Nilaveli',
  'Arugam Bay': 'Arugam Bay',
  'Colombo': 'Galle Face Green',
  'Anuradhapura': 'Anuradhapura',
  'Polonnaruwa': 'Polonnaruwa Vatadage',
  'Dambulla': 'Dambulla cave temple',
  'Unawatuna': 'Unawatuna',
  'Hikkaduwa': 'Hikkaduwa',
  'Bentota': 'Bentota',
  'Jaffna': 'Jaffna',
  'Horton Plains': 'Horton Plains National Park',
  'Pidurangala': 'Pidurangala',
  'Udawalawe': 'Udawalawe National Park',
};

const Map<String, String> localCoverAssets = {
  'Ella': 'assets/places/ella/cover.jpg',
  'Sigiriya': 'assets/places/sigiriya/cover.jpeg',
  'Kandy': 'assets/places/kandy/cover.jpg',
  'Galle': 'assets/places/galle/cover.jpg',
  'Mirissa': 'assets/places/mirissa/cover.jpg',
  'Nuwara Eliya': 'assets/places/nuwara_eliya/cover.jpg',
  'Yala National Park': 'assets/places/yala_national_park/cover.jpg',
  'Trincomalee': 'assets/places/trincomalee/cover.jpg',
  'Arugam Bay': 'assets/places/arugam_bay/cover.jpg',
  'Colombo': 'assets/places/colombo/cover.jpg',
  'Anuradhapura': 'assets/places/anuradhapura/cover.jpg',
  'Polonnaruwa': 'assets/places/polonnaruwa/cover.jpg',
  'Dambulla': 'assets/places/dambulla/cover.jpg',
  'Unawatuna': 'assets/places/unawatuna/cover.jpg',
  'Hikkaduwa': 'assets/places/hikkaduwa/cover.jpg',
  'Jaffna': 'assets/places/jaffna/cover.jpg',
  'Horton Plains': 'assets/places/horton_plains/cover.jpg',
  'Pidurangala': 'assets/places/pidurangala/cover.jpg',
  'Udawalawe': 'assets/places/udawalawe/cover.jpg',
};

const Map<String, List<String>> localPlaceGalleryAssets = {
  'Ella': [
    'assets/places/ella/cover.jpg',
    'assets/places/ella/1.jpg',
    'assets/places/ella/2.jpg',
  ],
  'Sigiriya': [
    'assets/places/sigiriya/cover.jpeg',
    'assets/places/sigiriya/1.jpg',
    'assets/places/sigiriya/2.jpg',
  ],
  'Kandy': [
    'assets/places/kandy/cover.jpg',
    'assets/places/kandy/1.jpg',
    'assets/places/kandy/2.jpg',
  ],
  'Galle': [
    'assets/places/galle/cover.jpg',
    'assets/places/galle/1.jpg',
    'assets/places/galle/2.jpg',
  ],
  'Mirissa': [
    'assets/places/mirissa/cover.jpg',
    'assets/places/mirissa/1.jpg',
    'assets/places/mirissa/2.jpg',
  ],
  'Nuwara Eliya': [
    'assets/places/nuwara_eliya/cover.jpg',
    'assets/places/nuwara_eliya/1.jpg',
    'assets/places/nuwara_eliya/2.jpg',
  ],
  'Yala National Park': [
    'assets/places/yala_national_park/cover.jpg',
    'assets/places/yala_national_park/1.jpg',
    'assets/places/yala_national_park/2.jpg',
  ],
  'Trincomalee': [
    'assets/places/trincomalee/cover.jpg',
    'assets/places/trincomalee/1.jpg',
    'assets/places/trincomalee/2.jpg',
  ],
  'Arugam Bay': [
    'assets/places/arugam_bay/cover.jpg',
    'assets/places/arugam_bay/1.jpg',
    'assets/places/arugam_bay/2.jpg',
  ],
  'Colombo': [
    'assets/places/colombo/cover.jpg',
    'assets/places/colombo/1.jpg',
    'assets/places/colombo/2.jpg',
  ],
  'Anuradhapura': [
    'assets/places/anuradhapura/cover.jpg',
    'assets/places/anuradhapura/1.jpg',
    'assets/places/anuradhapura/2.jpg',
  ],
  'Polonnaruwa': [
    'assets/places/polonnaruwa/cover.jpg',
    'assets/places/polonnaruwa/1.jpg',
    'assets/places/polonnaruwa/2.jpg',
  ],
  'Dambulla': [
    'assets/places/dambulla/cover.jpg',
    'assets/places/dambulla/1.jpg',
    'assets/places/dambulla/2.jpg',
  ],
  'Unawatuna': [
    'assets/places/unawatuna/cover.jpg',
    'assets/places/unawatuna/1.jpg',
    'assets/places/unawatuna/2.jpg',
  ],
  'Hikkaduwa': [
    'assets/places/hikkaduwa/cover.jpg',
    'assets/places/hikkaduwa/1.jpg',
    'assets/places/hikkaduwa/2.jpg',
  ],
  'Jaffna': [
    'assets/places/jaffna/cover.jpg',
    'assets/places/jaffna/1.jpg',
    'assets/places/jaffna/2.jpg',
  ],
  'Horton Plains': [
    'assets/places/horton_plains/cover.jpg',
    'assets/places/horton_plains/1.jpg',
    'assets/places/horton_plains/2.jpg',
  ],
  'Pidurangala': [
    'assets/places/pidurangala/cover.jpg',
  ],
  'Udawalawe': [
    'assets/places/udawalawe/cover.jpg',
    'assets/places/udawalawe/1.jpg',
    'assets/places/udawalawe/2.jpg',
  ],
};

String wikipediaTitleForPlace(String placeName) {
  return wikipediaPlaceTitles[placeName] ?? placeName;
}

bool hasDedicatedLocalPhotos(String placeName) {
  return localCoverAssets.containsKey(placeName);
}

String? localCoverAssetForPlace(String placeName) {
  return localCoverAssets[placeName];
}

List<String> localGalleryAssetsForPlace(String placeName) {
  return List<String>.from(localPlaceGalleryAssets[placeName] ?? const <String>[]);
}
