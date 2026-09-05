import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/get_staff_bookings_cubit.dart';
import '../../../repo/response_booking/get_staff_bookings_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetStaffBookings() {
  if (!getIt.isRegistered<GetStaffBookingsCubit>()) {
    getIt.registerFactory<GetStaffBookingsCubit>(
      () => GetStaffBookingsCubit(getIt<GetStaffBookingsRepository>()),
    );
  }
  if (!getIt.isRegistered<GetStaffBookingsRepository>()) {
    getIt.registerLazySingleton<GetStaffBookingsRepository>(
      () => GetStaffBookingsRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
