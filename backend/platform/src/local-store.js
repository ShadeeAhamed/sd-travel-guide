import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';

const defaultState = {
  users: [],
  otpChallenges: [],
  places: [],
  safetyAlerts: [],
  analyticsEvents: [],
  settings: {
    appName: 'SD Travel Guide',
    supportEmail: 'support@sdtravel.local',
    adminEmails: ['admin@sdtravel.local'],
  },
};

export function createLocalPlatformStore(filePath) {
  let writeQueue = Promise.resolve();

  function cleanStateForWrite(state) {
    const entries = Object.entries(state).filter(([key]) => !key.startsWith('__'));
    return Object.fromEntries(entries);
  }

  async function ensureFile() {
    try {
      await readFile(filePath, 'utf8');
    } catch (_) {
      await mkdir(dirname(filePath), { recursive: true });
      await writeFile(filePath, JSON.stringify(defaultState, null, 2), 'utf8');
    }
  }

  async function readState() {
    await ensureFile();
    const raw = await readFile(filePath, 'utf8');
    const parsed = JSON.parse(raw);
    return {
      ...defaultState,
      ...parsed,
      users: Array.isArray(parsed.users) ? parsed.users : [],
      otpChallenges: Array.isArray(parsed.otpChallenges)
        ? parsed.otpChallenges
        : [],
      places: Array.isArray(parsed.places) ? parsed.places : [],
      safetyAlerts: Array.isArray(parsed.safetyAlerts) ? parsed.safetyAlerts : [],
      analyticsEvents: Array.isArray(parsed.analyticsEvents)
        ? parsed.analyticsEvents
        : [],
      settings: {
        ...defaultState.settings,
        ...(parsed.settings || {}),
      },
    };
  }

  async function writeState(state) {
    await mkdir(dirname(filePath), { recursive: true });
    await writeFile(
      filePath,
      JSON.stringify(cleanStateForWrite(state), null, 2),
      'utf8',
    );
  }

  return {
    async getState() {
      return readState();
    },
    async mutate(mutator) {
      writeQueue = writeQueue.then(async () => {
        const state = await readState();
        const nextState = (await mutator(state)) || state;
        await writeState(nextState);
        return nextState;
      });
      return writeQueue;
    },
  };
}
