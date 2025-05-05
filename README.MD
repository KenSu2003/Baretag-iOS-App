
# BareTag iOS App  

<img src="https://github.com/KenSu2003/Baretag-iOS-App/blob/main/Baretag%20iOS%20App/Assets.xcassets/AppIcon.appiconset/Screenshot%202024-12-01%20155244.png" width="200" height="200">

**BareTag** is an iOS application designed to work with the BareTag tracking system. It helps users keep track of their valuable items using Bluetooth technology.  

## 🚀 Features  

- 📍 **Track & Locate** – Find your BareTag-equipped items easily.  
- 🔔 **Alerts & Notifications** – Get alerts when you leave your item behind.  
- 🗺 **Map Integration** – See the last known location of your BareTag.  
- 🔋 **Battery & Status Monitoring** – Check the battery level of your BareTag.  
- 🛠 **User-Friendly Interface** – Simple and intuitive design for easy use.  

## 📱 Screenshots

### 🔐 Login Page
Displays the login interface where users can securely access the BareTag system.

![Login Page](Screenshots/Login%20Page.png)

---

### 🆕 Registration Page
Allows new users to create an account with a username and password.

![Registration Page](Screenshots/Registration%20Page.png)

---

### 📍 Anchor Locator
Fetch and register anchor coordinates via GPS and send them to the server.

![Anchor Locator](Screenshots/Anchor%20Locator.png)

---

### 🛠️ Anchor Editor
Edit existing anchor names and coordinates or delete anchors from the map.

![Anchor Editor](Screenshots/Anchor%20Editor.png)

---

### 🗺️ Map View with Tools
Visual display of tools (tags) overlaid on a live map. Each tool is color-coded.

![Map View](Screenshots/Map%20View.png)

---

### 🧭 Grid Overlay for Positioning
Toggleable grid overlay for precise tag positioning within defined zones.

![Grid Overlay](Screenshots/Grid%20Overlay.png)

---

### 🚫 Out-of-Bounds Alert
Alert dialog notifying the user when a tag exits the designated tracking area.

![Out of Bounds Alert](Screenshots/Out%20of%20Bounds%20Alert.png)

---

### ⚙️ Set Alert Boundaries
Interactive interface to define and adjust the boundary area for tag movement alerts.

![Set Alert Bound](Screenshots/Set%20Alert%20Bound.png)

---

### 👤 Logout Page
Simple UI for logging out of the user's account.

![Logout Page](Screenshots/Logout%20Page.png)


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
