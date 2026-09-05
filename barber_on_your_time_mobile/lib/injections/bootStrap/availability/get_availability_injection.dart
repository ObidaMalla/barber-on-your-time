import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityCubit/get_availability_cubit.dart';
import '../../../repo/response_availability/get_availability_repo.dart';
import '../../../routes/availability/availability_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetAvailability() {
  if (!getIt.isRegistered<GetAvailabilityCubit>()) {
    getIt.registerFactory<GetAvailabilityCubit>(
      () => GetAvailabilityCubit(getIt<GetAvailabilityRepo>()),
    );
  }
  if (!getIt.isRegistered<GetAvailabilityRepo>()) {
    getIt.registerLazySingleton<GetAvailabilityRepo>(
      () => GetAvailabilityRepo(getIt<AvailabilityService>()),
    );
  }
  if (!getIt.isRegistered<AvailabilityService>()) {
    getIt.registerLazySingleton<AvailabilityService>(
      () => AvailabilityService(createAndSetupDio()),
    );
  }
}
