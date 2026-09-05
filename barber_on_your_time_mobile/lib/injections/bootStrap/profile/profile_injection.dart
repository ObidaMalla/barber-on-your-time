import 'package:get_it/get_it.dart';

import '../../../cubits/profileCubit/profile_cubit.dart';
import '../../../cubits/profileCubit/updateDataProfileCubit/update_data_profile_cubit.dart';
import '../../../cubits/profileCubit/updatePasswordProfileCubit/update_password_cubit.dart';
import '../../../repo/response_profile/profile_repo.dart';
import '../../../routes/profile_route/profile.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItProfile() {
  if (!getIt.isRegistered<ProfileCubit>()) {
    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(getIt<ProfileRepository>()),
    );
  }
  ///////////
  if (!getIt.isRegistered<UpdateProfileCubit>()) {
    getIt.registerFactory<UpdateProfileCubit>(
      () => UpdateProfileCubit(getIt<ProfileRepository>()),
    );
  }
  ///////////
  if (!getIt.isRegistered<UpdatePasswordCubit>()) {
    getIt.registerFactory<UpdatePasswordCubit>(
      () => UpdatePasswordCubit(getIt<ProfileRepository>()),
    );
  }
  ///////////
  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(getIt<ProfileService>()),
    );
  }
  if (!getIt.isRegistered<ProfileService>()) {
    getIt.registerLazySingleton<ProfileService>(
      () => ProfileService(createAndSetupDio()),
    );
  }
}
