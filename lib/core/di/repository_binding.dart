import 'package:ble_chat/data/source/ble/ble_data_source.dart';
import 'package:ble_chat/data/source/ble/ble_remote_repository.dart';
import 'package:ble_chat/data/source/ble/ble_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

class RepositoryBinding {
  static void register() {
    _provideBleRepository();
  }

  static void _provideBleRepository() {
    locator.registerLazySingleton<BLEDataSourceRemote>(
        () => BLERemoteRepository());
    locator.registerLazySingleton<BLERepository>(
        () => BLERepository(locator<BLEDataSourceRemote>()));
  }
}
