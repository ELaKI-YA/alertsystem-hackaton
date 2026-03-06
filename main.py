from fastapi import FastAPI
from pymongo import MongoClient
from datetime import datetime
from dotenv import load_dotenv
import os
import random

# RAG IMPORT
from rag.rag_pipeline import ask_rag

# -----------------------------
# Load ENV
# -----------------------------

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

# -----------------------------
# MongoDB Connection
# -----------------------------

client = MongoClient(MONGO_URI)
db = client[DB_NAME]

knowledge_base = db["data"]
sensor_alerts = db["sensor_alerts"]
incident_logs = db["incident_logs"]

app = FastAPI(title="AI Smart Transport Safety System")

# -----------------------------
# Get Sensor Rule
# -----------------------------

def get_sensor_rule(sensor_id):

    rule_doc = knowledge_base.find_one(
        {"collection_name": "bus_sensor_rules"}
    )

    if not rule_doc:
        return None

    sensors = rule_doc["data"]["sensors"]

    for sensor in sensors:
        if sensor["sensor_id"] == sensor_id:
            return sensor

    return None

# -----------------------------
# Classify Sensor Value
# -----------------------------

def classify_sensor_value(sensor_rule, value):

    thresholds = sensor_rule["thresholds"]

    for level, rule in thresholds.items():

        if isinstance(rule, dict):

            min_val = rule.get("min", float("-inf"))
            max_val = rule.get("max", float("inf"))

            if min_val <= value <= max_val:
                return level

        else:
            if value == rule:
                return level

    return "normal"

# -----------------------------
# Generate Live GPS Location
# -----------------------------

def generate_live_location():

    lat = round(random.uniform(11.0000, 11.0800),6)
    lon = round(random.uniform(76.9600, 77.0400),6)

    return {
        "latitude": lat,
        "longitude": lon,
        "google_maps": f"https://maps.google.com/?q={lat},{lon}"
    }

# -----------------------------
# AI Dispatch Decision
# -----------------------------

def get_dispatch_services(alert_level):

    if alert_level == "RED":

        return [
            "police",
            "ambulance",
            "fire_station",
            "mechanical_team"
        ]

    elif alert_level == "AMBER":

        return ["control_center"]

    return []

# -----------------------------
# SENSOR ALERT API
# -----------------------------

@app.post("/sensor-alert")
def sensor_alert(data: dict):

    sensor_id = data.get("sensor_id")
    value = data.get("value")
    bus_id = data.get("bus_id")

    rule = get_sensor_rule(sensor_id)

    if not rule:
        return {"error": "sensor rule not found"}

    level = classify_sensor_value(rule, value)

    alert_level = rule["alert_mapping"][level]

    actions = rule["recommended_action"]

    location = generate_live_location()

    dispatch_services = get_dispatch_services(alert_level)

    alert_record = {
        "bus_id": bus_id,
        "sensor_id": sensor_id,
        "sensor_name": rule["sensor_name"],
        "value": value,
        "alert_level": alert_level,
        "recommended_action": actions,
        "dispatch_services": dispatch_services,
        "location": location,
        "timestamp": datetime.utcnow()
    }

    sensor_alerts.insert_one(alert_record)
    incident_logs.insert_one(alert_record)

    return {
        "alert_level": alert_level,
        "actions": actions,
        "dispatch_services": dispatch_services,
        "live_location": location
    }

# -----------------------------
# SOS ALERT API
# -----------------------------

@app.post("/sos-alert")
def sos_alert(data: dict):

    location = generate_live_location()

    alert = {
        "bus_id": data.get("bus_id"),
        "category": data.get("alert_category"),
        "alert_level": "RED",
        "dispatch_services": [
            "police",
            "ambulance"
        ],
        "location": location,
        "timestamp": datetime.utcnow()
    }

    incident_logs.insert_one(alert)

    return {
        "status": "SOS received",
        "dispatch_services": alert["dispatch_services"],
        "location": location
    }

# -----------------------------
# AUTOMATIC SENSOR SIMULATION
# -----------------------------

@app.get("/simulate-sensors")
def simulate_sensors():

    sensors = [

        {"sensor_id":"ENGINE_TEMP_001","value":random.randint(70,115)},
        {"sensor_id":"OIL_PRESSURE_002","value":random.randint(5,60)},
        {"sensor_id":"BRAKE_PRESSURE_003","value":random.randint(40,120)},
        {"sensor_id":"TYRE_PRESSURE_004","value":random.randint(20,40)},
        {"sensor_id":"FUEL_GAS_005","value":random.randint(5,80)},
        {"sensor_id":"CRASH_TILT_006","value":random.randint(0,30)},
        {"sensor_id":"PASSENGER_LOAD_007","value":random.randint(20,100)},
        {"sensor_id":"SPEED_MONITOR_009","value":random.randint(40,100)}

    ]

    return sensors

# -----------------------------
# CONTROL CENTER ALERT DASHBOARD
# -----------------------------

@app.get("/alerts")
def get_alerts():

    alerts = list(
        incident_logs.find({}, {"_id":0})
        .sort("timestamp",-1)
        .limit(20)
    )

    return alerts

# -----------------------------
# RAG AI QUERY API
# -----------------------------

@app.get("/ai-query")
def ai_query(q: str):

    answer = ask_rag(q)

    return {"answer": answer}
@app.get("/ai-explain-alert")
def explain_alert(alert: str):
    return {"explanation": ask_rag(alert)}