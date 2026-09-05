import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityCubit/request_deletion_cubit.dart';
import '../../../repo/response_availability/request_deletion_repo.dart';
import '../../../routes/availability/availability_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItDeletionAvailability() {
  // ===== جديد =====
  if (!getIt.isRegistered<RequestDeletionCubit>()) {
    getIt.registerFactory<RequestDeletionCubit>(
      () => RequestDeletionCubit(getIt<RequestDeletionRepo>()),
    );
  }
  if (!getIt.isRegistered<RequestDeletionRepo>()) {
    getIt.registerLazySingleton<RequestDeletionRepo>(
      () => RequestDeletionRepo(getIt<AvailabilityService>()),
    );
  }

  if (!getIt.isRegistered<AvailabilityService>()) {
    getIt.registerLazySingleton<AvailabilityService>(
      () => AvailabilityService(createAndSetupDio()),
    );
  }
}
