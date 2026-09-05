import 'package:get_it/get_it.dart';

import '../../../cubits/businessCubit/business_cubit.dart';
import '../../../repo/response_business/business_repo.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItBusiness() {
  if (!getIt.isRegistered<CreateBusinessCubit>()) {
    getIt.registerFactory<CreateBusinessCubit>(
      () => CreateBusinessCubit(getIt<BusinessRepository>()),
    );
  }
  ///////////
  if (!getIt.isRegistered<BusinessRepository>()) {
    getIt.registerLazySingleton<BusinessRepository>(
      () => BusinessRepository(getIt<BusinessService>()),
    );
  }
  if (!getIt.isRegistered<BusinessService>()) {
    getIt.registerLazySingleton<BusinessService>(
      () => BusinessService(createAndSetupDio()),
    );
  }
}
