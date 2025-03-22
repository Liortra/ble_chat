import 'package:ble_chat/data/source/ble/ble_repository.dart';
import 'package:ble_chat/presentation/cubits/ble/ble_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

class BlocBinding{
  static void register() {
    locator.registerLazySingleton<BLECubit>(
            () => BLECubit(locator.get<BLERepository>())
    );
  }
}