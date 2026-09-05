import 'package:get_it/get_it.dart';

import '../../../cubits/businessCubit/get_staff_by_business_id_cubit.dart';
import '../../../repo/response_business/get_staff_by_business_id_repository.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetStaffByBusinessId() {
  if (!getIt.isRegistered<GetStaffByBusinessIdCubit>()) {
    getIt.registerFactory<GetStaffByBusinessIdCubit>(
      () => GetStaffByBusinessIdCubit(getIt<GetStaffByBusinessIdRepository>()),
    );
  }

  if (!getIt.isRegistered<GetStaffByBusinessIdRepository>()) {
    getIt.registerLazySingleton<GetStaffByBusinessIdRepository>(
      () => GetStaffByBusinessIdRepository(getIt<BusinessService>()),
    );
  }

  if (!getIt.isRegistered<BusinessService>()) {
    getIt.registerLazySingleton<BusinessService>(
      () => BusinessService(createAndSetupDio()),
    );
  }
}
