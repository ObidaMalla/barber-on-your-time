import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/complete_booking_cubit.dart';
import '../../../repo/response_booking/complete_booking_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItCompleteBooking() {
  if (!getIt.isRegistered<CompleteBookingCubit>()) {
    getIt.registerFactory<CompleteBookingCubit>(
      () => CompleteBookingCubit(getIt<CompleteBookingRepository>()),
    );
  }
  if (!getIt.isRegistered<CompleteBookingRepository>()) {
    getIt.registerLazySingleton<CompleteBookingRepository>(
      () => CompleteBookingRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
