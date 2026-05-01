const state = {
  adminKey: localStorage.getItem('sdTravelAdminKey') || 'dev-admin-key',
  activeSection: window.location.hash.replace('#', '') || 'overview',
};

const elements = {
  adminKeyInput: document.getElementById('adminKeyInput'),
  saveAdminKeyBtn: document.getElementById('saveAdminKeyBtn'),
  refreshAllBtn: document.getElementById('refreshAllBtn'),
  navItems: [...document.querySelectorAll('.nav-item')],
  sections: {
    overview: document.getElementById('overviewSection'),
    users: document.getElementById('usersSection'),
    places: document.getElementById('placesSection'),
    safety: document.getElementById('safetySection'),
    analytics: document.getElementById('analyticsSection'),
    database: document.getElementById('databaseSection'),
  },
  overviewStats: document.getElementById('overviewStats'),
  topEventsList: document.getElementById('topEventsList'),
  topSearchesList: document.getElementById('topSearchesList'),
  usersTableBody: document.getElementById('usersTableBody'),
  placesTableBody: document.getElementById('placesTableBody'),
  safetyAlertsList: document.getElementById('safetyAlertsList'),
  analyticsSummaryList: document.getElementById('analyticsSummaryList'),
  recentEventsList: document.getElementById('recentEventsList'),
  databaseMeta: document.getElementById('databaseMeta'),
  databaseDump: document.getElementById('databaseDump'),
  placeForm: document.getElementById('placeForm'),
  alertForm: document.getElementById('alertForm'),
};

elements.adminKeyInput.value = state.adminKey;

elements.saveAdminKeyBtn.addEventListener('click', () => {
  state.adminKey = elements.adminKeyInput.value.trim();
  localStorage.setItem('sdTravelAdminKey', state.adminKey);
  refreshAll();
});

elements.refreshAllBtn.addEventListener('click', refreshAll);

elements.navItems.forEach((button) => {
  button.addEventListener('click', () => {
    setActiveSection(button.dataset.section);
  });
});

elements.placeForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = new FormData(elements.placeForm);
  const payload = {
    name: form.get('name'),
    type: form.get('type'),
    region: form.get('region'),
    bestTime: form.get('bestTime'),
    budgetLevel: form.get('budgetLevel'),
    lat: Number(form.get('lat') || 0),
    lng: Number(form.get('lng') || 0),
    featured: form.get('featured') === 'on',
  };

  const response = await adminFetch('/admin/places', {
    method: 'POST',
    body: JSON.stringify(payload),
  });

  if (response?.error) {
    alert(response.error);
    return;
  }

  elements.placeForm.reset();
  refreshPlaces();
  refreshOverview();
  refreshDatabase();
});

elements.alertForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = new FormData(elements.alertForm);
  const payload = {
    title: form.get('title'),
    zone: form.get('zone'),
    severity: form.get('severity'),
    message: form.get('message'),
    active: true,
  };

  const response = await adminFetch('/admin/safety-alerts', {
    method: 'POST',
    body: JSON.stringify(payload),
  });

  if (response?.error) {
    alert(response.error);
    return;
  }

  elements.alertForm.reset();
  refreshSafety();
  refreshOverview();
  refreshDatabase();
});

function setActiveSection(sectionName) {
  state.activeSection = sectionName;
  window.location.hash = sectionName;
  elements.navItems.forEach((button) => {
    button.classList.toggle('active', button.dataset.section === sectionName);
  });
  Object.entries(elements.sections).forEach(([name, section]) => {
    section.classList.toggle('active', name === sectionName);
  });
}

async function adminFetch(path, options = {}) {
  if (!state.adminKey) {
    alert('Enter and save the admin key first.');
    return null;
  }

  const response = await fetch(path, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'X-Admin-Key': state.adminKey,
      ...(options.headers || {}),
    },
  });

  const data = await response.json();
  if (!response.ok) {
    return { error: data.error || 'Request failed.' };
  }
  return data;
}

function pill(label, color) {
  return `<span class="pill ${color}">${label}</span>`;
}

