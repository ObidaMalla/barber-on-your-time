import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/create_booking_cubit.dart';
import '../../../repo/response_booking/create_booking_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItCreateBooking() {
  if (!getIt.isRegistered<CreateBookingCubit>()) {
    getIt.registerFactory<CreateBookingCubit>(
      () => CreateBookingCubit(getIt<CreateBookingRepository>()),
    );
  }
  if (!getIt.isRegistered<CreateBookingRepository>()) {
    getIt.registerLazySingleton<CreateBookingRepository>(
      () => CreateBookingRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
