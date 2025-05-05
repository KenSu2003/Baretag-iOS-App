
# BareTag iOS App  

<img src="https://github.com/KenSu2003/Baretag-iOS-App/blob/main/Baretag%20iOS%20App/Assets.xcassets/AppIcon.appiconset/Screenshot%202024-12-01%20155244.png" width="200" height="200">

**BareTag** is an iOS application designed to work with the BareTag tracking system. It helps users keep track of their valuable items using UWB and BLE technology.  

## 🚀 Features  

- 📍 **Track & Locate**  
  Real-time location tracking of tagged tools within a designated UWB zone and beyond via the Apple Find My network.

- 🚧 **Custom Geo-Fencing**  
  Define virtual boundaries and receive alerts when a tag moves outside the designated area.

- 🔔 **Out-of-Bounds Alerts**  
  Instant pop-up warnings when tools exit the safe zone — ideal for preventing loss or theft on job sites.

- 🗺 **Interactive Map Integration**  
  Visualize tool locations, anchor zones, and movement history on a live map with dynamic grid overlays.

- 🧭 **Detailed Tag Location Info**  
  View exact latitude, longitude, and altitude data for each tag at a glance.

- 👤 **Secure User Accounts**  
  Login, register, and manage user sessions securely through the app.

- ⚙️ **Anchor Management**  
  Set, update, and remove anchor points used to define tracking boundaries and triangulate tag positions.

- 🛠 **User-Friendly Interface**  
  Clean, intuitive UI for seamless navigation across tracking, tagging, and account management.



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

### 📡 Anchor Management  
Manage anchor locations and metadata.

<p float="left">
  <img src="Screenshots/Anchor%20Locator.png" width="200" height="400">
  <img src="Screenshots/Anchor%20Editor.png" width="200" height="400">
</p>

---

### 🚨 Alerts & Boundaries  
Receive alerts and configure boundary zones.

<p float="left">
  <img src="Screenshots/Out%20of%20Bounds%20Alert.png" width="200" height="400">
  <img src="Screenshots/Set%20Alert%20Bound.png" width="200" height="400">
</p>


## 🛠 Installation  

To run the app locally:  

1. **Clone the repository**  
   ```sh
   git clone https://github.com/KenSu2003/Baretag-iOS-App.git
   ```
2. Run on Xcode


Example dataTag.json

```bash

{
    "id": "12345",
    "name": "Sample Tag",
    "latitude": 42.3942,
    "longitude": -72.529
}
```
