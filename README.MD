# 📦 BareTag iOS App  

<img src="https://github.com/KenSu2003/Baretag-iOS-App/blob/main/Baretag%20iOS%20App/Assets.xcassets/AppIcon.appiconset/Screenshot%202024-12-01%20155244.png" width="200" height="200">

**BareTag** is an iOS application designed to work with the BareTag tracking system. It helps users keep track of valuable tools and assets using UWB (Ultra-Wideband) and BLE (Bluetooth Low Energy) technology. BareTag offers real-time positioning, smart alerts, and a user-friendly interface to improve asset security and visibility — especially for construction sites and field teams.

---

## 🚀 Features  

- 📍 **Track & Locate**  
  Real-time location tracking of tagged tools within a UWB zone and beyond via Apple’s Find My network.

- 🚧 **Custom Geo-Fencing**  
  Define boundaries and get alerts when tags move outside the designated area.

- 🔔 **Out-of-Bounds Alerts**  
  Get instant alerts when a tool exits the permitted tracking zone.

- 🗺 **Interactive Map Integration**  
  Visualize anchors, tags, and movement in real-time on a dynamic grid overlaid map.

- 🧭 **Detailed Tag Location Info**  
  Access full GPS metadata — including latitude, longitude, and altitude — per tool.

- 👤 **Secure User Accounts**  
  Register, log in, and manage your session securely.

- ⚙️ **Anchor Management**  
  Add, edit, or delete anchors to define tracking zones with precision.

- 🛠 **User-Friendly Interface**  
  Clean, intuitive navigation across tagging, localization, and settings.

---

## 📱 Screenshots

### 👤 User Access (Authentication & Session Management)  
Login, registration, and logout functionality for user account management.

<p float="left">
  <img src="Screenshots/Login%20Page.png" width="200" height="400">
  <img src="Screenshots/Registration%20Page.png" width="200" height="400">
  <img src="Screenshots/Logout%20Page.png" width="200" height="400">
</p>

---

### 📡 Anchor Management  
Manage anchor locations and metadata.

<p float="left">
  <img src="Screenshots/Anchor%20Locator.png" width="200" height="400">
  <img src="Screenshots/Anchor%20Editor.png" width="200" height="400">
</p>

---

### 🗺️ Tag Tracking  
View tag positions, detailed coordinates, and grid overlays.

<p float="left">
  <img src="Screenshots/Map%20View.png" width="200" height="400">
  <img src="Screenshots/Grid%20Overlay.png" width="200" height="400">
  <img src="Screenshots/Tag%20Location%20Info.png" width="200" height="400">
  <img src="Screenshots/User%20GPS%20Location.png" width="200" height="400">
</p>

---

### 🚨 Alerts & Boundaries  
Receive alerts and configure boundary zones.

<p float="left">
  <img src="Screenshots/Out%20of%20Bounds%20Alert.png" width="200" height="400">
  <img src="Screenshots/Set%20Alert%20Bound.png" width="200" height="400">
</p>

---

## 🛠 Installation  

To run the app locally:  

1. **Clone the repository**  
   ```sh
   git clone https://github.com/KenSu2003/Baretag-iOS-App.git

   ```
2. Open in Xcode
  
  Open the .xcodeproj or .xcworkspace file with Xcode and run on a simulator or connected iOS device.

3. Build and Run
  
  Select a device target and press ▶️ to build and launch the app.


Example dataTag.json

```bash

{
    "id": "12345",
    "name": "Sample Tag",
    "latitude": 42.3942,
    "longitude": -72.529
}
```