async function refreshOverview() {
  const data = await adminFetch('/admin/overview');
  if (!data || data.error) {
    return;
  }

  const stats = [
    ['Users', data.totalUsers],
    ['Active', data.activeUsers],
    ['Premium', data.premiumUsers],
    ['Alerts', data.activeAlerts],
    ['Featured places', data.featuredPlaces],
    ['Events today', data.eventsToday],
  ];

  elements.overviewStats.innerHTML = stats
    .map(
      ([label, value]) => `
        <article class="stat-card">
          <div class="label">${label}</div>
          <div class="value">${value}</div>
        </article>
      `,
    )
    .join('');

  elements.topEventsList.innerHTML = data.topEvents
    .map(
      (item) => `
        <article class="list-item">
          <strong>${item.name}</strong>
          <div class="status-text">${item.count} events</div>
        </article>
      `,
    )
    .join('');

  elements.topSearchesList.innerHTML = data.topSearches
    .map(
      (item) => `
        <article class="list-item">
          <strong>${item.placeName}</strong>
          <div class="status-text">${item.count} searches</div>
        </article>
      `,
    )
    .join('');
}

async function refreshUsers() {
  const users = await adminFetch('/admin/users');
  if (!users || users.error) {
    return;
  }

  elements.usersTableBody.innerHTML = users
    .map(
      (user) => `
        <tr>
          <td>
            <strong>${user.fullName}</strong><br />
            <span class="status-text">${user.phone}</span>
          </td>
          <td>${user.email}</td>
          <td>${user.role}</td>
          <td>${user.travelPersonality}</td>
          <td>${user.premium ? pill('Premium', 'gold') : pill('Free', 'green')}</td>
          <td>${user.status}</td>
        </tr>
      `,
    )
    .join('');
}

async function refreshPlaces() {
  const places = await adminFetch('/admin/places');
  if (!places || places.error) {
    return;
  }

  elements.placesTableBody.innerHTML = places
    .map(
      (place) => `
        <tr>
          <td><strong>${place.name}</strong></td>
          <td>${place.type}</td>
          <td>${place.region}</td>
          <td>${place.featured ? pill('Yes', 'gold') : pill('No', 'green')}</td>
          <td>${place.budgetLevel}</td>
        </tr>
      `,
    )
    .join('');
}

async function refreshSafety() {
  const alerts = await adminFetch('/admin/safety-alerts');
  if (!alerts || alerts.error) {
    return;
  }

  elements.safetyAlertsList.innerHTML = alerts
    .map(
      (alert) => `
        <article class="alert-card">
          <strong>${alert.title}</strong>
          <div class="status-text">${alert.zone} · ${alert.updatedAt}</div>
          <p>${alert.message}</p>
          ${pill(
            alert.severity,
            alert.severity === 'high'
              ? 'red'
              : alert.severity === 'medium'
                  ? 'gold'
                  : 'green',
          )}
        </article>
      `,
    )
    .join('');
}

async function refreshAnalytics() {
  const analytics = await adminFetch('/admin/analytics');
  if (!analytics || analytics.error) {
    return;
  }

  elements.analyticsSummaryList.innerHTML = analytics.eventSummary
    .map(
      (item) => `
        <article class="list-item">
          <strong>${item.name}</strong>
          <div class="status-text">${item.count} events</div>
        </article>
      `,
    )
    .join('');

  elements.recentEventsList.innerHTML = analytics.recentEvents
    .map(
      (item) => `
        <article class="list-item">
          <strong>${item.name}</strong>
          <div class="status-text">${item.timestamp}</div>
          <div class="status-text">${JSON.stringify(item.metadata || {})}</div>
        </article>
      `,
    )
    .join('');
}

async function refreshDatabase() {
  const data = await adminFetch('/admin/database');
  if (!data || data.error) {
    return;
  }

  const counts = Object.entries(data.collections || {})
    .map(([name, value]) => {
      const total = Array.isArray(value) ? value.length : 1;
      return `<span class="pill green">${name}: ${total}</span>`;
    })
    .join('');

  elements.databaseMeta.innerHTML = `
    <article class="list-item">
      <strong>Provider</strong>
      <div class="status-text">${data.provider}</div>
    </article>
    <article class="list-item">
      <strong>Data source</strong>
      <div class="status-text">${data.localFile}</div>
    </article>
    <article class="list-item">
      <strong>Collections</strong>
      <div class="pill-row">${counts}</div>
    </article>
  `;

  elements.databaseDump.textContent = JSON.stringify(data.collections, null, 2);
}

async function refreshAll() {
  await Promise.all([
    refreshOverview(),
    refreshUsers(),
    refreshPlaces(),
    refreshSafety(),
    refreshAnalytics(),
    refreshDatabase(),
  ]);
}

setActiveSection(state.activeSection);
refreshAll();
