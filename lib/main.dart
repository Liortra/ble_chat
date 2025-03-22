import 'package:ble_chat/presentation/cubits/ble/ble_cubit.dart';
import 'package:ble_chat/presentation/cubits/ble/ble_state.dart';
import 'package:ble_chat/presentation/screens/selection/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/di/app_binding.dart';
import 'core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  setupDependencies();
  runApp(
    FutureBuilder(
        future: GetIt.I.allReady(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyApp();
          } else {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
        }),
  );
}

Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.locationWhenInUse,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<BLECubit>(),
      child: BlocListener<BLECubit, BLEState>(
        listenWhen: (previous, current) => current is BLEError,
        listener: (context, state) {
          if (state is BLEError) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BLE Chat',
          theme: AppTheme.lightTheme,
          home: SelectionScreen(),
        ),
      ),
    );
  }
}
