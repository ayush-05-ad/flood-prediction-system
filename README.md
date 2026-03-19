# 🌊 AI-Powered Flood Prediction \& Disaster Early Warning System

> \*\*B.Tech Final Year Project | CSE (IoT) | GEC Vaishali | Batch 2022-2026\*\*

!\[Status](https://img.shields.io/badge/Status-In%20Development-blue)
!\[LSTM](https://img.shields.io/badge/AI-LSTM%20+%20Attention-orange)
!\[ESP32](https://img.shields.io/badge/Hardware-ESP32%20+%20Raspberry%20Pi-green)
!\[Flutter](https://img.shields.io/badge/App-Flutter-blue)
!\[React](https://img.shields.io/badge/Dashboard-React.js-purple)

\---

## 👥 Team

|Name|Role|Responsibilities|
|-|-|-|
|**Ayush Deep**|Team Lead / AI + Edge|System architecture, LSTM model, Raspberry Pi, deployment|
|**Sneha Kumari**|Mobile App Developer|Flutter app, Google Maps, push notifications|
|**Annu Priya**|Web Dashboard Developer|React.js dashboard, Leaflet maps, analytics|
|**Nikhil Kumar**|Hardware + Testing|Sensor assembly, LoRa, solar power, field testing|

**Guide:** Asst. Prof. Aparna  | **HOD:** Manoj Kumar Shah

\---

## 📌 Problem Statement

Bihar is India's most flood-affected state — 76% of North Bihar's population lives under recurring flood threat from Kosi, Gandak, and Ganga rivers. Annual flood losses exceed ₹4,000 crore. Current warning systems provide only 6-12 hours advance warning.

## 💡 Our Solution

An AI-powered flood prediction system that provides **72-hour advance warnings** using:

* IoT sensors along rivers (water level, flow, rainfall, soil moisture)
* LSTM + Attention neural network for prediction
* Edge AI on Raspberry Pi (works without internet)
* Multi-channel alerts (SMS + Push + Siren)
* Flutter mobile app + React web dashboard

\---

## 🏆 Key Results

|Metric|Value|Grade|
|-|-|-|
|24-Hour Prediction RMSE|**8.34 cm**|EXCELLENT|
|48-Hour Prediction RMSE|**20.24 cm**|VERY GOOD|
|72-Hour Prediction RMSE|**24.36 cm**|VERY GOOD|
|Model Size|**1.04 MB**|Raspberry Pi Ready|
|Training Data|**43,800 readings**|5 Years Simulated|
|Sensors Supported|**6 types**|Water, Flow, Rain, Soil, Pressure, Temp|

\---

## 🛠️ Tech Stack

|Category|Technology|
|-|-|
|**Edge AI Gateway**|Raspberry Pi 4 (4GB) + Python|
|**Sensor Nodes**|ESP32 DevKit V1 + LoRa SX1276|
|**AI/ML Model**|LSTM + Attention (TensorFlow/Keras)|
|**Training**|Google Colab (T4 GPU)|
|**Sensors**|JSN-SR04T, YF-S201, Rain Gauge, BMP280, Soil Moisture, GPS|
|**Communication**|LoRa (2-5km) + MQTT + WiFi|
|**Cloud**|Firebase Realtime Database|
|**Mobile App**|Flutter (Dart) - Android + iOS + Web|
|**Web Dashboard**|React.js + Recharts + Leaflet|
|**Alerts**|SMS (SIM800L) + Firebase Push + Physical Siren|
|**Power**|Solar Panel 12V + 18650 Battery|

\---

## 📁 Project Structure

```
flood-prediction-system/
│
├── firmware/                    # ESP32 Arduino Code
│   ├── config.h                 # Pin definitions, WiFi, thresholds
│   └── sensor\_node.ino          # Main firmware (v3.0 - 3 sensors + JSON + alerts)
│
├── ml\_training/                 # AI/ML Model (Google Colab)
│   ├── Flood\_LSTM\_Training.ipynb # Complete training notebook
│   ├── flood\_model.h5           # Trained LSTM model (1.04 MB)
│   ├── flood\_model.keras        # Keras format model
│   ├── data\_scaler.pkl          # MinMaxScaler for normalization
│   └── prediction\_results.png   # Actual vs Predicted graph
│
├── flutter\_app/                 # Mobile App (Flutter)
│   └── main.dart                # Complete app with Day/Night mode
│
├── edge\_ai/                     # Raspberry Pi Gateway (Python)
│   ├── main.py                  # Gateway main loop
│   ├── lstm\_predictor.py        # TFLite inference module
│   ├── risk\_scorer.py           # Village risk assessment
│   ├── alert\_engine.py          # SMS + Push + Siren alerts
│   └── lora\_gateway.py          # LoRa receiver
│
├── web\_dashboard/               # React Dashboard (Coming Soon)
│
├── docs/                        # Documentation
│
└── README.md
```

\---

## 📱 App Features

### Dashboard

* 6 real-time sensor cards with progress bars
* Water level hero card with gradient alerts
* Day/Night mode toggle
* Simulate button for testing

### Alerts

* 4-level alert system: SAFE → WATCH → WARNING → EMERGENCY → EVACUATE
* Color-coded alert history
* Push notifications

### AI Prediction

* 24h, 48h, 72h flood level forecast
* Confidence percentage per prediction
* Trend analysis (Rising/Stable/Falling)
* AI advisory warnings

### SOS Emergency

* One-tap SOS with confirmation dialog
* NDRF helpline integration (9711077372)
* Location sharing with authorities

\---

## 🔌 Circuit Connections

### ESP32 Sensor Node

|Component|ESP32 Pin|
|-|-|
|Ultrasonic TRIG|GPIO 12|
|Ultrasonic ECHO|GPIO 13|
|DHT22 Data|GPIO 4|
|Soil Moisture|GPIO 34 (Analog)|
|BMP280 SDA|GPIO 21 (I2C)|
|BMP280 SCL|GPIO 22 (I2C)|
|GPS TX|GPIO 16 (UART)|
|GPS RX|GPIO 17 (UART)|
|LoRa MOSI|GPIO 23 (SPI)|
|LoRa MISO|GPIO 19 (SPI)|
|LoRa SCK|GPIO 18 (SPI)|
|LoRa CS|GPIO 5|
|Status LED|GPIO 2|

\---

## 📊 AI Model Architecture

```
Input (168 timesteps x 6 features)
    ↓
Bidirectional LSTM (64 units)
    ↓
Layer Normalization + Dropout (0.2)
    ↓
LSTM (32 units) + Attention Mechanism
    ↓
Concatenate \[Last Hidden + Attention Context]
    ↓
Dense (64, ReLU) → Dropout (0.2) → Dense (32, ReLU)
    ↓
Output: \[24h\_prediction, 48h\_prediction, 72h\_prediction]
```

**Training:** 19 epochs on Google Colab T4 GPU | **Loss:** Huber | **Optimizer:** Adam

\---

## 🚀 Progress Tracker

* \[x] Day 1: VS Code + Git + Node.js + GitHub + Accounts setup
* \[x] Day 2: ESP32 firmware v3.0 (3 sensors + JSON + 4-level alerts) on Wokwi
* \[x] Day 3: LSTM model trained (8.34cm RMSE) + exported to .h5
* \[x] Day 4: Flutter app with Day/Night mode, 4 screens, SOS
* \[ ] Day 5: Firebase Realtime Database integration
* \[ ] Day 6: Google Maps + live alerts in app
* \[ ] Day 7-8: React web dashboard
* \[ ] Day 9: Raspberry Pi setup + Edge AI
* \[ ] Day 10: Hardware assembly + real sensor testing
* \[ ] Day 11: Full system integration
* \[ ] Day 12: Demo model (MDF board)
* \[ ] Day 13: Project report + PPT
* \[ ] Day 14: Final demo + viva preparation

\---

## 💰 Budget: \~₹23,240

Complete system with 4 sensor nodes, Raspberry Pi 4, LoRa network, solar power, and waterproof enclosures.

\---

## 🌍 Social Impact

* Aligned with **UN SDG 11** (Sustainable Cities) and **SDG 13** (Climate Action)
* Supports **Bihar State Disaster Management Authority (BSDMA)** objectives
* Designed for **rural deployment** — works without internet (Edge AI)
* **Multi-language** support: Hindi, English, Bhojpuri, Maithili

\---

## 📄 License

Developed for academic purposes at Government Engineering College, Vaishali.

**© 2026 Ayush Deep \& Team | B.Tech CSE (IoT) | GEC Vaishali**

