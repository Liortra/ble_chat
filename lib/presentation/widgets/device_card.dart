import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceCard extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            device.platformName.isNotEmpty ? device.platformName : "Unknown Device",
          ),
          subtitle: Text("ID: ${device.remoteId.str}"),
          trailing: const Icon(Icons.bluetooth_connected),
        ),
      ),
    );
  }
}
