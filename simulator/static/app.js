/**
 * ESP32 Hardware Sensor Simulator Client JS
 * Interacts with local simulation server to control telemetry and scenarios.
 */

let activeScenario = 'normal';
let isRunning = true;
let isUserDragging = false;

// DOM Elements
const cloudDot = document.getElementById('cloudDot');
const cloudStatus = document.getElementById('cloudStatus');
const jsonPreview = document.getElementById('jsonPreview');
const txCount = document.getElementById('txCount');
const httpCode = document.getElementById('httpCode');
const lastTxTime = document.getElementById('lastTxTime');
const conditionStatus = document.getElementById('conditionStatus');
const flutterPredictionText = document.getElementById('flutterPredictionText');

// Sliders & Value Labels
const rangeSoilMoisture = document.getElementById('rangeSoilMoisture');
const valSoilMoisture = document.getElementById('valSoilMoisture');
const rangeTemperature = document.getElementById('rangeTemperature');
const valTemperature = document.getElementById('valTemperature');
const rangeHumidity = document.getElementById('rangeHumidity');
const valHumidity = document.getElementById('valHumidity');
const rangeLight = document.getElementById('rangeLight');
const valLight = document.getElementById('valLight');
const rangeWaterLevel = document.getElementById('rangeWaterLevel');
const valWaterLevel = document.getElementById('valWaterLevel');
const rangeBattery = document.getElementById('rangeBattery');
const valBattery = document.getElementById('valBattery');

// Toggles
const chkRain = document.getElementById('chkRain');
const lblRain = document.getElementById('lblRain');
const chkOnline = document.getElementById('chkOnline');
const lblOnline = document.getElementById('lblOnline');
const chkJitter = document.getElementById('chkJitter');
const btnToggleLoop = document.getElementById('btnToggleLoop');
const loopStatusText = document.getElementById('loopStatusText');
const btnForcePush = document.getElementById('btnForcePush');

// Scenario Buttons
const scenarioButtons = document.querySelectorAll('.scenario-btn');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  setupEventListeners();
  fetchStatus();
  setInterval(fetchStatus, 1000);
});

function setupEventListeners() {
  // Scenario Preset Buttons
  scenarioButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const scenario = btn.getAttribute('data-scenario');
      triggerScenario(scenario);
    });
  });

  // Sliders Input Listeners
  const bindSlider = (inputEl, labelEl, key, unit = '', decimals = 1) => {
    inputEl.addEventListener('mousedown', () => { isUserDragging = true; });
    inputEl.addEventListener('touchstart', () => { isUserDragging = true; });

    inputEl.addEventListener('input', (e) => {
      const val = parseFloat(e.target.value);
      labelEl.textContent = `${val.toFixed(decimals)}${unit}`;
    });

    const commitChange = (e) => {
      isUserDragging = false;
      const val = parseFloat(e.target.value);
      sendManualUpdate(key, val);
    };

    inputEl.addEventListener('mouseup', commitChange);
    inputEl.addEventListener('touchend', commitChange);
    inputEl.addEventListener('change', commitChange);
  };

  bindSlider(rangeSoilMoisture, valSoilMoisture, 'soilMoisture', '%', 0);
  bindSlider(rangeTemperature, valTemperature, 'temperature', '°C', 1);
  bindSlider(rangeHumidity, valHumidity, 'humidity', '%', 0);
  bindSlider(rangeLight, valLight, 'light', ' lux', 0);
  bindSlider(rangeWaterLevel, valWaterLevel, 'waterLevel', '%', 0);
  bindSlider(rangeBattery, valBattery, 'battery', '%', 0);

  // Rain Toggle
  chkRain.addEventListener('change', (e) => {
    const isRain = e.target.checked;
    lblRain.textContent = isRain ? 'Rain Active 🌧️' : 'No Rain';
    sendManualUpdate('rain', isRain);
  });

  // Device Status Toggle
  chkOnline.addEventListener('change', (e) => {
    const isOnline = e.target.checked;
    lblOnline.textContent = isOnline ? 'Online' : 'Offline';
    lblOnline.className = `toggle-status ${isOnline ? 'online' : 'offline'}`;
    sendManualUpdate('deviceStatus', isOnline ? 'online' : 'offline');
  });

  // Jitter Toggle
  chkJitter.addEventListener('change', (e) => {
    sendControlUpdate({ jitter_enabled: e.target.checked });
  });

  // Loop Pause/Resume Toggle
  btnToggleLoop.addEventListener('click', () => {
    isRunning = !isRunning;
    sendControlUpdate({ is_running: isRunning });
    updateLoopButtonState(isRunning);
  });

  // Force Push
  btnForcePush.addEventListener('click', () => {
    fetch('/api/push', { method: 'POST' })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          fetchStatus();
        }
      });
  });
}

function updateLoopButtonState(running) {
  if (running) {
    loopStatusText.textContent = '⏸ Pause Loop';
    btnToggleLoop.style.background = 'var(--bg-card)';
  } else {
    loopStatusText.textContent = '▶ Resume Loop';
    btnToggleLoop.style.background = 'var(--accent-warning)';
    btnToggleLoop.style.color = '#000';
  }
}

async function triggerScenario(scenario) {
  try {
    const res = await fetch('/api/scenario', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ scenario })
    });
    const data = await res.json();
    if (data.success) {
      activeScenario = scenario;
      updateActiveScenarioButton(scenario);
      fetchStatus();
    }
  } catch (err) {
    console.error('Failed to trigger scenario:', err);
  }
}

