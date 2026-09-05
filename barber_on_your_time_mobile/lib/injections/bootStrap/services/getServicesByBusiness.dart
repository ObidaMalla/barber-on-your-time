import 'package:get_it/get_it.dart';

import '../../../cubits/servicesCubit/get_services_by_business_cubit.dart';
import '../../../repo/response_services/get_services_by_business_repository.dart';
import '../../../routes/service/business_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetServicesByBusiness() {
  if (!getIt.isRegistered<GetServicesByBusinessCubit>()) {
    getIt.registerFactory<GetServicesByBusinessCubit>(
      () =>
          GetServicesByBusinessCubit(getIt<GetServicesByBusinessRepository>()),
    );
  }

  if (!getIt.isRegistered<GetServicesByBusinessRepository>()) {
    getIt.registerLazySingleton<GetServicesByBusinessRepository>(
      () => GetServicesByBusinessRepository(getIt<ServiceBarberShop>()),
    );
  }

  if (!getIt.isRegistered<ServiceBarberShop>()) {
    getIt.registerLazySingleton<ServiceBarberShop>(
      () => ServiceBarberShop(createAndSetupDio()),
    );
  }
}
