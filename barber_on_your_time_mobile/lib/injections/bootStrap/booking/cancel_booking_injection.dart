import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/cancel_booking_cubit.dart';
import '../../../repo/response_booking/cancel_booking_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItCancelBooking() {
  if (!getIt.isRegistered<CancelBookingCubit>()) {
    getIt.registerFactory<CancelBookingCubit>(
      () => CancelBookingCubit(getIt<CancelBookingRepository>()),
    );
  }
  if (!getIt.isRegistered<CancelBookingRepository>()) {
    getIt.registerLazySingleton<CancelBookingRepository>(
      () => CancelBookingRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
