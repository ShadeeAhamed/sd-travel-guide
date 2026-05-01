import '../models/place_model.dart';

const Set<String> featuredPlaceNames = {
  "Ella",
  "Sigiriya",
  "Kandy",
  "Galle",
  "Mirissa",
  "Nuwara Eliya",
  "Yala National Park",
  "Trincomalee",
  "Jaffna",
  "Nilaveli",
  "Sinharaja Forest Reserve",
  "Adam's Peak",
};

final List<PlaceModel> seedPlaces = [
  PlaceModel(
    name: "Ella",
    description:
        "Ella is a dramatic hill-country escape with tea estates, cloud-wrapped ridges, cool weather, waterfall drives, and some of Sri Lanka's most photogenic train and hiking scenery.",
    image: "assets/places/ella/cover.png",
    lat: 6.8667,
    lng: 81.0466,
    type: "Hill country",
  ),
  PlaceModel(
    name: "Sigiriya",
    description:
        "Sigiriya is one of Sri Lanka's signature landmarks, combining an ancient rock fortress, royal gardens, frescoes, and panoramic cultural-triangle views in one major stop.",
    image: "assets/places/sigiriya/cover.png",
    lat: 7.9570,
    lng: 80.7603,
    type: "Heritage",
  ),
  PlaceModel(
    name: "Kandy",
    description:
        "Kandy blends sacred history, lakefront walks, Kandyan culture, temple rituals, and easy access to highland landscapes, making it a strong base for first-time visitors.",
    image: "assets/places/kandy/cover.png",
    lat: 7.2906,
    lng: 80.6337,
    type: "Culture",
  ),
  PlaceModel(
    name: "Galle",
    description:
        "Galle offers colonial fort walls, boutique streets, ocean sunsets, museums, and stylish cafes in a compact coastal city that feels both historic and relaxed.",
    image: "assets/places/galle/cover.png",
    lat: 6.0320,
    lng: 80.2168,
    type: "Heritage",
  ),
  PlaceModel(
    name: "Mirissa",
    description:
        "Mirissa is a laid-back south-coast beach town known for golden sand, whale-watching boats, nightlife spots, surf-friendly bays, and easy day trips along the shore.",
    image: "assets/places/mirissa/cover.png",
    lat: 5.9465,
    lng: 80.4584,
    type: "Beach",
  ),
  PlaceModel(
    name: "Nuwara Eliya",
    description:
        "Nuwara Eliya is Sri Lanka's cool-weather tea capital, famous for gardens, lake views, colonial-era charm, and scenic drives through misty plantations.",
    image: "assets/places/ella/cover.png",
    lat: 6.9497,
    lng: 80.7891,
    type: "Hill country",
  ),
  PlaceModel(
    name: "Yala National Park",
    description:
        "Yala is the country's best-known safari destination, with open grasslands, lagoons, forest tracks, and a strong chance of spotting leopards and elephants.",
    image: "assets/places/sigiriya/cover.png",
    lat: 6.3725,
    lng: 81.5185,
    type: "Wildlife",
  ),
  PlaceModel(
    name: "Trincomalee",
    description:
        "Trincomalee combines calm east-coast beaches, whale season excursions, harbor viewpoints, hot springs, and temple history in one easy seaside base.",
    image: "assets/places/mirissa/cover.png",
    lat: 8.5874,
    lng: 81.2152,
    type: "Beach",
  ),
  PlaceModel(
    name: "Arugam Bay",
    description:
        "Arugam Bay is Sri Lanka's best-known surf town, loved for long point breaks, casual beach cafes, lagoon trips, and a very relaxed backpacker atmosphere.",
    image: "assets/places/mirissa/cover.png",
    lat: 6.8404,
    lng: 81.8368,
    type: "Beach",
  ),
  PlaceModel(
    name: "Colombo",
    description:
        "Colombo is the island's energetic gateway, mixing seafront promenades, city food culture, temples, malls, museums, nightlife, and quick transport links.",
    image: "assets/places/galle/cover.png",
    lat: 6.9271,
    lng: 79.8612,
    type: "City",
  ),
  PlaceModel(
    name: "Anuradhapura",
    description:
        "Anuradhapura is a major ancient capital with vast monastery ruins, sacred stupas, giant reservoirs, and deeply important Buddhist pilgrimage sites.",
    image: "assets/places/sigiriya/cover.png",
    lat: 8.3114,
    lng: 80.4037,
    type: "Heritage",
  ),
  PlaceModel(
    name: "Polonnaruwa",
    description:
        "Polonnaruwa preserves a beautifully planned royal city of stone shrines, statues, ponds, and palace remains that are easy to explore by bike or tuk-tuk.",
    image: "assets/places/sigiriya/cover.png",
    lat: 7.9403,
    lng: 81.0188,
    type: "Heritage",
  ),
  PlaceModel(
    name: "Dambulla",
    description:
        "Dambulla is best known for its cave temple complex filled with murals and Buddha statues, and it works perfectly as a base for the cultural triangle.",
    image: "assets/places/sigiriya/cover.png",
    lat: 7.8567,
    lng: 80.6492,
    type: "Heritage",
  ),
  PlaceModel(
    name: "Unawatuna",
    description:
        "Unawatuna is a friendly beach stop near Galle, popular for swimming, snorkeling, beach cafes, sunset walks, and easy access to nearby coastal highlights.",
    image: "assets/places/galle/cover.png",
    lat: 6.0105,
    lng: 80.2497,
    type: "Beach",
  ),
  PlaceModel(
    name: "Hikkaduwa",
    description:
        "Hikkaduwa is a lively beach town with reef areas, surf breaks, nightlife, diving options, and a long sandy shoreline that stays popular with young travelers.",
    image: "assets/places/galle/cover.png",
    lat: 6.1407,
    lng: 80.1018,
    type: "Beach",
  ),
  PlaceModel(
    name: "Bentota",
    description:
        "Bentota is ideal for resort-style beach time, water sports, river safaris, and calm holiday pacing, especially for couples and family travelers.",
    image: "assets/places/mirissa/cover.png",
    lat: 6.4218,
    lng: 79.9959,
    type: "Beach",
  ),
  PlaceModel(
    name: "Jaffna",
    description:
        "Jaffna offers a very different Sri Lanka experience with strong Tamil culture, island day trips, northern cuisine, historic sites, and a quieter urban rhythm.",
    image: "assets/places/kandy/cover.png",
    lat: 9.6615,
    lng: 80.0255,
    type: "Culture",
  ),
  PlaceModel(
    name: "Horton Plains",
    description:
        "Horton Plains is a high-altitude grassland and cloud-forest park known for cool trekking weather, dramatic escarpments, and the famous World's End viewpoint.",
    image: "assets/places/ella/cover.png",
    lat: 6.8094,
    lng: 80.8020,
    type: "Nature",
  ),
  PlaceModel(
    name: "Pidurangala",
    description:
        "Pidurangala is a rewarding rock hike facing Sigiriya, popular for sunrise climbs, panoramic photography, and a more adventurous alternative to the main fortress.",
    image: "assets/places/sigiriya/cover.png",
    lat: 7.9660,
    lng: 80.7603,
    type: "Hiking",
  ),
  PlaceModel(
    name: "Udawalawe",
    description:
        "Udawalawe is a reliable wildlife park for elephant sightings, open safari visibility, and easy half-day or full-day excursions from Sri Lanka's south and hills.",
    image: "assets/places/ella/cover.png",
    lat: 6.4749,
    lng: 80.8980,
    type: "Wildlife",
  ),
  PlaceModel(
    name: "Negombo",
    description:
        "Negombo is a practical beach gateway near the airport, known for its lagoon, seafood, canal traces, and easy first-night or last-night pacing.",
    image: "assets/places/mirissa/cover.png",
    lat: 7.2083,
    lng: 79.8358,
    type: "Beach",
  ),
  PlaceModel(
    name: "Nilaveli",
    description:
        "Nilaveli offers a quieter east-coast beach stay with calm water, long sand stretches, and access to Pigeon Island snorkeling.",
    image: "assets/places/mirissa/cover.png",
    lat: 8.6940,
    lng: 81.1982,
    type: "Beach",
  ),
  PlaceModel(
    name: "Pasikuda",
    description:
        "Pasikuda is a gentle east-coast lagoon-style beach, ideal for relaxed swimming, families, and resort-style downtime.",
    image: "assets/places/mirissa/cover.png",
    lat: 7.9290,
    lng: 81.5610,
    type: "Beach",
  ),
  PlaceModel(
    name: "Kalpitiya",
    description:
        "Kalpitiya is a wind-and-water destination known for kitesurfing, dolphin trips, sandbars, and a more open coastal landscape.",
    image: "assets/places/mirissa/cover.png",
    lat: 8.2330,
    lng: 79.7660,
    type: "Beach",
  ),
  PlaceModel(
    name: "Wilpattu National Park",
    description:
        "Wilpattu brings a quieter safari rhythm with lakes, dry-zone forest, and a strong wilderness feel for travelers who want a more spread-out park experience.",
    image: "assets/places/sigiriya/cover.png",
    lat: 8.4560,
    lng: 80.0440,
    type: "Wildlife",
  ),
  PlaceModel(
    name: "Kumana National Park",
    description:
        "Kumana is one of Sri Lanka's strongest birding and east-coast wildlife zones, mixing lagoons, scrub forest, and safari tracks.",
    image: "assets/places/ella/cover.png",
    lat: 6.5840,
    lng: 81.6700,
    type: "Wildlife",
  ),
  PlaceModel(
    name: "Bundala National Park",
    description:
        "Bundala is a compact wetland safari region known for flamingos, birdlife, lagoons, and easy coastal detours from the deep south.",
    image: "assets/places/ella/cover.png",
    lat: 6.1960,
    lng: 81.2250,
    type: "Wildlife",
  ),
  PlaceModel(
    name: "Adam's Peak",
    description:
        "Adam's Peak is a pilgrimage mountain famous for night climbs, sunrise views, and one of Sri Lanka's most memorable summit experiences.",
    image: "assets/places/ella/cover.png",
    lat: 6.8096,
    lng: 80.4994,
    type: "Hiking",
  ),
  PlaceModel(
    name: "Diyaluma Falls",
    description:
        "Diyaluma Falls combines a major waterfall drop with natural infinity-pool viewpoints higher up, making it a dramatic add-on from the hill country.",
    image: "assets/places/ella/cover.png",
    lat: 6.7369,
    lng: 81.0290,
    type: "Waterfall",
  ),
  PlaceModel(
    name: "Bambarakanda Falls",
    description:
        "Bambarakanda is Sri Lanka's tallest waterfall and a strong scenic roadside stop for travelers linking the hills and the south-central highlands.",
    image: "assets/places/ella/cover.png",
    lat: 6.7730,
    lng: 80.8300,
    type: "Waterfall",
  ),
  PlaceModel(
    name: "Sinharaja Forest Reserve",
    description:
        "Sinharaja is Sri Lanka's best-known rainforest experience, offering biodiversity, guided forest walks, and a rich green contrast to the coast and heritage sites.",
    image: "assets/places/ella/cover.png",
    lat: 6.4060,
    lng: 80.4903,
    type: "Nature",
  ),
  PlaceModel(
    name: "Knuckles Range",
    description:
        "Knuckles is a mountain wilderness zone with trekking routes, cloud forest, villages, and cooler adventure-driven travel outside the usual tourist path.",
    image: "assets/places/ella/cover.png",
    lat: 7.4340,
    lng: 80.8330,
    type: "Hiking",
  ),
  PlaceModel(
    name: "Kitulgala",
    description:
        "Kitulgala is Sri Lanka's classic soft-adventure base for white-water rafting, jungle activity days, and rainy-green scenery.",
    image: "assets/places/ella/cover.png",
    lat: 6.9891,
    lng: 80.4178,
    type: "Adventure",
  ),
  PlaceModel(
    name: "Habarana",
    description:
        "Habarana is a strategic central base for safaris, village rides, Sigiriya, and Dambulla, especially when you want easier logistics in the cultural triangle.",
    image: "assets/places/sigiriya/cover.png",
    lat: 8.0372,
    lng: 80.7503,
    type: "Nature",
  ),
  PlaceModel(
    name: "Kataragama",
    description:
        "Kataragama blends pilgrimage energy, regional culture, and easy links to Yala and the deep south, making it more than just a pass-through town.",
    image: "assets/places/kandy/cover.png",
    lat: 6.4145,
    lng: 81.3347,
    type: "Culture",
  ),
  PlaceModel(
    name: "Haputale",
    description:
        "Haputale is a scenic highland ridge town with tea-country views, cooler weather, and easy access to Lipton's Seat and cloud-wrapped viewpoints.",
    image: "assets/places/ella/cover.png",
    lat: 6.7667,
    lng: 80.9510,
    type: "Hill country",
  ),
  PlaceModel(
    name: "Tangalle",
    description:
        "Tangalle offers a calmer south-coast feel than the busier beach towns, with long bays, lagoons, and room to slow the trip down.",
    image: "assets/places/mirissa/cover.png",
    lat: 6.0230,
    lng: 80.7974,
    type: "Beach",
  ),
  PlaceModel(
    name: "Polhena",
    description:
        "Polhena is a gentle Matara-side beach known for calmer swimming stretches and easy short local stops away from heavier surf scenes.",
    image: "assets/places/mirissa/cover.png",
    lat: 5.9549,
    lng: 80.5353,
    type: "Beach",
  ),
  PlaceModel(
    name: "Mannar",
    description:
        "Mannar brings a quieter northern-western coastline, island character, birdlife, and a very different regional atmosphere for repeat visitors.",
    image: "assets/places/kandy/cover.png",
    lat: 8.9790,
    lng: 79.9050,
    type: "Culture",
  ),
  PlaceModel(
    name: "Batticaloa",
    description:
        "Batticaloa mixes lagoon scenery, east-coast culture, quieter beaches, and a slower city rhythm that suits travelers looking beyond the standard routes.",
    image: "assets/places/mirissa/cover.png",
    lat: 7.7102,
    lng: 81.6924,
    type: "Beach",
  ),
];
