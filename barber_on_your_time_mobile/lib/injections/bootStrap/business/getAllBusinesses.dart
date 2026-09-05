import 'package:get_it/get_it.dart';

import '../../../cubits/businessCubit/get_all_businesses_cubit.dart';
import '../../../repo/response_business/get_all_businesses_repo.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetAllBusinesses() {
  if (!getIt.isRegistered<GetAllBusinessesCubit>()) {
    getIt.registerFactory<GetAllBusinessesCubit>(
      () => GetAllBusinessesCubit(getIt<GetAllBusinessesRepository>()),
    );
  }

  if (!getIt.isRegistered<GetAllBusinessesRepository>()) {
    getIt.registerLazySingleton<GetAllBusinessesRepository>(
      () => GetAllBusinessesRepository(getIt<BusinessService>()),
    );
  }

  if (!getIt.isRegistered<BusinessService>()) {
    getIt.registerLazySingleton<BusinessService>(
      () => BusinessService(createAndSetupDio()),
    );
  }
}
