"""
Sensor State Machine & Physics Simulator.
Simulates real-world analog readings, environmental drift, and scenario transitions.
"""

import time
import random
import threading
from typing import Dict, Any, Optional
try:
    from config import SCENARIO_TARGETS, SENSOR_JITTER
except ImportError:
    from simulator.config import SCENARIO_TARGETS, SENSOR_JITTER


class SensorEngine:
    def __init__(self):
        self._lock = threading.RLock()

        # Active state (initialized to normal)
        self.active_scenario = "normal"
        self.is_running = True
        self.jitter_enabled = True
        self.update_interval = 3.0

        # Current sensor telemetry
        self.soil_moisture = 45.0
        self.temperature = 27.5
        self.humidity = 72.0
        self.light = 680.0
        self.rain = False
        self.water_level = 78.0
        self.battery = 92.0
        self.device_status = "online"

        # Interpolation / transition state
        self._transition_steps_remaining = 0
        self._target_values: Dict[str, Any] = dict(SCENARIO_TARGETS["normal"])

        # History log cache for UI
        self.transmission_history = []

    def set_scenario(self, scenario_key: str, smooth: bool = True):
        """
        Switches to a pre-defined scenario.
        If smooth is True, gradually transitions to targets over 5 steps.
        """
        with self._lock:
            if scenario_key not in SCENARIO_TARGETS:
                raise ValueError(f"Unknown scenario: {scenario_key}")

            self.active_scenario = scenario_key
            target = SCENARIO_TARGETS[scenario_key]
            self._target_values = dict(target)

            if not smooth or scenario_key == "device_offline":
                # Instant transition
                self.soil_moisture = float(target["soilMoisture"])
                self.temperature = float(target["temperature"])
                self.humidity = float(target["humidity"])
                self.light = float(target["light"])
                self.rain = bool(target["rain"])
                self.water_level = float(target["waterLevel"])
                self.battery = float(target["battery"])
                self.device_status = str(target["deviceStatus"])
                self._transition_steps_remaining = 0
            else:
                self._transition_steps_remaining = 5
                # Boolean and categorical update immediately
                self.rain = bool(target["rain"])
                self.device_status = str(target["deviceStatus"])

    def recover(self):
        """Helper to smoothly return to optimal normal conditions."""
        self.set_scenario("normal", smooth=True)

    def set_manual_value(self, key: str, value: Any):
        """Manually override a single parameter (e.g. from UI slider)."""
        with self._lock:
            self.active_scenario = "manual"
            self._transition_steps_remaining = 0

            if key == "soilMoisture":
                self.soil_moisture = max(0.0, min(100.0, float(value)))
            elif key == "temperature":
                self.temperature = max(-10.0, min(60.0, float(value)))
            elif key == "humidity":
                self.humidity = max(0.0, min(100.0, float(value)))
            elif key == "light":
                self.light = max(0.0, min(2000.0, float(value)))
            elif key == "rain":
                self.rain = bool(value)
            elif key == "waterLevel":
                self.water_level = max(0.0, min(100.0, float(value)))
            elif key == "battery":
                self.battery = max(0.0, min(100.0, float(value)))
            elif key == "deviceStatus":
                self.device_status = "offline" if str(value).lower() == "offline" else "online"

    def step(self):
        """
        Advances the simulation by one update cycle:
        1. Interpolates towards targets if transitioning.
        2. Applies realistic analog ADC sensor jitter.
        3. Simulates gentle battery consumption.
        """
        with self._lock:
            # 1. Smooth interpolation
            if self._transition_steps_remaining > 0:
                self._transition_steps_remaining -= 1
                if self._transition_steps_remaining == 0:
                    self.soil_moisture = float(self._target_values["soilMoisture"])
                    self.temperature = float(self._target_values["temperature"])
                    self.humidity = float(self._target_values["humidity"])
                    self.light = float(self._target_values["light"])
                    self.water_level = float(self._target_values["waterLevel"])
                    self.battery = float(self._target_values["battery"])
                else:
                    factor = 0.35
                    self.soil_moisture += (self._target_values["soilMoisture"] - self.soil_moisture) * factor
                    self.temperature += (self._target_values["temperature"] - self.temperature) * factor
                    self.humidity += (self._target_values["humidity"] - self.humidity) * factor
                    self.light += (self._target_values["light"] - self.light) * factor
                    self.water_level += (self._target_values["waterLevel"] - self.water_level) * factor
                    self.battery += (self._target_values["battery"] - self.battery) * factor

            # 2. Analog Sensor Jitter (real ADC readings fluctuate slightly)
            if self.jitter_enabled and self.device_status == "online":
                def jitter(val: float, max_delta: float, min_b: float, max_b: float) -> float:
                    delta = random.uniform(-max_delta, max_delta)
                    return max(min_b, min(max_b, val + delta))

                self.soil_moisture = round(jitter(self.soil_moisture, SENSOR_JITTER["soilMoisture"], 0.0, 100.0), 1)
                self.temperature = round(jitter(self.temperature, SENSOR_JITTER["temperature"], 0.0, 55.0), 1)
                self.humidity = round(jitter(self.humidity, SENSOR_JITTER["humidity"], 10.0, 100.0), 1)
                self.light = round(jitter(self.light, SENSOR_JITTER["light"], 0.0, 1500.0), 0)
                self.water_level = round(jitter(self.water_level, SENSOR_JITTER["waterLevel"], 0.0, 100.0), 1)

            # 3. Slow battery consumption (micro-discharge)
            if self.battery > 5.0 and random.random() < 0.1:
                self.battery = round(max(0.0, self.battery - 0.02), 1)

    def get_telemetry_payload(self) -> Dict[str, Any]:
        """
        Generates the Firebase payload.
        Matches Flutter SensorData.fromMap() schema.
        """
        with self._lock:
            # Timestamp as epoch milliseconds (compatible with fromMillisecondsSinceEpoch)
            timestamp_ms = int(time.time() * 1000)

            return {
                "soilMoisture": round(float(self.soil_moisture), 1),
                "temperature": round(float(self.temperature), 1),
                "humidity": round(float(self.humidity), 1),
                "light": round(float(self.light), 0),
                "rain": bool(self.rain),
                "waterLevel": round(float(self.water_level), 1),
                "battery": round(float(self.battery), 1),
                "deviceStatus": str(self.device_status),
                "timestamp": timestamp_ms,
            }

    def get_status(self) -> Dict[str, Any]:
        """Returns comprehensive status for UI monitoring."""
        with self._lock:
            telemetry = self.get_telemetry_payload()
            return {
                "active_scenario": self.active_scenario,
                "is_running": self.is_running,
                "jitter_enabled": self.jitter_enabled,
                "update_interval": self.update_interval,
                "transitioning": self._transition_steps_remaining > 0,
                "telemetry": telemetry,
            }
