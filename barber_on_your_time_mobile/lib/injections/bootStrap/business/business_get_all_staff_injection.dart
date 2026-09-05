import 'package:get_it/get_it.dart';

import '../../../cubits/businessCubit/business_get_all_staff_cubit.dart';
import '../../../repo/response_business/business_all_staff_repo.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItGetStaff() {
  if (!getIt.isRegistered<GetStaffCubit>()) {
    getIt.registerFactory<GetStaffCubit>(
      () => GetStaffCubit(getIt<BusinessGetAllStaffRepository>()),
    );
  }
  if (!getIt.isRegistered<BusinessGetAllStaffRepository>()) {
    getIt.registerLazySingleton<BusinessGetAllStaffRepository>(
      () => BusinessGetAllStaffRepository(getIt<BusinessService>()),
    );
  }
  if (!getIt.isRegistered<BusinessService>()) {
    getIt.registerLazySingleton<BusinessService>(
      () => BusinessService(createAndSetupDio()),
    );
  }
}
