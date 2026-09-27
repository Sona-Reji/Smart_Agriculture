"""
Lightweight Web Control Server using Python standard library (http.server).
Serves the presenter UI and REST API for real-time control.
Zero external dependencies required.
"""

import json
import os
import time
from http.server import SimpleHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
try:
    from sensor_engine import SensorEngine
    from firebase_client import FirebaseClient
    from config import SERVER_HOST, SERVER_PORT, FIELD_ID
except ImportError:
    from simulator.sensor_engine import SensorEngine
    from simulator.firebase_client import FirebaseClient
    from simulator.config import SERVER_HOST, SERVER_PORT, FIELD_ID


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    daemon_threads = True


def make_handler(engine: SensorEngine, fb_client: FirebaseClient):
    static_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")

    class SimulatorRequestHandler(SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=static_dir, **kwargs)

        def log_message(self, format, *args):
            # Suppress default request access logs to keep terminal output clean
            pass

        def _send_json(self, data: dict, status: int = 200):
            response_bytes = json.dumps(data).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(response_bytes)))
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.end_headers()
            self.wfile.write(response_bytes)

        def do_OPTIONS(self):
            self.send_response(200)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.end_headers()

        def do_GET(self):
            if self.path == "/api/status":
                status = {
                    "field_id": FIELD_ID,
                    "engine": engine.get_status(),
                    "last_status": fb_client.last_status,
                    "last_error": fb_client.last_error,
                    "total_transmissions": fb_client.total_transmissions,
                }
                self._send_json(status)
            else:
                super().do_GET()

        def do_POST(self):
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
            try:
                data = json.loads(body)
            except Exception:
                data = {}

            if self.path == "/api/scenario":
                scenario = data.get("scenario")
                smooth = data.get("smooth", False)
                print(f"\n[{time.strftime('%H:%M:%S')}] [WEB UI COMMAND] Scenario selection: {scenario.upper() if scenario else 'UNKNOWN'}", flush=True)
                if scenario == "recover":
                    engine.recover()
                else:
                    engine.set_scenario(scenario, smooth=smooth)

                # Push immediately to Firebase
                payload = engine.get_telemetry_payload()
                print(f"[{time.strftime('%H:%M:%S')}] [OUTGOING -> FIREBASE] Pushing updated scenario telemetry...", flush=True)
                fb_client.update_current(payload)
                self._send_json({"success": True, "active_scenario": engine.active_scenario})

            elif self.path == "/api/manual":
                key = data.get("key")
                val = data.get("value")
                print(f"\n[{time.strftime('%H:%M:%S')}] [WEB UI COMMAND] Manual sensor override: {key} -> {val}", flush=True)
                if key:
                    engine.set_manual_value(key, val)
                    payload = engine.get_telemetry_payload()
                    print(f"[{time.strftime('%H:%M:%S')}] [OUTGOING -> FIREBASE] Pushing manual override telemetry...", flush=True)
                    fb_client.update_current(payload)
                self._send_json({"success": True})

            elif self.path == "/api/control":
                print(f"\n[{time.strftime('%H:%M:%S')}] [WEB UI COMMAND] Engine settings changed: {data}", flush=True)
                if "is_running" in data:
                    engine.is_running = bool(data["is_running"])
                if "jitter_enabled" in data:
                    engine.jitter_enabled = bool(data["jitter_enabled"])
                if "update_interval" in data:
                    engine.update_interval = float(data["update_interval"])
                self._send_json({"success": True})

            elif self.path == "/api/push":
                print(f"\n[{time.strftime('%H:%M:%S')}] [WEB UI COMMAND] Force Push triggered", flush=True)
                payload = engine.get_telemetry_payload()
                print(f"[{time.strftime('%H:%M:%S')}] [OUTGOING -> FIREBASE] Force pushing current telemetry...", flush=True)
                success = fb_client.update_current(payload)
                self._send_json({"success": success})

            else:
                self.send_error(404, "API Endpoint Not Found")

    return SimulatorRequestHandler
