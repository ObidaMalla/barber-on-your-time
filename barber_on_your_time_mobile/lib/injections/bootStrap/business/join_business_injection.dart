import 'package:get_it/get_it.dart';

import '../../../cubits/joinBusinessCubit/join_business_cubit.dart';
import '../../../repo/response_business/business_repo.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItJoinBusiness() {
  if (!getIt.isRegistered<JoinBusinessCubit>()) {
    getIt.registerFactory<JoinBusinessCubit>(
      () => JoinBusinessCubit(getIt<BusinessRepository>()),
    );
  }
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
