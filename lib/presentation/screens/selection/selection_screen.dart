import 'package:ble_chat/presentation/screens/chat/chat_screen.dart';
import 'package:ble_chat/presentation/screens/devices/devices_screen.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BLE Chat",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choose Mode",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(Icons.bluetooth),
                label: Text("Start as Server"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(isServer: true, connectedDevice: null),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.search),
                label: Text("Start as Client"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DevicesScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
