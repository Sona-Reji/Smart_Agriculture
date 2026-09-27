"""
Direct REST Client for Firebase Realtime Database.
Uses Python standard library (urllib.request) - requires zero external dependencies.
Mimics the HTTPS REST requests that an ESP32 micro-controller executes.
"""

import json
import urllib.request
import urllib.error
import time
from typing import Dict, Any, Optional
try:
    from config import FIREBASE_DATABASE_URL, PATH_CURRENT, PATH_HISTORY, PATH_ALERTS
except ImportError:
    from simulator.config import FIREBASE_DATABASE_URL, PATH_CURRENT, PATH_HISTORY, PATH_ALERTS


class FirebaseClient:
    def __init__(self, base_url: str = FIREBASE_DATABASE_URL):
        self.base_url = base_url.rstrip("/")
        self.last_status: Optional[int] = None
        self.last_error: Optional[str] = None
        self.last_sync_time: Optional[float] = None
        self.total_transmissions: int = 0

    def _request(self, endpoint: str, data: Optional[Dict[str, Any]] = None, method: str = "GET") -> Optional[Any]:
        url = f"{self.base_url}/{endpoint}.json"
        body = json.dumps(data).encode("utf-8") if data is not None else None
        headers = {"Content-Type": "application/json"}

        if data is not None:
            formatted_json = json.dumps(data)
            print(f"\n[{time.strftime('%H:%M:%S')}] [OUTGOING -> FIREBASE RTDB] {method} /{endpoint}.json", flush=True)
            print(f"  Outgoing Payload: {formatted_json}", flush=True)

        req = urllib.request.Request(url, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=5.0) as resp:
                self.last_status = resp.status
                self.last_error = None
                self.last_sync_time = time.time()
                self.total_transmissions += 1
                if data is not None:
                    print(f"  Transmission Result: HTTP {resp.status} (OK) - Synchronized with cloud", flush=True)
                raw_data = resp.read().decode("utf-8")
                return json.loads(raw_data) if raw_data and raw_data != "null" else None
        except urllib.error.HTTPError as e:
            self.last_status = e.code
            self.last_error = f"HTTP {e.code}: {e.reason}"
            if data is not None:
                print(f"  Transmission Result: FAILED ({self.last_error})", flush=True)
            return None
        except urllib.error.URLError as e:
            self.last_status = 0
            self.last_error = f"Network error: {e.reason}"
            if data is not None:
                print(f"  Transmission Result: FAILED ({self.last_error})", flush=True)
            return None
        except Exception as e:
            self.last_status = -1
            self.last_error = str(e)
            if data is not None:
                print(f"  Transmission Result: FAILED ({self.last_error})", flush=True)
            return None

    def update_current(self, telemetry: Dict[str, Any]) -> bool:
        """
        Sends telemetry to fields/field01/current via HTTP PUT.
        Exact schema read by Flutter SensorData.fromMap().
        """
        res = self._request(PATH_CURRENT, data=telemetry, method="PUT")
        return res is not None

    def append_history(self, telemetry: Dict[str, Any]) -> bool:
        """
        Appends a historical record to fields/field01/history via HTTP POST.
        """
        res = self._request(PATH_HISTORY, data=telemetry, method="POST")
        return res is not None

    def set_alert(self, alert_id: str, alert_data: Dict[str, Any]) -> bool:
        """
        Sets an alert under fields/field01/alerts/{alert_id}.
        """
        res = self._request(f"{PATH_ALERTS}/{alert_id}", data=alert_data, method="PUT")
        return res is not None

    def clear_alerts(self) -> bool:
        """
        Clears or resets alerts under fields/field01/alerts.
        """
        res = self._request(PATH_ALERTS, data={}, method="PUT")
        return res is not None

    def get_current(self) -> Optional[Dict[str, Any]]:
        """
        Reads back current state from fields/field01/current.
        """
        return self._request(PATH_CURRENT, method="GET")
