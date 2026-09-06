import 'package:get_it/get_it.dart';

import '../../../cubits/loginCubit/login_cubit.dart';
import '../../../repo/response_login/login_repo.dart';
import '../../../routes/auth/auth_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItLogin() {
  if (!getIt.isRegistered<LoginCubit>()) {
    getIt.registerFactory<LoginCubit>(
      () => LoginCubit(getIt<LoginRepository>()),
    );
  }
  if (!getIt.isRegistered<LoginRepository>()) {
    getIt.registerLazySingleton<LoginRepository>(
      () => LoginRepository(getIt<AuthService>()),
    );
  }
  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(createAndSetupDio()),
    );
  }
}
