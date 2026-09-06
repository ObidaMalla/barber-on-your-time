import 'package:get_it/get_it.dart';

import '../../../cubits/logoutCubit/logout_cubit.dart';
import '../../../repo/response_logout/logout_repo.dart';
import '../../../routes/auth/auth_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItLogout() {
  if (!getIt.isRegistered<LogoutCubit>()) {
    getIt.registerFactory<LogoutCubit>(
      () => LogoutCubit(getIt<LogoutRepository>()),
    );
  }
  if (!getIt.isRegistered<LogoutRepository>()) {
    getIt.registerLazySingleton<LogoutRepository>(
      () => LogoutRepository(getIt<AuthService>()),
    );
  }
  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(createAndSetupDio()),
    );
  }
}
