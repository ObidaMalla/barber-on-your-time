import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityCubit/staff_free_slots_cubit.dart';
import '../../../repo/response_availability/free_slots_repo.dart';
import '../../../routes/Availability/availability_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItStaffFreeSlots() {
  if (!getIt.isRegistered<StaffFreeSlotsCubit>()) {
    getIt.registerFactory<StaffFreeSlotsCubit>(
      () => StaffFreeSlotsCubit(getIt<FreeSlotsRepository>()),
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
