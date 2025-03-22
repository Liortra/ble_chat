import 'package:ble_chat/core/di/bloc_binding.dart';
import 'package:ble_chat/core/di/repository_binding.dart';

void setupDependencies() {
  RepositoryBinding.register();
  BlocBinding.register();
}