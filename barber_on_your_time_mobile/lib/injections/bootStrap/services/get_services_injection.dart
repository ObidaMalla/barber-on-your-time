import 'package:get_it/get_it.dart';

import '../../../cubits/servicesCubit/get_services_cubit.dart';
import '../../../repo/response_services/get_services_repo.dart';
import '../../../routes/service/business_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetServices() {
  if (!getIt.isRegistered<GetServicesCubit>()) {
    getIt.registerFactory<GetServicesCubit>(
      () => GetServicesCubit(getIt<GetServicesRepository>()),
    );
  }

  if (!getIt.isRegistered<GetServicesRepository>()) {
    getIt.registerLazySingleton<GetServicesRepository>(
      () => GetServicesRepository(getIt<ServiceBarberShop>()),
    );
  }

  if (!getIt.isRegistered<ServiceBarberShop>()) {
    getIt.registerLazySingleton<ServiceBarberShop>(
      () => ServiceBarberShop(createAndSetupDio()),
    );
  }
}
