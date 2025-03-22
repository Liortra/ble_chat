import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_data_source.dart';

class BLERepository {
  final BLEDataSourceRemote remoteRepository;

  BLERepository(this.remoteRepository);

  Future<void> startAdvertising() => remoteRepository.startAdvertising();

  Future<void> stopAdvertising() => remoteRepository.stopAdvertising();

  Future<void> startGattServer() => remoteRepository.startGattServer();

  Future<void> stopGattServer() => remoteRepository.stopGattServer();

  Future<void> sendMessageToClient(String message) =>
      remoteRepository.sendMessageToClient(message);

  void setOnMessageReceived(Function(String) callback) =>
      remoteRepository.setOnMessageReceived(callback);

  Future<void> startScanning(Function(ScanResult) onDeviceFound) =>
      remoteRepository.startScanning(onDeviceFound);

  Future<void> connectToDevice(BluetoothDevice device) =>
      remoteRepository.connectToDevice(device);

  Future<void> sendMessage(BluetoothDevice device, String message) =>
      remoteRepository.sendMessage(device, message);

  Future<void> monitorConnection() =>
      remoteRepository.monitorConnection();

  Future<void> reconnect(BluetoothDevice device) =>
      remoteRepository.reconnect(device);

  Stream<String> get messageStream => remoteRepository.messageStream;

  void dispose() => remoteRepository.dispose();
}
