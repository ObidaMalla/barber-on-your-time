import 'package:get_it/get_it.dart';

import '../../../cubits/bookingCubit/request_completion_cubit.dart';
import '../../../repo/response_booking/request_completion_repo.dart';
import '../../../routes/booking/booking_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItRequestCompletion() {
  if (!getIt.isRegistered<RequestCompletionCubit>()) {
    getIt.registerFactory<RequestCompletionCubit>(
      () => RequestCompletionCubit(getIt<RequestCompletionRepository>()),
    );
  }
  if (!getIt.isRegistered<RequestCompletionRepository>()) {
    getIt.registerLazySingleton<RequestCompletionRepository>(
      () => RequestCompletionRepository(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(
      () => BookingService(createAndSetupDio()),
    );
  }
}
