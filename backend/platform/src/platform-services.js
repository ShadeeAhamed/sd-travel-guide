import { createHash, randomUUID } from 'node:crypto';

function nowIso() {
  return new Date().toISOString();
}

function hashPassword(password) {
  return createHash('sha256').update(password).digest('hex');
}

function sanitizeUser(user) {
  const { passwordHash, ...safeUser } = user;
  return safeUser;
}

function sanitizeChallenge(challenge) {
  return {
    id: challenge.id,
    channel: challenge.channel,
    purpose: challenge.purpose,
    maskedDestination: maskDestination(challenge.destination, challenge.channel),
    expiresAt: challenge.expiresAt,
    createdAt: challenge.createdAt,
  };
}

function personalityFromPreferences(preferences) {
  if (
    preferences.interest === 'beach' &&
    preferences.style === 'relax'
  ) {
    return 'Coastal Dreamer';
  }
  if (
    preferences.interest === 'hiking' &&
    preferences.style === 'adventure'
  ) {
    return 'Summit Seeker';
  }
  if (preferences.interest === 'culture') {
    return 'Heritage Hunter';
  }
  if (preferences.budget === 'luxury') {
    return 'Signature Voyager';
  }
  return 'Island Explorer';
}

function buildOtpChallenge({ userId, destination, channel, purpose }) {
  return {
    id: randomUUID(),
    userId,
    destination,
    channel,
    purpose,
    code: String(100000 + Math.floor(Math.random() * 900000)),
    expiresAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
    createdAt: nowIso(),
  };
}

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function normalizePhone(phone) {
  return String(phone || '').trim();
}

function maskDestination(destination, channel) {
  if (channel === 'sms') {
    const phone = normalizePhone(destination);
    if (phone.length <= 4) {
      return phone;
    }
    return `${phone.slice(0, 3)}*****${phone.slice(-2)}`;
  }

  const email = normalizeEmail(destination);
  if (!email.includes('@')) {
    return email;
  }
  const [local, domain] = email.split('@');
  const visible = local.length <= 2 ? local : `${local[0]}${local[1]}`;
  return `${visible}***@${domain}`;
}

function buildChallengeResponse(challenge) {
  return {
    challengeId: challenge.id,
    userId: challenge.userId,
    channel: challenge.channel,
    maskedDestination: maskDestination(
      challenge.destination,
      challenge.channel,
    ),
    expiresAt: challenge.expiresAt,
    debugCode: challenge.code,
    deliveryStatus: 'developerPreview',
    deliveryMessage: '',
  };
}

async function sendEmailViaResend({ challenge, config }) {
  if (!config.resendApiKey || !config.emailFrom) {
    return {
      status: 'developerPreview',
      message:
        'Email sending is not configured on this server yet. The developer verification code is still shown in the app.',
    };
  }

  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${config.resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: config.emailFrom,
        to: [challenge.destination],
        subject: `${config.appName} verification code`,
        html: `
          <div style="font-family: Arial, sans-serif; color: #111827; line-height: 1.5;">
            <h2 style="margin-bottom: 12px;">${config.appName}</h2>
            <p>Your verification code is:</p>
            <div style="font-size: 32px; font-weight: 700; letter-spacing: 6px; margin: 16px 0;">${challenge.code}</div>
            <p>This code expires in 5 minutes.</p>
          </div>
        `,
      }),
    });

    if (response.ok) {
      return {
        status: 'emailSent',
        message:
          'A verification code was sent to your email. The same code is also shown here for developer testing.',
      };
    }

    return {
      status: 'emailFailed',
      message:
        'Email delivery failed on the server, so use the developer verification code shown in the app.',
    };
  } catch (_) {
    return {
      status: 'emailFailed',
      message:
        'The email service could not be reached, so use the developer verification code shown in the app.',
    };
  }
}

async function deliverOtpChallenge(challenge, config) {
  if (challenge.channel === 'sms') {
    return {
      status: 'developerPreview',
      message:
        'SMS delivery is not configured on this server yet. Use the developer verification code shown in the app.',
    };
  }

  if (config.emailProvider === 'resend') {
    return sendEmailViaResend({ challenge, config });
  }

  return {
    status: 'developerPreview',
    message:
      'Email sending is not configured on this server yet. The developer verification code is still shown in the app.',
  };
}

