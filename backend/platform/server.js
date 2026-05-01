import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { URL, pathToFileURL } from 'node:url';

import { config } from './src/config.js';
import { createFirestoreStore } from './src/firestore-store.js';
import { createLocalPlatformStore } from './src/local-store.js';
import { createPlatformServices } from './src/platform-services.js';
import { seedInitialState } from './src/seed-data.js';

const store =
  config.dataProvider === 'firestore'
    ? createFirestoreStore()
    : createLocalPlatformStore(config.dataFile);

await seedInitialState(store);

const services = createPlatformServices({ store, config });

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
};

function sendJson(res, status, body) {
  const payload = JSON.stringify(body, null, 2);
  res.writeHead(status, {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Key',
    'Content-Type': 'application/json; charset=utf-8',
  });
  res.end(payload);
}

function sendText(res, status, text) {
  res.writeHead(status, {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Key',
    'Content-Type': 'text/plain; charset=utf-8',
  });
  res.end(text);
}

function redirect(res, location) {
  res.writeHead(302, {
    Location: location,
    'Access-Control-Allow-Origin': '*',
  });
  res.end();
}

async function readJsonBody(req) {
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(chunk);
  }
  if (chunks.length === 0) {
    return {};
  }
  return JSON.parse(Buffer.concat(chunks).toString('utf8'));
}

function requireAdmin(req, res) {
  const adminKey = req.headers['x-admin-key'];
  if (adminKey !== config.adminKey) {
    sendJson(res, 401, { error: 'Admin access denied.' });
    return false;
  }
  return true;
}

async function serveDashboardAsset(res, relativePath = 'index.html') {
  const safePath = normalize(relativePath).replace(/^(\.\.(\/|\\|$))+/, '');
  const filePath = join(process.cwd(), 'backend', 'platform', 'dashboard', safePath);
  try {
    const file = await readFile(filePath);
    const type = mimeTypes[extname(filePath)] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': type });
    res.end(file);
  } catch (_) {
    sendText(res, 404, 'Dashboard asset not found.');
  }
}

export function buildServer() {
  return createServer(async (req, res) => {
    if (req.method === 'OPTIONS') {
      res.writeHead(204, {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, X-Admin-Key',
      });
      res.end();
      return;
    }

    const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
    const pathname = url.pathname;

    try {
      if (req.method === 'GET' && pathname === '/health') {
        sendJson(res, 200, {
          ok: true,
          app: 'SD Travel Guide Platform',
          provider: config.dataProvider,
          dashboard: `http://${config.host}:${config.port}/dashboard`,
        });
        return;
      }

      if (req.method === 'GET' && pathname === '/database') {
        redirect(res, '/dashboard#database');
        return;
      }

      if (
        req.method === 'GET' &&
        (pathname === '/dashboard' || pathname === '/admin')
      ) {
        await serveDashboardAsset(res, 'index.html');
        return;
      }

      if (req.method === 'GET' && pathname.startsWith('/dashboard/')) {
        await serveDashboardAsset(res, pathname.replace('/dashboard/', ''));
        return;
      }

      if (req.method === 'POST' && pathname === '/auth/register') {
        const response = await services.register(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'POST' && pathname === '/auth/login/email') {
        const response = await services.loginWithEmail(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'POST' && pathname === '/auth/login/phone') {
        const response = await services.loginWithPhone(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'POST' && pathname === '/auth/verify-otp') {
        const response = await services.verifyOtp(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'GET' && pathname === '/profile/me') {
        const query = Object.fromEntries(url.searchParams.entries());
        const response = await services.getProfile(query);
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'PUT' && pathname === '/profile/preferences') {
        const response = await services.updatePreferences(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'POST' && pathname === '/events/track') {
        const response = await services.trackEvent(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'POST' && pathname === '/assistant/respond') {
        const response = await services.assistantRespond(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (req.method === 'POST' && pathname === '/itinerary/generate') {
        const response = await services.generateItinerary(await readJsonBody(req));
        sendJson(res, response.status, response.body);
        return;
      }

      if (pathname.startsWith('/admin/')) {
        if (!requireAdmin(req, res)) {
          return;
        }

        if (req.method === 'GET' && pathname === '/admin/overview') {
          const response = await services.getAdminOverview();
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'GET' && pathname === '/admin/users') {
          const response = await services.getAdminUsers();
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'GET' && pathname === '/admin/places') {
          const response = await services.getAdminPlaces();
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'POST' && pathname === '/admin/places') {
          const response = await services.saveAdminPlace(await readJsonBody(req));
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'PUT' && pathname.startsWith('/admin/places/')) {
          const placeId = pathname.split('/').pop();
          const response = await services.saveAdminPlace(
            await readJsonBody(req),
            placeId,
          );
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'GET' && pathname === '/admin/safety-alerts') {
          const response = await services.getSafetyAlerts();
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'POST' && pathname === '/admin/safety-alerts') {
          const response = await services.saveSafetyAlert(await readJsonBody(req));
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'GET' && pathname === '/admin/analytics') {
          const response = await services.getAnalytics();
          sendJson(res, response.status, response.body);
          return;
        }

        if (req.method === 'GET' && pathname === '/admin/database') {
          const response = await services.getAdminDatabase();
          sendJson(res, response.status, response.body);
          return;
        }
      }

      sendJson(res, 404, { error: 'Route not found.' });
    } catch (error) {
      sendJson(res, 500, {
        error: 'Unexpected server error.',
        details: error instanceof Error ? error.message : String(error),
      });
    }
  });
}

export function startServer() {
  const server = buildServer();
  server.listen(config.port, config.host, () => {
    console.log(
      `SD Travel Guide platform running at http://${config.host}:${config.port}`,
    );
    console.log(`Admin dashboard: http://${config.host}:${config.port}/dashboard`);
    console.log(`Data provider: ${config.dataProvider}`);
  });
  return server;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  startServer();
}
