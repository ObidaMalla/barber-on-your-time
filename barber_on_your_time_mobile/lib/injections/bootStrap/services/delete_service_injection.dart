import 'package:get_it/get_it.dart';

import '../../../cubits/servicesCubit/deleteServiceCubit.dart';
import '../../../repo/response_services/delete_service_repo.dart';
import '../../../routes/service/business_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItDeleteService() {
  if (!getIt.isRegistered<DeleteServiceCubit>()) {
    getIt.registerFactory<DeleteServiceCubit>(
      () => DeleteServiceCubit(getIt<DeleteServiceRepo>()),
    );
  }
  if (!getIt.isRegistered<DeleteServiceRepo>()) {
    getIt.registerLazySingleton<DeleteServiceRepo>(
      () => DeleteServiceRepo(getIt<ServiceBarberShop>()),
    );
  }
  if (!getIt.isRegistered<ServiceBarberShop>()) {
    getIt.registerLazySingleton<ServiceBarberShop>(
      () => ServiceBarberShop(createAndSetupDio()),
    );
  }
}
