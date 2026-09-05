import 'package:get_it/get_it.dart';

import '../../../cubits/registerCubit/register_cubit.dart';
import '../../../repo/response_register/register_repo.dart';
import '../../../routes/register/register.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItRegister() {
  if (!getIt.isRegistered<RegisterCubit>()) {
    getIt.registerFactory<RegisterCubit>(
      () => RegisterCubit(getIt<RegisterRepository>()),
    );
  }
  if (!getIt.isRegistered<RegisterRepository>()) {
    getIt.registerLazySingleton<RegisterRepository>(
      () => RegisterRepository(getIt<RegisterService>()),
    );
  }
  if (!getIt.isRegistered<RegisterService>()) {
    getIt.registerLazySingleton<RegisterService>(
      () => RegisterService(createAndSetupDio()),
    );
  }
}
