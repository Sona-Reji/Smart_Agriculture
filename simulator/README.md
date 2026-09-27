# 🌱 ESP32 Hardware Sensor Simulator (Smart Agriculture)

This simulator externally mimics the physical **ESP32 + Sensor Array** by transmitting realistic analog telemetry directly to **Firebase Realtime Database** over HTTPS REST (`PUT`/`PATCH`), exactly as an ESP32 microcontroller does in production.

---

## 🏗️ Architecture

```
┌─────────────────────────────────┐
│   ESP32 Sensor Simulator        │
│   (Python Standalone Process)   │
│   - Web Dashboard (Port 5000)   │
│   - Analog ADC Jitter & Physics │
└────────────────┬────────────────┘
                 │ HTTPS REST (PUT / PATCH)
                 ▼
┌─────────────────────────────────┐
│   Firebase Realtime Database    │
│   fields/field01/current        │
│   fields/field01/history        │
└────────────────┬────────────────┘
                 │ Realtime WebSocket Stream
                 ▼
┌─────────────────────────────────┐
│   Existing Flutter App          │
│   - Live Dashboard              │
│   - Alerts & Push Notifications │
│   - Health Condition / Score    │
└─────────────────────────────────┘
```

---

## 🚀 Quick Start (Zero External Dependencies)

The simulator uses **Python 3's built-in standard library** (`urllib.request`, `http.server`, `threading`, `json`). No `pip install` is needed.

### 1. Launch the Simulator
From the project root:
```bash
python simulator/run_simulator.py
```

### 2. Open the Presenter Control Panel
Open your browser to:
👉 **[http://localhost:5000](http://localhost:5000)**

---

## 🎛️ Demo Scenarios & Features

| Scenario | Values Sent | Expected Flutter App Reaction |
| :--- | :--- | :--- |
| **Normal Field** | Moisture: 45%, Temp: 27.5°C, Water: 78% | 🟢 Field Condition: **Good** (Score: ~98). All values green. |
| **Dry Soil** | Moisture: **16.0%** (&lt;25%) | 🟠 Condition: **Attention**. Triggers **"SOIL MOISTURE LOW"** warning alert. |
| **High Temperature**| Temperature: **38.8°C** (&gt;35°C) | 🟠 Triggers **"HIGH TEMPERATURE DETECTED"** warning alert. |
| **Low Water Tank** | Water Level: **18.0%** (&lt;30%) | 🟠 Triggers **"WATER LEVEL LOW"** warning alert. |
| **Rain Detected** | Rain: **True**, Moisture: 82% | 🌧️ Rain indicator active. Field insight updates to **"Automated irrigation paused"**. |
| **Device Offline** | DeviceStatus: **"offline"** | 🔴 Condition: **Critical**. Triggers **"DEVICE OFFLINE"** critical alert. |
| **Smooth Recovery** | All parameters return to normal | 🟢 Condition returns to **Good**, alerts resolve. |

### Manual Sliders
Use the web dashboard sliders to adjust any parameter in real-time (`soilMoisture`, `temperature`, `humidity`, `light`, `waterLevel`, `battery`, `rain`, `deviceStatus`).

### Terminal Hotkeys (Headless Mode)
You can also trigger scenarios directly from the command line while `run_simulator.py` is running:
* Press `1`: Normal
* Press `2`: Dry Soil
* Press `3`: High Temperature
* Press `4`: Low Water
* Press `5`: Rain
* Press `6`: Device Offline
* Press `R`: Smooth Recover
* Press `P`: Pause/Resume Loop

---

## 🔌 Hardware Migration Guide (Replacing Simulator with Real ESP32)

When your physical hardware arrives, flash the ESP32 using the Arduino code below. Notice that the payload schema and endpoint are **100% identical**, requiring **zero changes** to Firebase or Flutter:

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* firebaseUrl = "https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com/fields/field01/current.json";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(firebaseUrl);
    http.addHeader("Content-Type", "application/json");

    // Read real sensors
    float soilMoisture = map(analogRead(34), 4095, 1500, 0, 100);
    float temperature = 28.5; // From DHT22 (GPIO 4)
    float humidity = 70.0;    // From DHT22 (GPIO 4)
    float light = analogRead(35); // LDR sensor
    bool rain = digitalRead(18) == LOW; // Rain sensor
    float waterLevel = 75.0;  // Ultrasonic sensor
    float battery = 92.0;

    StaticJsonDocument<256> doc;
    doc["soilMoisture"] = soilMoisture;
    doc["temperature"] = temperature;
    doc["humidity"] = humidity;
    doc["light"] = light;
    doc["rain"] = rain;
    doc["waterLevel"] = waterLevel;
    doc["battery"] = battery;
    doc["deviceStatus"] = "online";
    doc["timestamp"] = (uint64_t)time(nullptr) * 1000;

    String jsonString;
    serializeJson(doc, jsonString);

    int httpResponseCode = http.PUT(jsonString);
    Serial.printf("HTTP PUT: %d\n", httpResponseCode);
    http.end();
  }
  delay(3000); // 3-second cycle
}
```
