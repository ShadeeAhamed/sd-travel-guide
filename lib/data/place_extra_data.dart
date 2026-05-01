class VisitStop {
  final String time;
  final String title;
  final String details;
  final String costNote;

  const VisitStop({
    required this.time,
    required this.title,
    required this.details,
    required this.costNote,
  });
}

class PlaceExtraInfo {
  final String headline;
  final String bestSeason;
  final String bestTime;
  final String idealDuration;
  final String budget;
  final String transportTip;
  final String localTip;
  final List<String> thingsToDo;
  final List<VisitStop> visitPlan;
  final List<String> quickTips;
  final List<String> nearbyPlaces;

  const PlaceExtraInfo({
    required this.headline,
    required this.bestSeason,
    required this.bestTime,
    required this.idealDuration,
    required this.budget,
    required this.transportTip,
    required this.localTip,
    required this.thingsToDo,
    required this.visitPlan,
    required this.quickTips,
    required this.nearbyPlaces,
  });
}

final Map<String, PlaceExtraInfo> placeExtraData = {
  "Ella": const PlaceExtraInfo(
    headline:
        "Best for a scenic hill-country day with sunrise hikes, train views, and easy waterfall stops.",
    bestSeason: "January to May",
    bestTime: "Sunrise to sunset, with the clearest views in the morning",
    idealDuration: "2 to 3 nights",
    budget:
        "Mostly mixed budget: bridge viewpoints are free, waterfalls are usually free, guided cave visits cost extra.",
    transportTip:
        "Tuk-tuks work well for Nine Arch Bridge, Ravana Falls, and tea-estate stops; walking works for town viewpoints.",
    localTip:
        "If you want the bridge with a train, aim for the morning or late afternoon and double-check the latest station timing locally.",
    thingsToDo: [
      "Walk to Nine Arch Bridge viewpoints",
      "Hike Little Adam's Peak for sunrise views",
      "Visit Ravana Falls, tea estates, and an optional Nil Diya Pokuna cave trip",
    ],
    visitPlan: [
      VisitStop(
        time: "6:30 AM",
        title: "Little Adam's Peak",
        details:
            "Go early for the softest weather and clear ridge views before the hiking path gets crowded.",
        costNote: "Free",
      ),
      VisitStop(
        time: "9:00 AM to 10:30 AM",
        title: "Nine Arch Bridge",
        details:
            "Use the upper viewpoints first, then move closer only if the tracks are clear and safe. Train times can shift.",
        costNote: "Free",
      ),
      VisitStop(
        time: "3:30 PM",
        title: "Ravana Falls and cave-side route",
        details:
            "Best as a relaxed roadside photo stop after lunch; water is strongest after rain.",
        costNote: "Roadside stop is usually free",
      ),
      VisitStop(
        time: "Optional extra",
        title: "Nil Diya Pokuna",
        details:
            "A guided underground adventure near Ella for confident travelers only; not ideal for children or anyone uncomfortable underground.",
        costNote: "Paid guided activity",
      ),
    ],
    quickTips: [
      "Carry a light rain layer even on sunny days.",
      "Book the Kandy-Ella train in advance if rail views matter to your trip.",
      "Start hikes early; midday heat and mist can flatten the views.",
    ],
    nearbyPlaces: ["Nuwara Eliya", "Badulla", "Diyaluma Falls"],
  ),
  "Sigiriya": const PlaceExtraInfo(
    headline:
        "Best for first-time visitors who want one major landmark, history, and a sunrise or sunset rock climb.",
    bestSeason: "January to April",
    bestTime: "Early morning for the main climb, late afternoon for nearby viewpoints",
    idealDuration: "1 to 2 nights",
    budget: "Main fortress is paid; nearby hikes and village add-ons are mixed.",
    transportTip:
        "A private car or tuk-tuk is easiest if you want to combine Sigiriya, Dambulla, and Pidurangala in one day.",
    localTip:
        "The climb is far more comfortable before the rock heats up. Carry water and sun protection.",
    thingsToDo: [
      "Climb Sigiriya Rock Fortress",
      "Explore the museum and landscaped water gardens",
      "Add Pidurangala for a wider sunrise or sunset view",
    ],
    visitPlan: [
      VisitStop(
        time: "6:30 AM",
        title: "Sigiriya main climb",
        details:
            "Start early to beat the heat and crowds; current published visiting hours have been listed as early as 5:00 AM to 6:30 PM on Sigiriya's tourism site.",
        costNote: "Paid heritage ticket",
      ),
      VisitStop(
        time: "10:00 AM",
        title: "Museum and gardens",
        details:
            "Slow down after the climb and explore the lower complex properly instead of rushing back to the hotel.",
        costNote: "Included or bundled with the main site ticket",
      ),
      VisitStop(
        time: "5:00 PM",
        title: "Pidurangala lookout",
        details:
            "Use this for the classic Sigiriya-facing panorama if you still have energy for another short rocky climb.",
        costNote: "Small paid entry or donation",
      ),
    ],
    quickTips: [
      "Wear grippy shoes; some stair sections are narrow.",
      "Sunrise light is best for photos from Pidurangala.",
      "Check current ticket rules before arrival because fees can change.",
    ],
    nearbyPlaces: ["Dambulla", "Pidurangala", "Polonnaruwa"],
  ),
  "Kandy": const PlaceExtraInfo(
    headline:
        "Best for sacred heritage, lake walks, and a cultural base before the hill country train journey.",
    bestSeason: "January to April",
    bestTime: "Morning temple visits and late afternoon around the lake",
    idealDuration: "1 to 2 nights",
    budget:
        "Very manageable: lake walks are free, while temple and shows are usually paid.",
    transportTip:
        "Stay close to the lake if you want to walk between the temple, shops, and evening food stops.",
    localTip:
        "Dress modestly for the Temple of the Tooth and keep shoulders and knees covered.",
    thingsToDo: [
      "Visit the Temple of the Sacred Tooth Relic",
      "Walk around Kandy Lake",
      "Watch a cultural dance performance in the evening",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Temple of the Tooth",
        details:
            "Go in the morning for a calmer visit and easier temple access before city traffic builds.",
        costNote: "Paid entry",
      ),
      VisitStop(
        time: "4:30 PM",
        title: "Kandy Lake and market area",
        details:
            "This is the best time for a lake walk and a more relaxed look at central Kandy.",
        costNote: "Free",
      ),
      VisitStop(
        time: "5:30 PM or later",
        title: "Cultural dance show",
        details:
            "A good short evening activity if you want a classic first-visit Kandy experience.",
        costNote: "Paid",
      ),
    ],
    quickTips: [
      "Traffic gets slow around the center, so keep buffer time.",
      "Temple queues can spike on weekends and public holidays.",
      "Pair Kandy with Peradeniya or the train south if you have an extra day.",
    ],
    nearbyPlaces: ["Peradeniya", "Knuckles", "Pinnawala"],
  ),
  "Galle": const PlaceExtraInfo(
    headline:
        "Best for a relaxed half-day or full-day fort walk with ocean views, cafes, and boutique streets.",
    bestSeason: "December to April",
    bestTime: "Late afternoon through sunset",
    idealDuration: "1 to 2 nights",
    budget: "Mostly flexible; walking the fort is free and museums or boutique stops add cost.",
    transportTip:
        "Base yourself inside the fort for atmosphere or nearby if you want easier parking and beach access.",
    localTip:
        "The ramparts are nicest once the sun softens, especially on the lighthouse side.",
    thingsToDo: [
      "Walk the fort walls",
      "See the lighthouse, museum zone, and church streets",
      "Use Galle as a base for beach day trips",
    ],
    visitPlan: [
      VisitStop(
        time: "3:30 PM",
        title: "Fort wall circuit",
        details:
            "Start with the ramparts and sea side while the light improves and the heat fades.",
        costNote: "Free",
      ),
      VisitStop(
        time: "5:30 PM",
        title: "Lighthouse and sunset corner",
        details:
            "This is the classic photo hour for the fort, especially for first-time visitors.",
        costNote: "Free",
      ),
      VisitStop(
        time: "Evening",
        title: "Cafe and boutique streets",
        details:
            "Finish with dinner, gelato, or a slow walk through the inner lanes once the crowds thin out.",
        costNote: "Mixed",
      ),
    ],
    quickTips: [
      "It is easy to combine Galle with Unawatuna or Hikkaduwa.",
      "Midday inside the fort can feel hot and bright.",
      "The fort is better explored on foot than by tuk-tuk.",
    ],
    nearbyPlaces: ["Unawatuna", "Hikkaduwa", "Bentota"],
  ),
  "Mirissa": const PlaceExtraInfo(
    headline:
        "Best for beach time, whale season outings, and a laid-back south-coast stop with nightlife nearby.",
    bestSeason: "November to April",
    bestTime: "Early morning for boats, late afternoon for the beach",
    idealDuration: "2 nights",
    budget: "Beach time is easy on the budget; whale trips and surfing lessons add cost.",
    transportTip:
        "Stay close to the main beach if you want to walk between cafes, boats, and sunset points.",
    localTip:
        "Sea conditions matter more than the calendar for boat trips, so confirm conditions the day before.",
    thingsToDo: [
      "Go whale watching in season",
      "Spend time on the main beach and surf spots",
      "Catch sunset at Coconut Tree Hill",
    ],
    visitPlan: [
      VisitStop(
        time: "6:00 AM",
        title: "Whale watching departure",
        details:
            "Join only if the sea is calm enough and you are comfortable on boats for several hours.",
        costNote: "Paid boat tour",
      ),
      VisitStop(
        time: "3:30 PM",
        title: "Beach and surf time",
        details:
            "Use the afternoon for swimming, beginner surf, or a long beach break.",
        costNote: "Beach access is free",
      ),
      VisitStop(
        time: "Sunset",
        title: "Coconut Tree Hill",
        details:
            "Best for a short photo stop before dinner; arrive a little early if you want space.",
        costNote: "Free",
      ),
    ],
    quickTips: [
      "Avoid rough-sea days for whale boats.",
      "Mirissa works well with Weligama and Galle in one route.",
      "Carry reef-safe sun protection if you plan to swim often.",
    ],
    nearbyPlaces: ["Weligama", "Matara", "Unawatuna"],
  ),
  "Nuwara Eliya": const PlaceExtraInfo(
    headline:
        "Best for cool air, tea scenery, gardens, and a slower highland stop between Kandy and Ella.",
    bestSeason: "February to April",
    bestTime: "Morning for gardens and afternoon for tea-country drives",
    idealDuration: "1 to 2 nights",
    budget: "Mixed: town walks are easy, while parks, boating, and tea tours can add small costs.",
    transportTip:
        "Hire a driver or tuk-tuk for Gregory Lake, tea estates, and Hakgala in one smooth day.",
    localTip:
        "Mornings are crisp and photogenic; evenings can feel genuinely cold compared with the coast.",
    thingsToDo: [
      "Visit tea factories and plantations",
      "Walk around Gregory Lake",
      "Add Victoria Park or Hakgala for gardens",
    ],
    visitPlan: [
      VisitStop(
        time: "8:30 AM",
        title: "Tea estate or factory visit",
        details:
            "Go early for clearer views before mist thickens on the surrounding hills.",
        costNote: "Mixed; some tastings or tours are paid",
      ),
      VisitStop(
        time: "2:00 PM",
        title: "Gregory Lake area",
        details:
            "Good for a light walk, family time, and easy boating options.",
        costNote: "Public access is easy, activities may charge",
      ),
      VisitStop(
        time: "Late afternoon",
        title: "Town center or park",
        details:
            "Keep this relaxed; Nuwara Eliya is more about atmosphere than rushing between sites.",
        costNote: "Low to mixed",
      ),
    ],
    quickTips: [
      "Pack a warm layer for evenings.",
      "Fog can roll in quickly after midday.",
      "This stop pairs nicely with Horton Plains if you start early the next day.",
    ],
    nearbyPlaces: ["Ella", "Horton Plains", "Ambewela"],
  ),
  "Yala National Park": const PlaceExtraInfo(
    headline:
        "Best for safari travelers who want strong wildlife chances and can handle early starts.",
    bestSeason: "February to July",
    bestTime: "Early morning or late afternoon safari windows",
    idealDuration: "1 night",
    budget: "This is a paid activity destination; jeeps and park fees make it one of the pricier stops.",
    transportTip:
        "Book a safari through a reliable hotel or operator in Tissamaharama to avoid last-minute pricing confusion.",
    localTip:
        "Go for the wildlife, not just the leopard promise. Elephant, bird, and landscape sightings make the day.",
    thingsToDo: [
      "Take a jeep safari",
      "Look for elephant, deer, crocodile, and leopard sightings",
      "Use Tissamaharama as a nearby base",
    ],
    visitPlan: [
      VisitStop(
        time: "5:00 AM",
        title: "Morning safari departure",
        details:
            "This is the classic window for cooler temperatures and the strongest overall movement in the park.",
        costNote: "Paid jeep plus park fees",
      ),
      VisitStop(
        time: "Midday",
        title: "Rest and reset",
        details:
            "The park can feel hot and wildlife becomes less active, so use midday for hotel rest.",
        costNote: "Low",
      ),
      VisitStop(
        time: "2:30 PM",
        title: "Optional second safari",
        details:
            "A second drive helps if wildlife photography matters more than budget.",
        costNote: "Paid",
      ),
    ],
    quickTips: [
      "Carry dust protection for jeep rides in dry months.",
      "Do not expect guaranteed leopard sightings.",
      "Bring water, binoculars, and patience.",
    ],
    nearbyPlaces: ["Kataragama", "Tissamaharama", "Bundala"],
  ),
  "Trincomalee": const PlaceExtraInfo(
    headline:
        "Best for east-coast beach days, temple views, and island outings when the water is calm and bright.",
    bestSeason: "May to September",
    bestTime: "Morning for the beach and boat trips",
    idealDuration: "2 to 3 nights",
    budget: "Beach time is affordable; island boats and snorkeling add cost.",
    transportTip:
        "Stay near Nilaveli or Uppuveli if beaches are your priority, or closer to town if you want temple access.",
    localTip:
        "Pigeon Island conditions depend on weather and water clarity, so keep one flexible day if possible.",
    thingsToDo: [
      "Swim at Nilaveli or Uppuveli",
      "Visit Koneswaram Temple",
      "Take a boat to Pigeon Island in the right season",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Nilaveli or Uppuveli beach",
        details:
            "Start the day on the beach before the midday sun gets harsher.",
        costNote: "Beach access is generally free",
      ),
      VisitStop(
        time: "11:00 AM",
        title: "Koneswaram Temple and viewpoint",
        details:
            "A strong culture-and-view stop with one of the best sea-facing temple settings on the island.",
        costNote: "Free or donation-based",
      ),
      VisitStop(
        time: "Optional half day",
        title: "Pigeon Island",
        details:
            "Best added when the sea is calm and visibility is worth the boat and snorkeling cost.",
        costNote: "Paid park and boat trip",
      ),
    ],
    quickTips: [
      "The east coast shines when the south and west are wetter.",
      "Carry cash for boat trips and small cafes.",
      "Reserve extra time if you want whale-season outings.",
    ],
    nearbyPlaces: ["Nilaveli", "Pigeon Island", "Kanniya Hot Springs"],
  ),
  "Arugam Bay": const PlaceExtraInfo(
    headline:
        "Best for surf travelers, lagoon trips, and a very casual beach-town atmosphere.",
    bestSeason: "May to September",
    bestTime: "Early and late for surfing, midday for rest",
    idealDuration: "2 to 4 nights",
    budget: "Flexible; surfing lessons and safaris cost extra.",
    transportTip:
        "You can base in town and tuk-tuk to surf points, lagoons, and nearby beaches.",
    localTip:
        "This stop is more about staying a few days and settling into the rhythm than rushing site to site.",
    thingsToDo: [
      "Surf the main point",
      "Take a lagoon safari",
      "Explore Panama and nearby beach stretches",
    ],
    visitPlan: [
      VisitStop(
        time: "6:30 AM",
        title: "Morning surf session",
        details:
            "Conditions are often cleaner in the morning, especially for beginners or long sessions.",
        costNote: "Beach free, rentals or lessons paid",
      ),
      VisitStop(
        time: "4:00 PM",
        title: "Lagoon or wildlife outing",
        details:
            "A good way to break up beach time if you want more than surfing.",
        costNote: "Paid tour",
      ),
      VisitStop(
        time: "Sunset",
        title: "Town and beach road",
        details:
            "Best for a relaxed dinner and the social side of Arugam Bay.",
        costNote: "Mixed",
      ),
    ],
    quickTips: [
      "Plan around surf conditions more than fixed sightseeing slots.",
      "Carry sun protection; the open coast gets intense.",
      "This pairs well with a later wildlife stop like Kumana.",
    ],
    nearbyPlaces: ["Panama", "Kumana", "Pottuvil"],
  ),
  "Colombo": const PlaceExtraInfo(
    headline:
        "Best for your arrival day, city food, shopping, museums, and a quick urban reset between travel legs.",
    bestSeason: "January to March",
    bestTime: "Late afternoon into evening",
    idealDuration: "1 night",
    budget: "Highly flexible depending on hotels, dining, and shopping.",
    transportTip:
        "Traffic can be slow, so group nearby stops instead of zigzagging across the city.",
    localTip:
        "Colombo works best when you pick a few neighborhoods instead of trying to cover everything in one rush.",
    thingsToDo: [
      "Walk Galle Face Green",
      "Try city food streets and cafes",
      "Visit museums, temples, and shopping areas",
    ],
    visitPlan: [
      VisitStop(
        time: "4:30 PM",
        title: "Galle Face Green",
        details:
            "This is the classic city wind-down and one of the easiest first stops after checking in.",
        costNote: "Free",
      ),
      VisitStop(
        time: "Evening",
        title: "Dinner and street food",
        details:
            "Use the evening to sample Colombo's mix of Sri Lankan, Muslim, Tamil, and modern city food.",
        costNote: "Mixed",
      ),
      VisitStop(
        time: "Next morning",
        title: "Museum or temple stop",
        details:
            "Good if you want one culture stop before leaving the city.",
        costNote: "Low to paid",
      ),
    ],
    quickTips: [
      "Keep extra time for airport transfers.",
      "A short Colombo stop is often enough for most tourists.",
      "Use malls and cafes when you need a comfortable reset day.",
    ],
    nearbyPlaces: ["Negombo", "Mount Lavinia", "Bentota"],
  ),
  "Anuradhapura": const PlaceExtraInfo(
    headline:
        "Best for deep ancient-city exploration, sacred Buddhist sites, and a slower heritage day.",
    bestSeason: "January to April",
    bestTime: "Morning and late afternoon",
    idealDuration: "1 to 2 nights",
    budget: "Sacred and archaeological areas are typically paid for foreign visitors.",
    transportTip:
        "Use a tuk-tuk, driver, or bicycle based on heat tolerance and how much ground you want to cover.",
    localTip:
        "This site is large; trying to walk everything in midday heat can drain the whole experience.",
    thingsToDo: [
      "Visit Ruwanwelisaya and Jaya Sri Maha Bodhi",
      "Explore monastery ruins",
      "Tour the ancient city circuit",
    ],
    visitPlan: [
      VisitStop(
        time: "7:30 AM",
        title: "Sacred core sites",
        details:
            "Start with the major sacred stops before the grounds get hotter and busier.",
        costNote: "Paid heritage zone",
      ),
      VisitStop(
        time: "11:00 AM",
        title: "Ancient city circuit",
        details:
            "Continue by vehicle or bicycle depending on your pace and energy.",
        costNote: "Included within site access or low transport cost",
      ),
      VisitStop(
        time: "4:30 PM",
        title: "Return for quieter light",
        details:
            "The late-day atmosphere is much calmer and better for reflective visits.",
        costNote: "No extra site cost if already entered",
      ),
    ],
    quickTips: [
      "Carry socks or easy footwear for temple areas.",
      "Take water and sun cover seriously.",
      "This works well with Mihintale if you have more time.",
    ],
    nearbyPlaces: ["Mihintale", "Wilpattu", "Sigiriya"],
  ),
  "Polonnaruwa": const PlaceExtraInfo(
    headline:
        "Best for travelers who want an archaeological city that is easier to move through than Anuradhapura.",
    bestSeason: "January to April",
    bestTime: "Morning",
    idealDuration: "Full day or one night",
    budget: "Paid heritage destination with low extra spend once inside.",
    transportTip:
        "Cycling is popular here because the site layout is approachable and scenic.",
    localTip:
        "A bike works beautifully if you enjoy slow travel, but a driver is easier in hotter months.",
    thingsToDo: [
      "Cycle around the ancient city",
      "Visit Gal Vihara and palace ruins",
      "See reservoirs and monument zones",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Royal palace and core monuments",
        details:
            "Start in the main archaeological heart before the day becomes too hot.",
        costNote: "Paid heritage ticket",
      ),
      VisitStop(
        time: "10:30 AM",
        title: "Gal Vihara",
        details:
            "This is the signature sculpture stop and worth slowing down for.",
        costNote: "Included in site entry",
      ),
      VisitStop(
        time: "Late morning",
        title: "Reservoir and outer sections",
        details:
            "Use the final portion of the morning for the less crowded outer areas.",
        costNote: "Included",
      ),
    ],
    quickTips: [
      "Start early if you plan to cycle.",
      "Bring a hat and water because the site is exposed.",
      "Pair this with Sigiriya only if you begin very early.",
    ],
    nearbyPlaces: ["Sigiriya", "Dambulla", "Minneriya"],
  ),
  "Dambulla": const PlaceExtraInfo(
    headline:
        "Best as a cultural-triangle base with one of the island's most important cave temple visits.",
    bestSeason: "January to April",
    bestTime: "Morning or late afternoon",
    idealDuration: "Half day or one night",
    budget: "Cave temple entry is paid for most foreign visitors.",
    transportTip:
        "Dambulla is most useful as a base for Sigiriya, Pidurangala, and other cultural-triangle stops.",
    localTip:
        "The steps are straightforward but the rock surface can feel hot later in the day.",
    thingsToDo: [
      "Visit the cave temple complex",
      "Use Dambulla as a base for triangle day trips",
      "Combine with Sigiriya and Pidurangala",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Cave temple climb",
        details:
            "Start before the steps heat up and before tour buses arrive in larger waves.",
        costNote: "Paid entry",
      ),
      VisitStop(
        time: "Late morning",
        title: "Museum or local lunch break",
        details:
            "Slow the pace after the temple instead of trying to squeeze too much into the same hour.",
        costNote: "Low to mixed",
      ),
      VisitStop(
        time: "Afternoon option",
        title: "Move to Sigiriya or Pidurangala",
        details:
            "Good if you are using Dambulla as the center of a wider triangle route.",
        costNote: "Transport cost",
      ),
    ],
    quickTips: [
      "Temple dress rules matter here too.",
      "Carry water for the approach steps.",
      "It is a strong same-day pairing with Sigiriya.",
    ],
    nearbyPlaces: ["Sigiriya", "Pidurangala", "Polonnaruwa"],
  ),
  "Unawatuna": const PlaceExtraInfo(
    headline:
        "Best for easy swimming, a softer beach mood than city Galle, and short coastal day trips.",
    bestSeason: "December to April",
    bestTime: "Morning and sunset",
    idealDuration: "1 to 2 nights",
    budget: "Simple beach days are affordable; snorkeling and cafes raise the spend.",
    transportTip:
        "Stay close to the bay if swimming matters most, or closer to the hills if you want quieter nights.",
    localTip:
        "The bay is usually gentler than some surf beaches, which is why so many travelers choose it for easy water time.",
    thingsToDo: [
      "Swim and relax in the bay",
      "Try beach cafes",
      "Take short trips to Galle and Jungle Beach",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Main bay swim",
        details:
            "The water is usually friendliest earlier in the day before the beach fills out.",
        costNote: "Free",
      ),
      VisitStop(
        time: "Late morning",
        title: "Jungle Beach or short snorkel stop",
        details:
            "Use this if you want a little more movement than simply staying on one beach all day.",
        costNote: "Low to mixed",
      ),
      VisitStop(
        time: "Evening",
        title: "Galle Fort dinner option",
        details:
            "An easy upgrade if you want a more atmospheric dinner without changing hotels.",
        costNote: "Mixed",
      ),
    ],
    quickTips: [
      "This is one of the easiest beach bases near Galle.",
      "Use sunscreen early; shade fills up quickly.",
      "Beach weekends can feel much busier than weekdays.",
    ],
    nearbyPlaces: ["Galle", "Habaraduwa", "Mirissa"],
  ),
  "Hikkaduwa": const PlaceExtraInfo(
    headline:
        "Best for lively beach energy, snorkeling, and a more social south-coast stay.",
    bestSeason: "December to April",
    bestTime: "Morning for water clarity, evening for nightlife",
    idealDuration: "1 to 2 nights",
    budget: "Beach time is flexible; diving and nightlife are where cost rises.",
    transportTip:
        "Stay near the beach strip if you want everything within walking distance.",
    localTip:
        "Choose your exact stretch carefully because Hikkaduwa changes from relaxed to lively quickly.",
    thingsToDo: [
      "Snorkel or dive near the reef",
      "Try beginner-friendly surf breaks",
      "Enjoy beach restaurants and nightlife",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Reef or water activity",
        details:
            "Morning conditions are usually more comfortable for snorkeling or diving plans.",
        costNote: "Free beach access, paid equipment or tours",
      ),
      VisitStop(
        time: "Afternoon",
        title: "Beach downtime",
        details:
            "Use the afternoon for easy beach time and cafe breaks rather than overplanning the day.",
        costNote: "Flexible",
      ),
      VisitStop(
        time: "Evening",
        title: "Food and nightlife",
        details:
            "This is where Hikkaduwa stands apart from quieter beach towns nearby.",
        costNote: "Mixed",
      ),
    ],
    quickTips: [
      "Pick a quieter hotel if you are a light sleeper.",
      "Water visibility varies by day and weather.",
      "Good as a social stop, not the calmest honeymoon base.",
    ],
    nearbyPlaces: ["Galle", "Bentota", "Unawatuna"],
  ),
  "Bentota": const PlaceExtraInfo(
    headline:
        "Best for resort-style beach stays, river activities, and smoother family or couple pacing.",
    bestSeason: "December to April",
    bestTime: "Morning and sunset",
    idealDuration: "1 to 2 nights",
    budget: "Mid-range to premium depending on hotel style and water activities.",
    transportTip:
        "Bentota works best if you stay in a beach resort area and add short river or turtle-centre trips.",
    localTip:
        "This is a strong choice when you want a polished beach stop instead of a backpacker scene.",
    thingsToDo: [
      "Enjoy calm beach time",
      "Try water sports",
      "Take a Bentota River safari",
    ],
    visitPlan: [
      VisitStop(
        time: "8:30 AM",
        title: "Beach morning",
        details:
            "Use the cooler part of the day for swimming and longer time by the sea.",
        costNote: "Free with public access or included with hotel stay",
      ),
      VisitStop(
        time: "2:30 PM",
        title: "Bentota River safari",
        details:
            "A good contrast to the beach if you want mangroves and wildlife instead of only sea time.",
        costNote: "Paid boat ride",
      ),
      VisitStop(
        time: "Sunset",
        title: "Quiet resort evening",
        details:
            "Bentota shines when you slow down and enjoy the property or beach rather than rushing around.",
        costNote: "Flexible",
      ),
    ],
    quickTips: [
      "Great for travelers who want comfort over nightlife.",
      "River trips are easiest to arrange through hotels or trusted boatmen.",
      "This stop works well right before returning to Colombo.",
    ],
    nearbyPlaces: ["Kosgoda", "Hikkaduwa", "Colombo"],
  ),
  "Jaffna": const PlaceExtraInfo(
    headline:
        "Best for travelers who want a different cultural rhythm, Tamil heritage, and island-hopping options.",
    bestSeason: "May to September",
    bestTime: "Morning and evening",
    idealDuration: "2 nights",
    budget: "Usually good value, with island trips adding transport cost.",
    transportTip:
        "Keep extra time for longer northern journeys; Jaffna is rewarding when you avoid rushing.",
    localTip:
        "Food is a highlight here, so leave space for local crab, curries, and short eats.",
    thingsToDo: [
      "Visit Nallur Kandaswamy Temple",
      "Try northern Sri Lankan food",
      "Add Delft or nearby islands if transport lines up",
    ],
    visitPlan: [
      VisitStop(
        time: "8:00 AM",
        title: "Nallur Temple area",
        details:
            "A strong first stop for grounding yourself in the city's identity and rhythm.",
        costNote: "Free or donation-based",
      ),
      VisitStop(
        time: "Midday",
        title: "Local food stop",
        details:
            "Jaffna rewards slow meals more than checklist tourism.",
        costNote: "Low to mixed",
      ),
      VisitStop(
        time: "Extra day",
        title: "Island excursion",
        details:
            "Add Delft or another island only if you have enough time and current transport is working well.",
        costNote: "Paid transport",
      ),
    ],
    quickTips: [
      "Temperatures can feel dry and strong.",
      "A second night improves the Jaffna experience a lot.",
      "Check island transport locally before committing.",
    ],
    nearbyPlaces: ["Delft Island", "Nagadeepa", "Casuarina Beach"],
  ),
  "Horton Plains": const PlaceExtraInfo(
    headline:
        "Best for a cool-climate national-park walk where timing matters more than almost anything else.",
    bestSeason: "January to April",
    bestTime: "Very early morning",
    idealDuration: "Half day from Nuwara Eliya or one nearby night",
    budget: "Paid national-park stop with transport cost.",
    transportTip:
        "Leave very early from Nuwara Eliya or Ohiya to reach the trail before clouds and queues grow.",
    localTip:
        "World's End can completely cloud over later in the day, so a late start can waste the main reason to come.",
    thingsToDo: [
      "Walk to World's End",
      "See cloud forest scenery",
      "Visit Baker's Falls on the same loop",
    ],
    visitPlan: [
      VisitStop(
        time: "6:30 AM",
        title: "Park entry and trail start",
        details:
            "Start as early as possible if the viewpoint matters to you.",
        costNote: "Paid park fee",
      ),
      VisitStop(
        time: "8:00 AM to 9:00 AM",
        title: "World's End",
        details:
            "Aim to reach this section before mist starts closing the view.",
        costNote: "Included",
      ),
      VisitStop(
        time: "Return loop",
        title: "Baker's Falls",
        details:
            "A rewarding extra on the loop if the trail is not too slippery from rain.",
        costNote: "Included",
      ),
    ],
    quickTips: [
      "Wear layers; the morning can feel cold.",
      "Do not count on clear views after late morning.",
      "Rain can change the trail feel quickly.",
    ],
    nearbyPlaces: ["Nuwara Eliya", "Ohiya", "Ella"],
  ),
  "Pidurangala": const PlaceExtraInfo(
    headline:
        "Best for the classic Sigiriya-facing panorama and a shorter adventurous climb with strong photo payoff.",
    bestSeason: "January to April",
    bestTime: "Sunrise or sunset",
    idealDuration: "Half day",
    budget: "Low paid entry or donation style compared with major heritage sites.",
    transportTip:
        "It is easiest to pair Pidurangala with Sigiriya if you stay nearby and avoid the hottest midday hours.",
    localTip:
        "The final rock section needs care, especially in low light or after rain.",
    thingsToDo: [
      "Climb for Sigiriya-facing views",
      "Take sunrise or sunset photos",
      "Combine with Sigiriya and Dambulla",
    ],
    visitPlan: [
      VisitStop(
        time: "5:15 AM or 4:45 PM",
        title: "Ascent",
        details:
            "Pick sunrise for softer views or sunset for warmer light depending on your energy and plan.",
        costNote: "Low paid entry",
      ),
      VisitStop(
        time: "Viewpoint window",
        title: "Rock-top photo time",
        details:
            "Give yourself time instead of rushing straight back down after reaching the top.",
        costNote: "Included",
      ),
      VisitStop(
        time: "Same day option",
        title: "Add Sigiriya or Dambulla",
        details:
            "Works well when you build one cultural-triangle day around sunrise or sunset timing.",
        costNote: "Transport plus separate entries",
      ),
    ],
    quickTips: [
      "Take a phone light or headlamp for very early starts.",
      "Good shoes matter on the last section.",
      "Do not expect shade during the climb.",
    ],
    nearbyPlaces: ["Sigiriya", "Dambulla", "Minneriya"],
  ),
  "Udawalawe": const PlaceExtraInfo(
    headline:
        "Best for reliable elephant sightings and a simpler safari stop than Yala for many travelers.",
    bestSeason: "Year round",
    bestTime: "Morning safari",
    idealDuration: "1 night",
    budget: "Paid safari destination, usually slightly easier to plan than bigger parks.",
    transportTip:
        "Stay near the park or transit home area so you can start early without a long transfer.",
    localTip:
        "If elephants matter more than leopards, Udawalawe is often the easier recommendation.",
    thingsToDo: [
      "Take a jeep safari for elephant sightings",
      "Visit the elephant transit home nearby",
      "Use it as a south-hills route stop",
    ],
    visitPlan: [
      VisitStop(
        time: "6:00 AM",
        title: "Morning safari",
        details:
            "This is usually the strongest window for cooler air and animal movement.",
        costNote: "Paid jeep plus park fees",
      ),
      VisitStop(
        time: "Late morning",
        title: "Elephant transit home area",
        details:
            "A good follow-up if the current visitor timing works on your day.",
        costNote: "Usually paid or timed access",
      ),
      VisitStop(
        time: "Afternoon",
        title: "Travel onward",
        details:
            "Udawalawe is excellent as a clean one-night wildlife break before moving back to hills or coast.",
        costNote: "Transport cost",
      ),
    ],
    quickTips: [
      "Book a reputable jeep to keep the experience smoother.",
      "Dust and sun cover both matter here.",
      "This is a good family-friendly wildlife choice.",
    ],
    nearbyPlaces: ["Ella", "Tissamaharama", "Yala National Park"],
  ),
};
