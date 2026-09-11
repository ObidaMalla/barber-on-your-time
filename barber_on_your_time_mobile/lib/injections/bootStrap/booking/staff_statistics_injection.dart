import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/staff_statistics_cubit.dart';
import '../../../repo/response_booking/staff_statistics_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItStaffStatistics() {
  if (!getIt.isRegistered<StaffStatisticsCubit>()) {
    getIt.registerFactory<StaffStatisticsCubit>(
      () => StaffStatisticsCubit(getIt<StaffStatisticsRepository>()),
    );
  }

  if (!getIt.isRegistered<StaffStatisticsRepository>()) {
    getIt.registerLazySingleton<StaffStatisticsRepository>(
      () => StaffStatisticsRepository(getIt<BookingService>()),
    );
  }

  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