async function sendManualUpdate(key, value) {
  try {
    await fetch('/api/manual', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key, value })
    });
    activeScenario = 'manual';
    updateActiveScenarioButton('manual');
    fetchStatus();
  } catch (err) {
    console.error('Failed to send manual update:', err);
  }
}

async function sendControlUpdate(payload) {
  try {
    await fetch('/api/control', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
  } catch (err) {
    console.error('Failed to send control update:', err);
  }
}

function updateActiveScenarioButton(scenario) {
  scenarioButtons.forEach(btn => {
    const s = btn.getAttribute('data-scenario');
    if (s === scenario) {
      btn.classList.add('active');
    } else {
      btn.classList.remove('active');
    }
  });
}

async function fetchStatus() {
  try {
    const res = await fetch('/api/status');
    const data = await res.json();

    if (!data) return;

    // Update connection status
    cloudDot.className = data.last_error ? 'status-dot error' : 'status-dot pulse';
    cloudStatus.textContent = data.last_error
      ? `Error: ${data.last_error}`
      : `Firebase Connected (${data.field_id})`;

    // Update Telemetry JSON Preview
    const telemetry = data.engine.telemetry;
    jsonPreview.innerHTML = `<code>${JSON.stringify(telemetry, null, 2)}</code>`;

    // Update Stats
    txCount.textContent = data.total_transmissions || 0;
    httpCode.textContent = data.last_status || 200;
    lastTxTime.textContent = new Date().toLocaleTimeString();

    // Update active scenario highlight if not manually dragging
    if (!isUserDragging) {
      updateSlidersFromTelemetry(telemetry);
    }

    // Evaluate Flutter App Behavior Prediction
    evaluateFlutterReaction(telemetry);

  } catch (err) {
    cloudDot.className = 'status-dot error';
    cloudStatus.textContent = 'Simulator Server Disconnected';
  }
}

function updateSlidersFromTelemetry(telemetry) {
  rangeSoilMoisture.value = telemetry.soilMoisture;
  valSoilMoisture.textContent = `${telemetry.soilMoisture.toFixed(0)}%`;

  rangeTemperature.value = telemetry.temperature;
  valTemperature.textContent = `${telemetry.temperature.toFixed(1)}°C`;

  rangeHumidity.value = telemetry.humidity;
  valHumidity.textContent = `${telemetry.humidity.toFixed(0)}%`;

  rangeLight.value = telemetry.light;
  valLight.textContent = `${telemetry.light.toFixed(0)} lux`;

  rangeWaterLevel.value = telemetry.waterLevel;
  valWaterLevel.textContent = `${telemetry.waterLevel.toFixed(0)}%`;

  rangeBattery.value = telemetry.battery;
  valBattery.textContent = `${telemetry.battery.toFixed(0)}%`;

  chkRain.checked = telemetry.rain;
  lblRain.textContent = telemetry.rain ? 'Rain Active 🌧️' : 'No Rain';

  const isOnline = telemetry.deviceStatus.toLowerCase() === 'online';
  chkOnline.checked = isOnline;
  lblOnline.textContent = isOnline ? 'Online' : 'Offline';
  lblOnline.className = `toggle-status ${isOnline ? 'online' : 'offline'}`;
}

function evaluateFlutterReaction(data) {
  const isOffline = data.deviceStatus.toLowerCase() === 'offline';
  let condition = 'GOOD';
  let conditionClass = 'condition-good';
  let message = 'All monitored conditions are optimal and normal.';
  let alerts = [];

  if (isOffline) {
    condition = 'CRITICAL';
    conditionClass = 'condition-critical';
    alerts.push('🚨 Critical Alert: "DEVICE OFFLINE"');
    message = 'ESP32 Gateway offline. Top card shows Critical status and triggers Offline Alert.';
  } else {
    if (data.soilMoisture < 20.0 || data.waterLevel < 15.0) {
      condition = 'CRITICAL';
      conditionClass = 'condition-critical';
    } else if (data.soilMoisture < 25.0 || data.waterLevel < 30.0 || data.temperature > 35.0 || data.battery < 20.0) {
      condition = 'ATTENTION';
      conditionClass = 'condition-attention';
    }

    if (data.soilMoisture < 25.0) {
      alerts.push('⚠️ Warning Alert: "SOIL MOISTURE LOW" (Irrigation recommended)');
    }
    if (data.waterLevel < 30.0) {
      alerts.push('⚠️ Warning Alert: "WATER LEVEL LOW" (Refill tank)');
    }
    if (data.temperature > 35.0) {
      alerts.push('⚠️ Warning Alert: "HIGH TEMPERATURE DETECTED" (Heat stress)');
    }
    if (data.rain) {
      alerts.push('🌧️ Field Insight: "Rain detected. Automated irrigation paused."');
    }
  }

  conditionStatus.textContent = condition;
  conditionStatus.className = `stat-val ${conditionClass}`;

  if (alerts.length > 0) {
    flutterPredictionText.innerHTML = `<strong>Field Condition: ${condition}</strong><br>` + alerts.join('<br>');
  } else {
    flutterPredictionText.innerHTML = `<strong>Field Condition: GOOD</strong><br>All parameters are within healthy thresholds. Health Score: ~95-100/100.`;
  }
}
