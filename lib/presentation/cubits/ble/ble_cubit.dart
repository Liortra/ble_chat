import 'dart:async';

import 'package:ble_chat/data/source/ble/ble_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_state.dart';

class BLECubit extends Cubit<BLEState> {
  final BLERepository bleRepository;
  bool isServer = false;
  List<String> messages = [];

  BLECubit(this.bleRepository) : super(BLEInitial()) {
    bleRepository.setOnMessageReceived(_handleMessageReceived);
  }

  void _handleMessageReceived(String message) {
    messages.add(message);
    emit(BLEMessageReceived(message, List.from(messages)));
  }

  void startGattServer() => bleRepository.startGattServer();

  void stopGattServer() => bleRepository.stopGattServer();

  void startAdvertising() {
    isServer = true;
    print("📡 Advertising..");
    bleRepository.startAdvertising();
    emit(BLEAdvertising());
  }

  void stopAdvertising() {
    isServer = false;
    print("🛑 Stopping BLE Advertising...");
    bleRepository.stopAdvertising();
    emit(BLEStopped());
  }

  void startScanning() {
    isServer = false;
    emit(BLEScanning());

    bleRepository.startScanning((scanResult) {
      print("🔍 Repository Found Device: ${scanResult.device.platformName}");
      print("🔍 Device ID: ${scanResult.device.toString()}");
      print(
          "✅ Found Server: ${scanResult.device.platformName} - ID: ${scanResult.device.remoteId}");
      emit(BLEDevicesUpdated(
          scanResult.device.platformName, [scanResult.device]));
    });
  }

  void connectToDevice(BluetoothDevice device){
    print("🔗 Connecting to ${device.platformName}...");

    bleRepository.connectToDevice(device).then((_) async{
      emit(BLEConnected(device));
      await bleRepository.monitorConnection();
    }).catchError((error) {
      print("❌ Connection failed: $error");
      emit(BLEError(error.toString()));
    });
  }

  void sendMessage(BluetoothDevice? device, String message) async {
    try {
      if (isServer) {
        bleRepository.sendMessageToClient(message);
        messages.add("You (server): $message");
        emit(BLEMessageReceived(message, List.from(messages)));
      } else {
        await bleRepository.sendMessage(device!, message);
        messages.add("You: $message");
        emit(BLEMessageReceived(message, List.from(messages)));
      }
    } catch (e) {
      print("❌ Failed to send message: $e");
      emit(BLEError("Failed to send message: $e"));
    }
  }

  Future<void> checkConnection() async{
    if (isServer) return;
    try{
      await bleRepository.monitorConnection();
    }catch (e){
      print("❌ Failed to monitor connection: $e");
      emit(BLEError("Failed to checkConnection: $e"));
    }
  }

  void clearMessages() {
    messages.clear();
    emit(BLEMessageReceived("", List.from(messages)));
  }

  void dispose() {
    stopAdvertising();
    stopGattServer();
    bleRepository.dispose();
    super.close();
  }
}
