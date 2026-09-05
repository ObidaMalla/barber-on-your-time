import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/get_my_bookings_cubit.dart';
import '../../../repo/response_booking/get_my_bookings_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetMyBookings() {
  if (!getIt.isRegistered<GetMyBookingsCubit>()) {
    getIt.registerFactory<GetMyBookingsCubit>(
      () => GetMyBookingsCubit(getIt<GetMyBookingsRepository>()),
    );
  }
  if (!getIt.isRegistered<GetMyBookingsRepository>()) {
    getIt.registerLazySingleton<GetMyBookingsRepository>(
      () => GetMyBookingsRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
