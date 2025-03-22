import 'package:ble_chat/presentation/cubits/ble/ble_cubit.dart';
import 'package:ble_chat/presentation/cubits/ble/ble_state.dart';
import 'package:ble_chat/presentation/screens/chat/chat_screen.dart';
import 'package:ble_chat/presentation/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bleCubit = context.read<BLECubit>();

    return Scaffold(
      appBar: AppBar(title: Text("Available BLE Devices")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => bleCubit.startScanning(),
              icon: Icon(Icons.refresh),
              label: Text("Scan for Devices"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<BLECubit, BLEState>(
                builder: (context, state) {
                  if (state is BLEDevicesUpdated && state.devices.isNotEmpty) {
                    return ListView.builder(
                      itemCount: state.devices.length,
                      itemBuilder: (context, index) {
                        final device = state.devices[index];

                        return DeviceCard(
                          device: device,
                          onTap: () {
                            bleCubit.connectToDevice(device);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  isServer: false,
                                  connectedDevice: device,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return Center(
                    child: Text("No BLEChat servers found."),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
