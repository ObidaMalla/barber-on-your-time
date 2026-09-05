import 'package:get_it/get_it.dart';

import '../../../cubits/servicesCubit/updateServiceCubit/update_service_cubit.dart';
import '../../../repo/response_services/update_services_repo.dart';
import '../../../routes/service/business_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItUpdateService() {
  if (!getIt.isRegistered<UpdateServiceCubit>()) {
    getIt.registerFactory<UpdateServiceCubit>(
      () => UpdateServiceCubit(getIt<UpdateServicesRepo>()),
    );
  }

  if (!getIt.isRegistered<UpdateServicesRepo>()) {
    getIt.registerLazySingleton<UpdateServicesRepo>(
      () => UpdateServicesRepo(getIt<ServiceBarberShop>()),
    );
  }

  if (!getIt.isRegistered<ServiceBarberShop>()) {
    getIt.registerLazySingleton<ServiceBarberShop>(
      () => ServiceBarberShop(createAndSetupDio()),
    );
  }
}
