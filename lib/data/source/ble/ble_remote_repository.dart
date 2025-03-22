import 'dart:async';

import 'package:ble_chat/core/utils/const.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_data_source.dart';

class BLERemoteRepository extends BLEDataSourceRemote {
  BluetoothCharacteristic? _notifyCharacteristic;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothDevice? _lastDevice;

  static const MethodChannel _channel = MethodChannel('ble_chat');
  final StreamController<String> _messageController =
      StreamController.broadcast();

  BLERemoteRepository() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onMessageReceived') {
        final message = call.arguments as String;
        print('📩 Message received from native: $message');
        _messageController.add(message);
      }
    });
  }

  @override
  Stream<String> get messageStream => _messageController.stream;

  BluetoothDevice get lastDevice => _lastDevice!;

  @override
  Future<void> startAdvertising() async {
    await _channel.invokeMethod("startAdvertising");
  }

  @override
  Future<void> stopAdvertising() async {
    await _channel.invokeMethod("stopAdvertising");
  }

  @override
  Future<void> startGattServer() async {
    await _channel.invokeMethod("startGattServer");
  }

  @override
  Future<void> stopGattServer() async {
    await _channel.invokeMethod("stopGattServer");
  }

  @override
  Future<void> startScanning(Function(ScanResult) onDeviceFound) async {
    print("🔍 Starting BLE Scan...");
    final serviceUUID = Guid("12345678-1234-5678-1234-56789abcdef0");
    await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 10), withServices: [serviceUUID]);

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        print("🔍 Found Device: ${result.device.platformName}");
        onDeviceFound(result);
      }
    }, onError: (error) {
      print("❌ Scan error: $error");
    });
  }

  @override
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    _lastDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {

        if (characteristic.uuid.str.toLowerCase() == Constants.writeCharUuid &&
            characteristic.properties.write) {
          print("✅ Found writable characteristic: ${characteristic.uuid}");
          _writeCharacteristic = characteristic;
        }

        else if (
        characteristic.uuid.str.toLowerCase() == Constants.notifyCharUuid &&
        characteristic.properties.notify) {
          print("✅ Found notify characteristic: ${characteristic.uuid}");
          _notifyCharacteristic = characteristic;

          await _notifyCharacteristic!.setNotifyValue(true);
          _notifyCharacteristic!.lastValueStream.listen((value) {
            final message = String.fromCharCodes(value);
            _messageController.add(message);
          });
        }
      }
    }
  }

  @override
  Future<void> sendMessage(BluetoothDevice device, String message) async {
    try {
      if(_writeCharacteristic != null){
        List<int> bytes = Uint8List.fromList(message.codeUnits);
        await _writeCharacteristic!.write(bytes, withoutResponse: false);
        print("📤 Sent message: $message");
        return;
      }
      print("❌ No matching writable characteristic found.");
    } catch (e) {
      print("❌ Failed to send message: $e");
    }
  }

  @override
  void setOnMessageReceived(Function(String) callback) {
    _messageController.stream.listen(callback);
  }

  @override
  Future<void> sendMessageToClient(String message) async {
    await _channel.invokeMethod("sendToClient", {"message": message});
  }

  @override
  void dispose() {
    _messageController.close();
  }

  @override
  Future<void> monitorConnection() async {
    if (_lastDevice == null) {
      throw Exception("No device connected");
    }
    _lastDevice!.connectionState.listen((state) async{
      if (state == BluetoothConnectionState.disconnected) {
        print("❌ Disconnected from device: ${_lastDevice!.platformName}");
        await reconnect(_lastDevice!);
      }
    });
  }

  @override
  Future<void> reconnect(BluetoothDevice device) async{
    try {
      print("🔁 Reconnected to device: ${device.platformName}");
      await connectToDevice(device);
    } catch (e) {
      print("❌ Reconnection failed: $e");
    }
  }
}
