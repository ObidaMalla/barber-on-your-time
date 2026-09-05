import 'package:get_it/get_it.dart';

import '../../../cubits/servicesCubit/add_service_cubit.dart';
import '../../../repo/response_services/add_services_repo.dart';
import '../../../routes/service/business_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItAddService() {
  if (!getIt.isRegistered<AddServiceCubit>()) {
    getIt.registerFactory<AddServiceCubit>(
      () => AddServiceCubit(getIt<AddServiceRepository>()),
    );
  }

  if (!getIt.isRegistered<AddServiceRepository>()) {
    getIt.registerLazySingleton<AddServiceRepository>(
      () => AddServiceRepository(getIt<ServiceBarberShop>()),
    );
  }

  if (!getIt.isRegistered<ServiceBarberShop>()) {
    getIt.registerLazySingleton<ServiceBarberShop>(
      () => ServiceBarberShop(createAndSetupDio()),
    );
  }
}
