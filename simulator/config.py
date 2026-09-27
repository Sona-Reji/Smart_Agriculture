"""
Configuration settings for the ESP32 Hardware Sensor Simulator.
"""

# Firebase Realtime Database Configuration
FIREBASE_DATABASE_URL = "https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com"
FIELD_ID = "field01"

# Paths in Firebase Realtime Database
PATH_CURRENT = f"fields/{FIELD_ID}/current"
PATH_HISTORY = f"fields/{FIELD_ID}/history"
PATH_ALERTS = f"fields/{FIELD_ID}/alerts"

# Simulation timings (in seconds)
DEFAULT_UPDATE_INTERVAL = 3.0       # Update rate in seconds
HISTORY_LOG_INTERVAL = 15.0         # How often to append to historical readings
MAX_HISTORY_ENTRIES = 50            # Rolling history retention limit

# Local Control Server Configuration
SERVER_HOST = "127.0.0.1"
SERVER_PORT = 5000

# Default Scenario Targets
SCENARIO_TARGETS = {
    "normal": {
        "name": "Normal Healthy Field",
        "description": "Optimal growing conditions across all parameters",
        "soilMoisture": 45.0,
        "temperature": 27.5,
        "humidity": 72.0,
        "light": 680.0,
        "rain": False,
        "waterLevel": 78.0,
        "battery": 92.0,
        "deviceStatus": "online",
    },
    "dry_soil": {
        "name": "Dry Soil Condition",
        "description": "Soil moisture drops below 25%, triggering irrigation alert",
        "soilMoisture": 16.0,
        "temperature": 31.0,
        "humidity": 58.0,
        "light": 840.0,
        "rain": False,
        "waterLevel": 70.0,
        "battery": 90.0,
        "deviceStatus": "online",
    },
    "high_temperature": {
        "name": "Heatwave / High Temperature",
        "description": "Temperature exceeds 35°C, triggering crop heat stress alert",
        "soilMoisture": 32.0,
        "temperature": 38.8,
        "humidity": 44.0,
        "light": 960.0,
        "rain": False,
        "waterLevel": 60.0,
        "battery": 88.0,
        "deviceStatus": "online",
    },
    "low_water": {
        "name": "Low Water Reservoir",
        "description": "Water tank drops below 30%, triggering refill alert",
        "soilMoisture": 42.0,
        "temperature": 28.0,
        "humidity": 68.0,
        "light": 650.0,
        "rain": False,
        "waterLevel": 18.0,
        "battery": 86.0,
        "deviceStatus": "online",
    },
    "rain": {
        "name": "Precipitation / Rain",
        "description": "Rain detected, high humidity, automated irrigation paused",
        "soilMoisture": 82.0,
        "temperature": 21.5,
        "humidity": 94.0,
        "light": 190.0,
        "rain": True,
        "waterLevel": 88.0,
        "battery": 94.0,
        "deviceStatus": "online",
    },
    "device_offline": {
        "name": "ESP32 Gateway Offline",
        "description": "Hardware disconnected, triggering critical offline alert",
        "soilMoisture": 42.0,
        "temperature": 27.5,
        "humidity": 72.0,
        "light": 680.0,
        "rain": False,
        "waterLevel": 78.0,
        "battery": 92.0,
        "deviceStatus": "offline",
    },
}

# Real-world analog sensor jitter tolerances (micro-variations)
SENSOR_JITTER = {
    "soilMoisture": 0.4,
    "temperature": 0.2,
    "humidity": 0.5,
    "light": 8.0,
    "waterLevel": 0.3,
    "battery": 0.05,
}
