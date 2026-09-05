import 'package:get_it/get_it.dart';

import '../../../cubits/businessCubit/delete_staff_cubit.dart';
import '../../../repo/response_business/delete_staff_repo.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItDeleteStaff() {
  if (!getIt.isRegistered<DeleteStaffCubit>()) {
    getIt.registerFactory<DeleteStaffCubit>(
      () => DeleteStaffCubit(getIt<DeleteStaffRepository>()),
    );
  }

  if (!getIt.isRegistered<DeleteStaffRepository>()) {
    getIt.registerLazySingleton<DeleteStaffRepository>(
      () => DeleteStaffRepository(getIt<BusinessService>()),
    );
  }

  if (!getIt.isRegistered<BusinessService>()) {
    getIt.registerLazySingleton<BusinessService>(
      () => BusinessService(createAndSetupDio()),
    );
  }
}