function countToday(events) {
  const today = new Date().toISOString().slice(0, 10);
  return events.filter((event) => String(event.timestamp).startsWith(today)).length;
}

function summarizeEventCounts(events) {
  const counts = {};
  for (const event of events) {
    counts[event.name] = (counts[event.name] || 0) + 1;
  }
  return Object.entries(counts)
    .sort((left, right) => right[1] - left[1])
    .map(([name, count]) => ({ name, count }));
}

function topPlaceSearches(events) {
  const counts = {};
  for (const event of events) {
    const placeName = event.metadata?.placeName;
    if (!placeName) {
      continue;
    }
    counts[placeName] = (counts[placeName] || 0) + 1;
  }
  return Object.entries(counts)
    .sort((left, right) => right[1] - left[1])
    .slice(0, 8)
    .map(([placeName, count]) => ({ placeName, count }));
}

function scorePlace(place, preferences) {
  let score = place.featured ? 3 : 0;
  const type = String(place.type || '').toLowerCase();
  const name = String(place.name || '').toLowerCase();

  switch (preferences.interest) {
    case 'beach':
      if (type.includes('beach')) score += 6;
      if (name.includes('mirissa') || name.includes('trincomalee')) score += 2;
      break;
    case 'waterfalls':
      if (name.includes('ella')) score += 5;
      break;
    case 'hiking':
      if (type.includes('hill') || type.includes('wildlife')) score += 4;
      break;
    case 'culture':
      if (type.includes('heritage') || type.includes('culture')) score += 6;
      break;
    default:
      score += 2;
  }

  switch (preferences.mood) {
    case 'chill':
      if (type.includes('beach')) score += 2;
      break;
    case 'adventure':
      if (type.includes('wildlife') || type.includes('hill')) score += 2;
      break;
    case 'luxury':
      if (name.includes('colombo') || name.includes('galle')) score += 1;
      break;
    case 'culture':
      if (type.includes('heritage') || type.includes('culture')) score += 2;
      break;
    default:
      break;
  }

  return score;
}

function recommendPlaces(places, preferences, limit = 4) {
  return [...places]
    .sort((left, right) => {
      return scorePlace(right, preferences) - scorePlace(left, preferences);
    })
    .slice(0, limit);
}

function buildAssistantResponse({
  message,
  user,
  location,
  weather,
  currentTime,
  places,
}) {
  const preferences = user?.preferences || {
    interest: 'mixed',
    budget: 'medium',
    style: 'exploreEverything',
    food: 'both',
    mood: 'chill',
  };
  const lowered = String(message || '').toLowerCase();
  const topPlaces = recommendPlaces(places, preferences, 3);
  const weatherText = weather?.condition
    ? `Weather looks ${weather.condition}${weather.temperatureC ? ` at about ${weather.temperatureC}C` : ''}.`
    : 'Live weather is not connected yet, so this reply is using your profile and local travel logic.';
  const timeText = currentTime
    ? `It is currently ${currentTime}.`
    : 'Current local time was not provided.';

  if (lowered.includes('what should i do now') || lowered.includes('plan my day')) {
    return {
      answer:
        `${timeText} ${weatherText} Based on your ${preferences.mood} mood and ${preferences.interest} interest, start with ${topPlaces[0]?.name || 'a nearby highlight'}, then keep ${topPlaces[1]?.name || 'a food stop'} as your second move. Finish with ${topPlaces[2]?.name || 'a sunset-friendly place'} for a smoother day.`,
      suggestions: topPlaces.map((place) => place.name),
      mode: 'local-context',
    };
  }

  if (lowered.includes('best places near me') || lowered.includes('near me')) {
    return {
      answer:
        `${weatherText} The strongest nearby-style picks for this traveler profile are ${topPlaces.map((place) => place.name).join(', ')}. Once live location routing is wired into this platform, this endpoint can sort them by distance from ${location?.lat && location?.lng ? `${location.lat}, ${location.lng}` : 'your current pin'}.`,
      suggestions: topPlaces.map((place) => place.name),
      mode: 'local-context',
    };
  }

  if (lowered.includes('sunset')) {
    return {
      answer:
        `For a premium sunset recommendation flow, prioritize Galle ramparts, Mirissa, or Trincomalee depending on which coast you are near. Your current mood is ${preferences.mood}, so the app should bias toward a lower-stress route with food and transport built in.`,
      suggestions: ['Galle', 'Mirissa', 'Trincomalee'],
      mode: 'local-context',
    };
  }

  return {
    answer:
      `This backend is ready to be your real travel control layer. For this traveler profile, the best current matches are ${topPlaces.map((place) => place.name).join(', ')}. ${weatherText}`,
    suggestions: topPlaces.map((place) => place.name),
    mode: 'local-context',
  };
}

