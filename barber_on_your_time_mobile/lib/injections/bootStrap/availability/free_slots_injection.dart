import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityCubit/free_slots_cubit.dart';
import '../../../repo/response_availability/free_slots_repo.dart';
import '../../../routes/Availability/availability_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItFreeSlots() {
  if (!getIt.isRegistered<FreeSlotsCubit>()) {
    getIt.registerFactory<FreeSlotsCubit>(
      () => FreeSlotsCubit(getIt<FreeSlotsRepository>()),
    );
  }

  if (!getIt.isRegistered<FreeSlotsRepository>()) {
    getIt.registerLazySingleton<FreeSlotsRepository>(
      () => FreeSlotsRepository(getIt<AvailabilityService>()),
    );
  }

  if (!getIt.isRegistered<AvailabilityService>()) {
    getIt.registerLazySingleton<AvailabilityService>(
      () => AvailabilityService(createAndSetupDio()),
    );
  }
}
