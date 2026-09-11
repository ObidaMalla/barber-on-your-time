import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/owner_staff_stats_cubit.dart';
import '../../../repo/response_booking/owner_staff_stats_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItOwnerStaffStats() {
  if (!getIt.isRegistered<OwnerStaffStatsCubit>()) {
    getIt.registerFactory<OwnerStaffStatsCubit>(
      () => OwnerStaffStatsCubit(getIt<OwnerStaffStatsRepository>()),
    );
  }

  if (!getIt.isRegistered<OwnerStaffStatsRepository>()) {
    getIt.registerLazySingleton<OwnerStaffStatsRepository>(
      () => OwnerStaffStatsRepository(getIt<BookingService>()),
    );
  }

  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
