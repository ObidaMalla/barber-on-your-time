import 'package:barber_on_your_time/cubits/bookingCubit/respond_booking_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../../repo/response_booking/respond_booking_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItRespondBooking() {
  if (!getIt.isRegistered<RespondBookingCubit>()) {
    getIt.registerFactory<RespondBookingCubit>(
      () => RespondBookingCubit(getIt<RespondBookingRepository>()),
    );
  }
  if (!getIt.isRegistered<RespondBookingRepository>()) {
    getIt.registerLazySingleton<RespondBookingRepository>(
      () => RespondBookingRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
