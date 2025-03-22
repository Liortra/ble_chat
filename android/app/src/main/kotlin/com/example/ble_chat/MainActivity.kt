package com.example.ble_chat

import android.bluetooth.*
import android.content.Context
import android.os.Bundle
import android.os.ParcelUuid
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private lateinit var methodChannel: MethodChannel
    private lateinit var bleAdvertiser: BLEAdvertiser
    private var bluetoothManager: BluetoothManager? = null
    private var bluetoothGattServer: BluetoothGattServer? = null
    private var connectedDevice: BluetoothDevice? = null

    private lateinit var notifyCharacteristic: BluetoothGattCharacteristic

    private val serviceUuid = UUID.fromString("12345678-1234-5678-1234-56789abcdef0")
    private val writeCharacteristicUuid = UUID.fromString("87654321-4321-5678-4321-56789abcdef0")
    private val notifyCharacteristicUuid = UUID.fromString("99998888-7777-6666-5555-444433332222")
    private val configDescriptorUuid = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ble_chat")
        bleAdvertiser = BLEAdvertiser(this)
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdvertising" -> bleAdvertiser.startAdvertising(result)
                "stopAdvertising" -> bleAdvertiser.stopAdvertising(result)
                "startGattServer" -> {
                    startGattServer()
                    result.success("GATT Server started")
                }
                "stopGattServer" -> {
                    bluetoothGattServer?.close()
                    bluetoothGattServer = null
                    result.success("GATT Server stopped")
                }
                "sendToClient" -> {
                    val message = call.argument<String>("message") ?: ""
                    sendMessageToClient(message)
                    result.success("Message sent to client")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startGattServer() {
        bluetoothGattServer = bluetoothManager?.openGattServer(this, gattServerCallback)

        val service = BluetoothGattService(serviceUuid, BluetoothGattService.SERVICE_TYPE_PRIMARY)

        val writeCharacteristic = BluetoothGattCharacteristic(
            writeCharacteristicUuid,
            BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )

        notifyCharacteristic = BluetoothGattCharacteristic(
            notifyCharacteristicUuid,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )

        val configDescriptor = BluetoothGattDescriptor(
            configDescriptorUuid,
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        )
        configDescriptor.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
        notifyCharacteristic.addDescriptor(configDescriptor)

        service.addCharacteristic(writeCharacteristic)
        service.addCharacteristic(notifyCharacteristic)

        bluetoothGattServer?.addService(service)
        Log.i("BLE", "✅ GATT Server started")
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.i("BLE", "🔗 Device connected: ${device.address}")
                connectedDevice = device
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.i("BLE", "🔌 Device disconnected: ${device.address}")
                connectedDevice = null
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice?,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            val message = String(value)
            Log.i("BLE", "📩 Received message: $message")
            device?.let { connectedDevice = it }

            runOnUiThread {
                methodChannel.invokeMethod("onMessageReceived", message)
            }

            if (responseNeeded) {
                bluetoothGattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, null)
            }
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            if (descriptor.uuid == configDescriptorUuid) {
                if (Arrays.equals(value, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)) {
                    Log.i("BLE", "✅ Notifications ENABLED by ${device.address}")
                } else if (Arrays.equals(value, BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE)) {
                    Log.i("BLE", "❌ Notifications DISABLED by ${device.address}")
                }

                descriptor.value = value
                bluetoothGattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value)
                Log.i("BLE", "onDescriptorWriteRequest from ${device.address} for ${descriptor.uuid}")
            } else {
                bluetoothGattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_FAILURE, offset, value)
            }
        }
    }

    private fun sendMessageToClient(message: String) {
        if (::notifyCharacteristic.isInitialized && connectedDevice != null && bluetoothGattServer != null) {
            notifyCharacteristic.value = message.toByteArray()
            bluetoothGattServer?.notifyCharacteristicChanged(connectedDevice, notifyCharacteristic, false)
            Log.i("BLE", "📤 Sent to client: $message")
        } else {
            Log.w("BLE", "❌ Cannot send message: Not connected or characteristic not ready")
        }
    }
}
