import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BLEDataSourceRemote {
  Stream<String> get messageStream;
  Future<void> monitorConnection();
  Future<void> reconnect(BluetoothDevice device);
  Future<void> startAdvertising();
  Future<void> stopAdvertising();
  Future<void> startGattServer();
  Future<void> stopGattServer();
  Future<void> startScanning(Function(ScanResult) onDeviceFound);
  Future<void> connectToDevice(BluetoothDevice device);
  Future<void> sendMessage(BluetoothDevice device, String message);
  Future<void> sendMessageToClient(String message);
  void setOnMessageReceived(Function(String) callback);
  void dispose();
}
