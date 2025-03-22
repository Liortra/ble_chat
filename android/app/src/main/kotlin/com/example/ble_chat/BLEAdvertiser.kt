package com.example.ble_chat

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class BLEAdvertiser(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
    private val advertiser: BluetoothLeAdvertiser? = bluetoothAdapter?.bluetoothLeAdvertiser
    private val serviceUuid = ParcelUuid(UUID.fromString("12345678-1234-5678-1234-56789abcdef0"))

    fun startAdvertising(result: MethodChannel.Result) {
        if (advertiser == null) {
            result.error("BLE_ERROR", "Bluetooth LE Advertising not supported", null)
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .build()

        val data = AdvertiseData.Builder()
//            .setIncludeDeviceName(true)
            .addServiceUuid(serviceUuid)
            .build()

        advertiser.startAdvertising(settings, data, object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
                super.onStartSuccess(settingsInEffect)
                Log.d("BLE", "Advertising started successfully.")
                result.success("Advertising started successfully.")
            }

            override fun onStartFailure(errorCode: Int) {
                super.onStartFailure(errorCode)
                Log.e("BLE", "Advertising failed with error: $errorCode")
                result.error("BLE_ERROR", "Advertising failed with error: $errorCode", null)
            }
        })
    }

    fun stopAdvertising(result: MethodChannel.Result) {
        advertiser?.stopAdvertising(object : AdvertiseCallback() {})
        Log.d("BLE", "Advertising stopped.")
        result.success("Advertising stopped.")
    }
}