function buildDayPlan(dayNumber, place) {
  return {
    dayNumber,
    theme: `${place.name} focus day`,
    stops: [
      {
        title: `${place.name} arrival`,
        timing: '8:00 AM',
        summary: `Start in ${place.name} during its best window: ${place.bestTime}.`,
        cost: place.budgetLevel === 'premium' ? 'Higher spend expected' : 'Manageable spend',
      },
      {
        title: `Explore ${place.type.toLowerCase()} highlights`,
        timing: '11:30 AM',
        summary: `Use the middle of the day for a structured route around ${place.region}.`,
        cost: 'Mixed',
      },
      {
        title: 'Late-day finish',
        timing: '5:30 PM',
        summary: 'Reserve golden hour for photos, dinner, or a lower-stress final stop.',
        cost: 'Flexible',
      },
    ],
  };
}

function behaviorKeyForEvent(name) {
  switch (name) {
    case 'assistant_message':
      return 'assistantMessages';
    case 'map_search':
      return 'mapSearches';
    case 'translator_use':
      return 'translatorUses';
    case 'itinerary_generation':
      return 'itineraryGenerations';
    case 'login':
      return 'logins';
    default:
      return null;
  }
}

function sanitizeDatabaseSnapshot(state, config) {
  return {
    provider: config.dataProvider,
    localFile:
      config.dataProvider === 'local'
        ? config.dataFile
        : 'Firestore provider does not expose a local JSON file.',
    collections: {
      users: state.users.map((user) => sanitizeUser(user)),
      otpChallenges: state.otpChallenges.map((challenge) =>
        sanitizeChallenge(challenge),
      ),
      places: state.places,
      safetyAlerts: state.safetyAlerts,
      analyticsEvents: state.analyticsEvents,
      settings: state.settings,
    },
  };
}

