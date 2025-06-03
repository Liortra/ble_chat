# 🔵 BLE Chat App

BLE Chat App is a simple Flutter application that enables two nearby Android devices to communicate
via **Bluetooth Low Energy (BLE)**.

One device acts as a **peripheral = "server"** and the other as a **central = "client"**. Messages
can be exchanged over a BLE connection using GATT (Generic Attribute Profile).

---

## 🧩 Features

- 📡 Scan for nearby BLE devices
- 🔌 Connect to a BLE server device
- 🟢 Send and receive messages in real-time via BLE
- 🔁 Reconnect automatically if connection drops (even in background)
- 🧠 Clean architecture with `Cubit` for state management
- 🎨 Beautiful and intuitive UI

---

## 📱 Screens

- **Selection Screen** – Choose whether the device will act as `Client` or `Server`
- **Device Scan Screen** – Client scans and connects to server device
- **Chat Screen** – Two-way message communication between client and server

---

## 🛠️ Technologies & Packages

| Purpose              | Package                                                                     |
|----------------------|-----------------------------------------------------------------------------|
| BLE communication    | [`flutter_blue_plus`](https://pub.dev/packages/flutter_blue_plus)           |
| State management     | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)                     |
| Dependency Injection | [`get_it`](https://pub.dev/packages/get_it)                                 |
| UI & Routing         | Flutter + Navigator                                                         |

> ℹ️ BLE advertising is handled natively via `MethodChannel` using Kotlin.

---

## 🔁 Reconnect on Disconnect

- The app monitors connection state using `FlutterBluePlus`.
- If a connection drops (e.g. due to app backgrounding or signal issues), the client will *
  *automatically try to reconnect**.
- Reconnection is handled inside `BLECubit` using `checkConnection()` and listener on
  `BluetoothDeviceState`.

---

## ⚙️ Project Structure

```
lib/
├── main.dart
├── core/                   # Utilities and constants
│   ├── di/
│   └── utils/
├── data/                   # Data source interfaces
│   └── source/
└── presentation/
    ├── cubits/ble/         # BLECubit & BLEState
    ├── screens/
    └── widgets/            # Reusable widgets like device cards

```

---

## 📋 Permissions

Make sure to include these permissions in `AndroidManifest.xml`:

```xml

<uses-permission android:name="android.permission.BLUETOOTH" /><uses-permission
android:name="android.permission.BLUETOOTH_ADMIN" /><uses-permission
android:name="android.permission.BLUETOOTH_CONNECT" /><uses-permission
android:name="android.permission.BLUETOOTH_SCAN" /><uses-permission
android:name="android.permission.ACCESS_FINE_LOCATION" /><uses-permission
android:name="android.permission.FOREGROUND_SERVICE" />
```

For Android 10+ also define foreground service types:

```xml

<service android:name=".MyBleService" android:foregroundServiceType="connectedDevice|dataSync" />
```

---

## ▶️ Getting Started

1. Clone the repo
   ```bash
   git clone https://github.com/your_username/ble_chat_app.git
   cd ble_chat_app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app on 2 physical Android devices
   ```bash
   flutter run
   ```

4. On one device select `Server`, and on the other select `Client`

---

## 💬 Known Limitations

- Only supports **Android** for now
- BLE requires **location permissions**
- Must be tested on **physical devices** (not emulators)
- iOS support is **not implemented**

---

## 📦 Contribution

Pull requests are welcome! Feel free to open issues or submit suggestions 🙌

---

## 🛡️ License

MIT License © 2025

---

## 🧠 Built by

Lior Trachtman
Inspired by hands-on Bluetooth experiments 💙

---