import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BLEState {}

class BLEInitial extends BLEState {}

class BLEScanning extends BLEState {}

class BLEAdvertising extends BLEState {}

class BLEConnected extends BLEState {
  final BluetoothDevice device;

  BLEConnected(this.device);
}

class BLEDevicesUpdated extends BLEState {
  final String deviceName;
  final List<BluetoothDevice> devices;

  BLEDevicesUpdated(this.deviceName, this.devices);
}

class BLEStopped extends BLEState {}

class BLEError extends BLEState {
  final String message;

  BLEError(this.message);
}

class BLEMessageReceived extends BLEState {
  final String lastMessage;
  final List<String> allMessages;

  BLEMessageReceived(this.lastMessage, this.allMessages);
}
