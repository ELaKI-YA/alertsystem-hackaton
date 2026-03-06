import requests
import random
import time

API_URL = "http://127.0.0.1:8000/sensor-alert"

print("🚍 Mock IoT Sensor System Started")

while True:

    data = {
        "bus_id": random.choice(["BUS1001","BUS1002","BUS1003"]),
        "sensor_id": random.choice([
            "ENGINE_TEMP_001",
            "OIL_PRESSURE_002",
            "BRAKE_PRESSURE_003",
            "TYRE_PRESSURE_004",
            "FUEL_GAS_005"
        ]),
        "value": random.randint(10,120)
    }

    try:
        response = requests.post(API_URL, json=data)
        print("Sent:", data)
        print("Response:", response.json())

    except Exception as e:
        print("Backend error:", e)

    time.sleep(3)