export function createPlatformServices({ store, config }) {
  return {
    async register(payload) {
      const fullName = String(payload.fullName || '').trim();
      const email = normalizeEmail(payload.email);
      const phone = normalizePhone(payload.phone);
      const password = String(payload.password || '');

      if (!fullName || !email || !phone || password.length < 6) {
        return {
          status: 400,
          body: { error: 'Complete all fields and use a password with at least 6 characters.' },
        };
      }

      const result = await store.mutate(async (state) => {
        const existingEmail = state.users.find((user) => user.email === email);
        if (existingEmail) {
          return { ...state, __error: 'An account already exists for that email.' };
        }
        const existingPhone = state.users.find((user) => user.phone === phone);
        if (existingPhone) {
          return { ...state, __error: 'An account already exists for that phone number.' };
        }

        const userId = randomUUID();
        const user = {
          id: userId,
          fullName,
          email,
          phone,
          passwordHash: hashPassword(password),
          role: 'traveler',
          premium: false,
          preferences: {
            interest: 'mixed',
            budget: 'medium',
            style: 'exploreEverything',
            food: 'both',
            mood: 'chill',
          },
          travelPersonality: 'New Explorer',
          history: {
            savedPlaces: [],
            itineraries: [],
          },
          behavior: {
            logins: 0,
            assistantMessages: 0,
            mapSearches: 0,
            translatorUses: 0,
            itineraryGenerations: 0,
          },
          isOnboardingComplete: false,
          status: 'active',
          createdAt: nowIso(),
          updatedAt: nowIso(),
        };

        const challenge = buildOtpChallenge({
          userId,
          destination: email,
          channel: 'email',
          purpose: 'signup',
        });

        return {
          ...state,
          users: [...state.users, user],
          otpChallenges: [
            ...state.otpChallenges.filter((item) => item.userId !== userId),
            challenge,
          ],
          __response: buildChallengeResponse(challenge),
          __challenge: challenge,
        };
      });

      if (result.__error) {
        return { status: 409, body: { error: result.__error } };
      }

      const delivery = await deliverOtpChallenge(result.__challenge, config);
      return {
        status: 200,
        body: {
          ...result.__response,
          deliveryStatus: delivery.status,
          deliveryMessage: delivery.message,
        },
      };
    },

    async loginWithEmail(payload) {
      const email = normalizeEmail(payload.email);
      const password = String(payload.password || '');
      const state = await store.getState();
      const user = state.users.find((item) => item.email === email);
      if (!user || user.passwordHash !== hashPassword(password)) {
        return { status: 401, body: { error: 'Incorrect email or password.' } };
      }

      const challenge = buildOtpChallenge({
        userId: user.id,
        destination: user.email,
        channel: 'email',
        purpose: 'login',
      });

      await store.mutate(async (current) => ({
        ...current,
        otpChallenges: [
          ...current.otpChallenges.filter((item) => item.userId !== user.id),
          challenge,
        ],
      }));

      const delivery = await deliverOtpChallenge(challenge, config);
      return {
        status: 200,
        body: {
          ...buildChallengeResponse(challenge),
          deliveryStatus: delivery.status,
          deliveryMessage: delivery.message,
        },
      };
    },

    async loginWithPhone(payload) {
      const phone = normalizePhone(payload.phone);
      const state = await store.getState();
      const user = state.users.find((item) => item.phone === phone);
      if (!user) {
        return { status: 404, body: { error: 'No account was found for that phone number.' } };
      }

      const challenge = buildOtpChallenge({
        userId: user.id,
        destination: user.phone,
        channel: 'sms',
        purpose: 'login',
      });

      await store.mutate(async (current) => ({
        ...current,
        otpChallenges: [
          ...current.otpChallenges.filter((item) => item.userId !== user.id),
          challenge,
        ],
      }));

      const delivery = await deliverOtpChallenge(challenge, config);
      return {
        status: 200,
        body: {
          ...buildChallengeResponse(challenge),
          deliveryStatus: delivery.status,
          deliveryMessage: delivery.message,
        },
      };
    },

    async verifyOtp(payload) {
      const challengeId = String(payload.challengeId || '').trim();
      const code = String(payload.code || '').trim();

      const result = await store.mutate(async (state) => {
        const challenge = state.otpChallenges.find((item) => item.id === challengeId);
        if (!challenge) {
          return { ...state, __error: 'Verification code not found or expired.' };
        }
        if (new Date(challenge.expiresAt).getTime() < Date.now()) {
          return {
            ...state,
            otpChallenges: state.otpChallenges.filter((item) => item.id !== challenge.id),
            __error: 'Verification code expired.',
          };
        }
        if (challenge.code !== code) {
          return { ...state, __error: 'Verification code is incorrect.' };
        }

        const userIndex = state.users.findIndex((item) => item.id === challenge.userId);
        if (userIndex < 0) {
          return { ...state, __error: 'User account not found.' };
        }

        const nextUser = {
          ...state.users[userIndex],
          behavior: {
            ...state.users[userIndex].behavior,
            logins: (state.users[userIndex].behavior?.logins || 0) + 1,
          },
          updatedAt: nowIso(),
        };

        const nextUsers = [...state.users];
        nextUsers[userIndex] = nextUser;

        return {
          ...state,
          users: nextUsers,
          otpChallenges: state.otpChallenges.filter((item) => item.id !== challenge.id),
          __response: {
            token: `dev-token-${nextUser.id}`,
            user: sanitizeUser(nextUser),
          },
        };
      });

      if (result.__error) {
        return { status: 400, body: { error: result.__error } };
      }

      return { status: 200, body: result.__response };
    },

    async getProfile(query) {
      const userId = String(query.userId || '').trim();
      if (!userId) {
        return { status: 400, body: { error: 'userId is required.' } };
      }

      const state = await store.getState();
      const user = state.users.find((item) => item.id === userId);
      if (!user) {
        return { status: 404, body: { error: 'User not found.' } };
      }

      return { status: 200, body: sanitizeUser(user) };
    },

    async updatePreferences(payload) {
      const userId = String(payload.userId || '').trim();
      const preferences = payload.preferences || {};
      if (!userId) {
        return { status: 400, body: { error: 'userId is required.' } };
      }

      const result = await store.mutate(async (state) => {
        const userIndex = state.users.findIndex((item) => item.id === userId);
        if (userIndex < 0) {
          return { ...state, __error: 'User not found.' };
        }

        const currentUser = state.users[userIndex];
        const nextPreferences = {
          ...currentUser.preferences,
          ...preferences,
        };
        const nextUser = {
          ...currentUser,
          preferences: nextPreferences,
          travelPersonality: personalityFromPreferences(nextPreferences),
          isOnboardingComplete: true,
          updatedAt: nowIso(),
        };
        const nextUsers = [...state.users];
        nextUsers[userIndex] = nextUser;

        return {
          ...state,
          users: nextUsers,
          __response: sanitizeUser(nextUser),
        };
      });

      if (result.__error) {
        return { status: 404, body: { error: result.__error } };
      }

      return { status: 200, body: result.__response };
    },

    async trackEvent(payload) {
      const event = {
        id: randomUUID(),
        name: String(payload.name || '').trim() || 'unknown_event',
        userId: String(payload.userId || '').trim() || null,
        metadata: payload.metadata || {},
        timestamp: nowIso(),
      };

      await store.mutate(async (state) => {
        const nextState = {
          ...state,
          analyticsEvents: [...state.analyticsEvents, event].slice(-5000),
        };

        const behaviorKey = behaviorKeyForEvent(event.name);
        if (!behaviorKey || !event.userId) {
          return nextState;
        }

        const userIndex = state.users.findIndex((item) => item.id === event.userId);
        if (userIndex < 0) {
          return nextState;
        }

        const currentUser = state.users[userIndex];
        const nextUsers = [...state.users];
        nextUsers[userIndex] = {
          ...currentUser,
          behavior: {
            ...currentUser.behavior,
            [behaviorKey]: (currentUser.behavior?.[behaviorKey] || 0) + 1,
          },
          updatedAt: nowIso(),
        };

        return {
          ...nextState,
          users: nextUsers,
        };
      });

      return { status: 200, body: { ok: true, eventId: event.id } };
    },

    async assistantRespond(payload) {
      const state = await store.getState();
      const user = state.users.find((item) => item.id === payload.userId) || null;

      const localResponse = buildAssistantResponse({
        message: payload.message,
        user,
        location: payload.location,
        weather: payload.weather,
        currentTime: payload.time,
        places: state.places,
      });

      if (payload.useLiveAi && config.aiProxyUrl) {
        try {
          const response = await fetch(config.aiProxyUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              messages: [
                {
                  role: 'user',
                  content: payload.message,
                },
              ],
            }),
          });

          if (response.ok) {
            const data = await response.json();
            return {
              status: 200,
              body: {
                ...localResponse,
                aiAnswer: data.answer,
                sources: data.sources || [],
                mode: 'live-ai',
              },
            };
          }
        } catch (_) {
          // fall back to local response
        }
      }

      return { status: 200, body: localResponse };
    },

    async generateItinerary(payload) {
      const preferences = {
        interest: payload.preferences?.interest || 'mixed',
        budget: payload.preferences?.budget || 'medium',
        style: payload.preferences?.style || 'exploreEverything',
        food: payload.preferences?.food || 'both',
        mood: payload.preferences?.mood || 'chill',
      };
      const days = Math.max(1, Math.min(7, Number(payload.days || 1)));
      const state = await store.getState();
      const matches = recommendPlaces(state.places, preferences, days);
      const itinerary = matches.map((place, index) => buildDayPlan(index + 1, place));

      return {
        status: 200,
        body: {
          travelerMood: preferences.mood,
          days,
          itinerary,
        },
      };
    },

    async getAdminOverview() {
      const state = await store.getState();
      return {
        status: 200,
        body: {
          totalUsers: state.users.length,
          activeUsers: state.users.filter((user) => user.status === 'active').length,
          premiumUsers: state.users.filter((user) => user.premium).length,
          activeAlerts: state.safetyAlerts.filter((alert) => alert.active).length,
          featuredPlaces: state.places.filter((place) => place.featured).length,
          eventsToday: countToday(state.analyticsEvents),
          topEvents: summarizeEventCounts(state.analyticsEvents).slice(0, 5),
          topSearches: topPlaceSearches(state.analyticsEvents),
        },
      };
    },

    async getAdminUsers() {
      const state = await store.getState();
      return {
        status: 200,
        body: state.users.map((user) => sanitizeUser(user)),
      };
    },

    async getAdminPlaces() {
      const state = await store.getState();
      return { status: 200, body: state.places };
    },

    async saveAdminPlace(payload, placeId = null) {
      const nextPlace = {
        id: placeId || String(payload.id || '').trim() || randomUUID(),
        name: String(payload.name || '').trim(),
        type: String(payload.type || '').trim() || 'General',
        region: String(payload.region || '').trim() || 'Sri Lanka',
        featured: Boolean(payload.featured),
        budgetLevel: String(payload.budgetLevel || 'medium'),
        bestTime: String(payload.bestTime || 'Flexible'),
        lat: Number(payload.lat || 0),
        lng: Number(payload.lng || 0),
        status: String(payload.status || 'active'),
        updatedAt: nowIso(),
      };

      if (!nextPlace.name) {
        return { status: 400, body: { error: 'Place name is required.' } };
      }

      const result = await store.mutate(async (state) => {
        const existingIndex = state.places.findIndex((item) => item.id === nextPlace.id);
        if (existingIndex >= 0) {
          const nextPlaces = [...state.places];
          nextPlaces[existingIndex] = {
            ...nextPlaces[existingIndex],
            ...nextPlace,
          };
          return { ...state, places: nextPlaces, __response: nextPlaces[existingIndex] };
        }

        return {
          ...state,
          places: [...state.places, nextPlace],
          __response: nextPlace,
        };
      });

      return { status: 200, body: result.__response };
    },

    async getSafetyAlerts() {
      const state = await store.getState();
      return { status: 200, body: state.safetyAlerts };
    },

    async saveSafetyAlert(payload) {
      const alert = {
        id: String(payload.id || '').trim() || randomUUID(),
        title: String(payload.title || '').trim(),
        zone: String(payload.zone || '').trim() || 'Sri Lanka',
        severity: String(payload.severity || 'medium'),
        message: String(payload.message || '').trim(),
        active: payload.active !== false,
        updatedAt: nowIso(),
      };

      if (!alert.title || !alert.message) {
        return { status: 400, body: { error: 'Alert title and message are required.' } };
      }

      const result = await store.mutate(async (state) => {
        const existingIndex = state.safetyAlerts.findIndex((item) => item.id === alert.id);
        if (existingIndex >= 0) {
          const nextAlerts = [...state.safetyAlerts];
          nextAlerts[existingIndex] = {
            ...nextAlerts[existingIndex],
            ...alert,
          };
          return { ...state, safetyAlerts: nextAlerts, __response: nextAlerts[existingIndex] };
        }

        return {
          ...state,
          safetyAlerts: [alert, ...state.safetyAlerts],
          __response: alert,
        };
      });

      return { status: 200, body: result.__response };
    },

    async getAnalytics() {
      const state = await store.getState();
      const eventSummary = summarizeEventCounts(state.analyticsEvents);
      return {
        status: 200,
        body: {
          eventSummary,
          topPlaceSearches: topPlaceSearches(state.analyticsEvents),
          totalEvents: state.analyticsEvents.length,
          recentEvents: [...state.analyticsEvents].slice(-25).reverse(),
        },
      };
    },

    async getAdminDatabase() {
      const state = await store.getState();
      return {
        status: 200,
        body: sanitizeDatabaseSnapshot(state, config),
      };
    },
  };
}
