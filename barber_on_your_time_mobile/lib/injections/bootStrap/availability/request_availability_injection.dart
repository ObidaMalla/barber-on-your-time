import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityCubit/get_pending_requests_cubit.dart';
import '../../../cubits/availabilityCubit/request_availability_cubit.dart';
import '../../../repo/response_availability/get_pending_requests_repo.dart';
import '../../../repo/response_availability/request_availability_repo.dart';
import '../../../routes/availability/availability_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItRequestAvailability() {
  if (!getIt.isRegistered<RequestAvailabilityCubit>()) {
    getIt.registerFactory<RequestAvailabilityCubit>(
      () => RequestAvailabilityCubit(getIt<RequestAvailabilityRepo>()),
    );
  }
  if (!getIt.isRegistered<RequestAvailabilityRepo>()) {
    getIt.registerLazySingleton<RequestAvailabilityRepo>(
      () => RequestAvailabilityRepo(getIt<AvailabilityService>()),
    );
  }

  // ===== جديد =====
  if (!getIt.isRegistered<GetPendingRequestsCubit>()) {
    getIt.registerFactory<GetPendingRequestsCubit>(
      () => GetPendingRequestsCubit(getIt<GetPendingRequestsRepo>()),
    );
  }
  if (!getIt.isRegistered<GetPendingRequestsRepo>()) {
    getIt.registerLazySingleton<GetPendingRequestsRepo>(
      () => GetPendingRequestsRepo(getIt<AvailabilityService>()),
    );
  }

  if (!getIt.isRegistered<AvailabilityService>()) {
    getIt.registerLazySingleton<AvailabilityService>(
      () => AvailabilityService(createAndSetupDio()),
    );
  }
}
