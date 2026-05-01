import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const envFilePath = resolve(process.cwd(), 'backend/platform/.env');

if (existsSync(envFilePath)) {
  const raw = readFileSync(envFilePath, 'utf8');
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) {
      continue;
    }

    const separatorIndex = trimmed.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }

    const key = trimmed.slice(0, separatorIndex).trim();
    let value = trimmed.slice(separatorIndex + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (!(key in process.env)) {
      process.env[key] = value;
    }
  }
}

export const config = {
  host: process.env.SD_PLATFORM_HOST || '127.0.0.1',
  port: Number(process.env.SD_PLATFORM_PORT || 4100),
  dataProvider: process.env.SD_PLATFORM_DATA_PROVIDER || 'local',
  dataFile: resolve(
    process.cwd(),
    process.env.SD_PLATFORM_DATA_FILE || 'backend/platform/data/dev-db.json',
  ),
  adminKey: process.env.SD_PLATFORM_ADMIN_KEY || 'dev-admin-key',
  aiProxyUrl: process.env.SD_PLATFORM_AI_PROXY_URL || 'http://127.0.0.1:8000/chat',
  translationProxyUrl:
    process.env.SD_PLATFORM_TRANSLATION_PROXY_URL ||
    'http://127.0.0.1:8000/translate',
  emailProvider: process.env.SD_PLATFORM_EMAIL_PROVIDER || 'none',
  resendApiKey: process.env.SD_PLATFORM_RESEND_API_KEY || '',
  emailFrom: process.env.SD_PLATFORM_EMAIL_FROM || '',
  appName: process.env.SD_PLATFORM_APP_NAME || 'SD Travel Guide',
};
