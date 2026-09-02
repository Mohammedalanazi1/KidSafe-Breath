# KIDSAFE BREATH

### Early Detection & Prevention of Choking in Children

KIDSAFE BREATH is a Computer Science graduation project that combines a wearable IoT prototype with a Flutter mobile application to support real-time monitoring of a child's health indicators.

The system is designed to monitor vital readings such as heart rate, blood oxygen level (SpO₂), and body temperature, while providing health alerts through a connected mobile application.

---

## 📱 Project Overview

The project consists of two main parts:

**Wearable Prototype**  
A wearable prototype designed to collect and display health readings.

**Mobile Application**  
A Flutter-based application connected to Firebase for real-time health monitoring, child information management, authentication, and health alerts.

---

## ⌚ Hardware Prototype

The project includes a functional wearable prototype capable of displaying health readings such as SpO₂ and heart rate.

![KIDSAFE BREATH Prototype](images/kidsafe-breath-prototype-active.png)

---

## ✨ Key Features

- Real-time heart rate monitoring
- Blood oxygen (SpO₂) monitoring
- Body temperature monitoring
- Health and suffocation alerts
- Parent registration and login
- Child information management
- Real-time data synchronization using Firebase
- Mobile notifications for important health alerts
- Wearable IoT prototype integration

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Application programming language |
| Firebase Authentication | User authentication |
| Firebase Realtime Database | Real-time health data and alerts |
| ESP32 | IoT / wearable prototype |
| MAX30102 | Heart rate and SpO₂ sensing |
| MLX90614 | Temperature sensing |
| OLED Display | Displaying readings on the prototype |

---

## 🔄 System Workflow

The KIDSAFE BREATH system follows a connected IoT architecture:

**Wearable Device → Sensors → Firebase Realtime Database → Flutter Application → Parent**

The wearable prototype collects health readings, while the mobile application retrieves and displays the data in real time.

---

## 📊 Real-Time Health Monitoring

The application provides real-time monitoring of:

- ❤️ Heart Rate
- 🫁 Blood Oxygen (SpO₂)
- 🌡️ Body Temperature

Health data is retrieved from Firebase Realtime Database and displayed through the Flutter application.

---

## 🚨 Health Alerts

The application includes an alert system designed to display important health notifications.

Alerts are retrieved from Firebase and can generate local mobile notifications for health or suffocation alerts.

---

## 📱 Application Screens

The application includes:

- Welcome Screen
- Login & Registration
- Home Dashboard
- Real-Time Health Monitoring
- Health Alerts
- Child Information
- Settings

<!-- Add application screenshots here -->

---

## 📂 Project Structure

```text
KidSafe-Breath/
│
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   └── screens/
│
├── images/
│   └── Project screenshots and prototype images
│
├── docs/
│   └── Project presentation and poster
│
└── README.md
```

---

## 📄 Project Documentation

Additional project documentation is available in the `docs` folder:

- Graduation Project Presentation
- Graduation Project Poster

---

## 🎓 Graduation Project

**Project Name:** KIDSAFE BREATH  
**Field:** Computer Science  
**Project Type:** IoT & Mobile Application  
**Purpose:** Early Detection and Prevention of Choking in Children

---

## ⚠️ Disclaimer

KIDSAFE BREATH was developed as an academic graduation project and prototype. It is not a certified medical device and should not be used as a substitute for professional medical equipment, diagnosis, or medical advice.
