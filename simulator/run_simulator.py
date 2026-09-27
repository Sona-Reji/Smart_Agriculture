#!/usr/bin/env python3
"""
Main Executable: ESP32 Hardware Sensor Simulator
Runs the background telemetry engine and launches the local Web Control Panel.
"""

import os
import sys
import time
import threading

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

try:
    from config import (
        FIREBASE_DATABASE_URL,
        FIELD_ID,
        PATH_CURRENT,
        PATH_HISTORY,
        SERVER_HOST,
        SERVER_PORT,
        DEFAULT_UPDATE_INTERVAL,
        HISTORY_LOG_INTERVAL,
    )
    from firebase_client import FirebaseClient
    from sensor_engine import SensorEngine
    from server import ThreadedHTTPServer, make_handler
except ImportError:
    from simulator.config import (
        FIREBASE_DATABASE_URL,
        FIELD_ID,
        PATH_CURRENT,
        PATH_HISTORY,
        SERVER_HOST,
        SERVER_PORT,
        DEFAULT_UPDATE_INTERVAL,
        HISTORY_LOG_INTERVAL,
    )
    from simulator.firebase_client import FirebaseClient
    from simulator.sensor_engine import SensorEngine
    from simulator.server import ThreadedHTTPServer, make_handler


def background_telemetry_loop(engine: SensorEngine, fb_client: FirebaseClient):
    """
    Main loop mimicking ESP32:
    Steps through sensor physics, jitter, and broadcasts to Firebase RTDB.
    """
    last_history_log = 0.0

    while True:
        try:
            if engine.is_running:
                # 1. Advance simulation state
                engine.step()

                # 2. Get payload
                payload = engine.get_telemetry_payload()

                # 3. Transmit to Firebase RTDB
                success = fb_client.update_current(payload)

                # 4. Periodically append to history
                now = time.time()
                if now - last_history_log >= HISTORY_LOG_INTERVAL and engine.device_status == "online":
                    fb_client.append_history(payload)
                    last_history_log = now

                # Console summary log for presenter
                status_icon = "[OK]" if success else "[FAIL]"
                print(
                    f"  [OUTGOING TELEMETRY SUMMARY] {status_icon} TX #{fb_client.total_transmissions:04d} | "
                    f"Scenario: {engine.active_scenario.upper()} | "
                    f"Moist: {payload['soilMoisture']}% | "
                    f"Temp: {payload['temperature']}C | "
                    f"Hum: {payload['humidity']}% | "
                    f"Water: {payload['waterLevel']}% | "
                    f"Rain: {'YES' if payload['rain'] else 'NO'} | "
                    f"Batt: {payload['battery']}% | "
                    f"Status: {payload['deviceStatus']}",
                    flush=True
                )

            time.sleep(engine.update_interval)

        except Exception as e:
            print(f"\n[Telemetry Error]: {e}")
            time.sleep(2.0)


def print_banner():
    banner = f"""
========================================================================
[+] SMART AGRICULTURE - ESP32 SENSOR HARDWARE SIMULATOR
========================================================================
[*] Cloud Target:      {FIREBASE_DATABASE_URL}
[*] Database Path:     {PATH_CURRENT}
[*] Update Rate:       Every {DEFAULT_UPDATE_INTERVAL}s (analog ADC jitter enabled)
[*] Web Control Panel: http://{SERVER_HOST}:{SERVER_PORT}
                      (Open in browser to switch scenarios & use sliders)
========================================================================
[!] QUICK SCENARIO HOTKEYS (or use the web dashboard):
   [1] Normal Field        [2] Dry Soil (<25%)      [3] High Temp (>35C)
   [4] Low Water (<30%)    [5] Rain Detected (Rain) [6] Device Offline
   [R] Smooth Recover      [P] Pause/Resume Loop    [Q] Quit Simulator
========================================================================
Live Sensor Transmission Log:
"""
    print(banner)


def cli_input_thread(engine: SensorEngine, fb_client: FirebaseClient):
    """Allows presenters to also trigger scenarios directly from the terminal."""
    time.sleep(1.0)
    while True:
        try:
            raw = sys.stdin.readline()
            if not raw:
                # Stdin closed or non-interactive background process
                break
            line = raw.strip().lower()
            if not line:
                continue

            if line == "1":
                engine.set_scenario("normal", smooth=False)
                print(f"\n>> Switched to: NORMAL FIELD")
            elif line == "2":
                engine.set_scenario("dry_soil", smooth=False)
                print(f"\n>> Switched to: DRY SOIL (<25%)")
            elif line == "3":
                engine.set_scenario("high_temperature", smooth=False)
                print(f"\n>> Switched to: HIGH TEMPERATURE (>35°C)")
            elif line == "4":
                engine.set_scenario("low_water", smooth=False)
                print(f"\n>> Switched to: LOW WATER TANK (<30%)")
            elif line == "5":
                engine.set_scenario("rain", smooth=False)
                print(f"\n>> Switched to: RAIN DETECTED")
            elif line == "6":
                engine.set_scenario("device_offline", smooth=False)
                print(f"\n>> Switched to: DEVICE OFFLINE")
            elif line == "r":
                engine.recover()
                print(f"\n>> Recovering smoothly to NORMAL...")
            elif line == "p":
                engine.is_running = not engine.is_running
                print(f"\n>> Telemetry Loop: {'RUNNING' if engine.is_running else 'PAUSED'}")
            elif line == "q":
                print("\nExiting simulator...")
                sys.exit(0)

            # Instant push after manual key
            payload = engine.get_telemetry_payload()
            print(f"[{time.strftime('%H:%M:%S')}] [CLI HOTKEY TRIGGER] Immediate outgoing telemetry push to Firebase...", flush=True)
            fb_client.update_current(payload)

        except Exception:
            break


def main():
    engine = SensorEngine()
    fb_client = FirebaseClient()

    # Initial test connection
    print("Connecting to Firebase Realtime Database...")
    initial_payload = engine.get_telemetry_payload()
    if fb_client.update_current(initial_payload):
        print(f"Successfully connected to Firebase RTDB! Initial state written.")
    else:
        print(f"Warning: Initial Firebase write failed ({fb_client.last_error}). Retrying in background.")

    print_banner()

    # Start telemetry sender thread
    sender_thread = threading.Thread(
        target=background_telemetry_loop, args=(engine, fb_client), daemon=True
    )
    sender_thread.start()

    # Start CLI hotkey listener thread
    cli_thread = threading.Thread(
        target=cli_input_thread, args=(engine, fb_client), daemon=True
    )
    cli_thread.start()

    # Start Web Control HTTP Server
    handler_class = make_handler(engine, fb_client)
    server = ThreadedHTTPServer((SERVER_HOST, SERVER_PORT), handler_class)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n\nShutting down simulator...")
        server.server_close()
        print("Simulator stopped.")


if __name__ == "__main__":
    main()
