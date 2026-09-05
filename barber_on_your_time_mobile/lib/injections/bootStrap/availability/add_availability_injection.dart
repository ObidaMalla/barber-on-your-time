import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityCubit/add_availability_cubit.dart';
import '../../../repo/response_availability/add_availability_repo.dart';
import '../../../routes/availability/availability_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItAddAvailability() {
  if (!getIt.isRegistered<AddAvailabilityCubit>()) {
    getIt.registerFactory<AddAvailabilityCubit>(
      () => AddAvailabilityCubit(getIt<AddAvailabilityRepo>()),
    );
  }
  if (!getIt.isRegistered<AddAvailabilityRepo>()) {
    getIt.registerLazySingleton<AddAvailabilityRepo>(
      () => AddAvailabilityRepo(getIt<AvailabilityService>()),
    );
  }
  if (!getIt.isRegistered<AvailabilityService>()) {
    getIt.registerLazySingleton<AvailabilityService>(
      () => AvailabilityService(createAndSetupDio()),
    );
  }
}
