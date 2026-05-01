import { createHash } from 'node:crypto';

const starterPlaces = [
  {
    id: 'ella',
    name: 'Ella',
    type: 'Hill country',
    region: 'Badulla',
    featured: true,
    budgetLevel: 'medium',
    bestTime: 'Sunrise to sunset',
    lat: 6.8667,
    lng: 81.0466,
    status: 'active',
  },
  {
    id: 'galle',
    name: 'Galle',
    type: 'Heritage',
    region: 'Southern',
    featured: true,
    budgetLevel: 'medium',
    bestTime: 'Late afternoon',
    lat: 6.032,
    lng: 80.2168,
    status: 'active',
  },
  {
    id: 'sigiriya',
    name: 'Sigiriya',
    type: 'Heritage',
    region: 'Cultural Triangle',
    featured: true,
    budgetLevel: 'premium',
    bestTime: 'Early morning',
    lat: 7.957,
    lng: 80.7603,
    status: 'active',
  },
  {
    id: 'kandy',
    name: 'Kandy',
    type: 'Culture',
    region: 'Central',
    featured: true,
    budgetLevel: 'medium',
    bestTime: 'Morning and evening',
    lat: 7.2906,
    lng: 80.6337,
    status: 'active',
  },
  {
    id: 'mirissa',
    name: 'Mirissa',
    type: 'Beach',
    region: 'Southern',
    featured: true,
    budgetLevel: 'medium',
    bestTime: 'Late afternoon',
    lat: 5.9465,
    lng: 80.4584,
    status: 'active',
  },
  {
    id: 'trincomalee',
    name: 'Trincomalee',
    type: 'Beach',
    region: 'Eastern',
    featured: true,
    budgetLevel: 'medium',
    bestTime: 'Morning',
    lat: 8.5874,
    lng: 81.2152,
    status: 'active',
  },
  {
    id: 'colombo',
    name: 'Colombo',
    type: 'City',
    region: 'Western',
    featured: false,
    budgetLevel: 'mixed',
    bestTime: 'Evening',
    lat: 6.9271,
    lng: 79.8612,
    status: 'active',
  },
  {
    id: 'yala',
    name: 'Yala National Park',
    type: 'Wildlife',
    region: 'Southern',
    featured: true,
    budgetLevel: 'premium',
    bestTime: 'Morning safari',
    lat: 6.3725,
    lng: 81.5185,
    status: 'active',
  },
];

const starterAlerts = [
  {
    id: 'alert-1',
    title: 'Late-night beach tuk pricing',
    zone: 'South coast tourist belt',
    severity: 'medium',
    message:
      'Advise travelers to check the fair price card before accepting tuk rides after 9 PM.',
    active: true,
    updatedAt: '2026-05-01T00:00:00.000Z',
  },
  {
    id: 'alert-2',
    title: 'Unofficial ticket helpers',
    zone: 'Sigiriya outer approach',
    severity: 'high',
    message:
      'Warn travelers not to buy unofficial entry help or side-access tickets from roadside sellers.',
    active: true,
    updatedAt: '2026-05-01T00:00:00.000Z',
  },
];

const starterAnalytics = [
  {
    id: 'evt-1',
    name: 'app_open',
    userId: 'seed-user',
    metadata: { source: 'seed' },
    timestamp: new Date().toISOString(),
  },
  {
    id: 'evt-2',
    name: 'map_search',
    userId: 'seed-user',
    metadata: { placeName: 'Ella' },
    timestamp: new Date().toISOString(),
  },
  {
    id: 'evt-3',
    name: 'assistant_message',
    userId: 'seed-user',
    metadata: { topic: 'itinerary' },
    timestamp: new Date().toISOString(),
  },
];

export async function seedInitialState(store) {
  await store.mutate(async (state) => {
    if (state.users.length > 0 || state.places.length > 0) {
      return state;
    }

    const now = new Date().toISOString();
    const adminUser = {
      id: 'admin-user',
      fullName: 'SD Platform Admin',
      email: 'admin@sdtravel.local',
      phone: '+94770000000',
      passwordHash: createHash('sha256').update('Admin123!').digest('hex'),
      role: 'admin',
      premium: true,
      preferences: {
        interest: 'mixed',
        budget: 'luxury',
        style: 'exploreEverything',
        food: 'both',
        mood: 'culture',
      },
      travelPersonality: 'Operations Captain',
      history: {
        savedPlaces: ['ella', 'galle'],
        itineraries: [],
      },
      behavior: {
        logins: 14,
        assistantMessages: 9,
        mapSearches: 7,
        translatorUses: 2,
        itineraryGenerations: 4,
      },
      isOnboardingComplete: true,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    };

    return {
      ...state,
      users: [adminUser],
      places: starterPlaces,
      safetyAlerts: starterAlerts,
      analyticsEvents: starterAnalytics,
    };
  });
}
