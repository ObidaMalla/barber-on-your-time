import 'package:get_it/get_it.dart';

import '../../../cubits/staffInviteCubit/staff_invite_cubit.dart';
import '../../../repo/response_business/business_repo.dart';
import '../../../routes/business_routes/business.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItStaffInvite() {
  if (!getIt.isRegistered<StaffInviteCubit>()) {
    getIt.registerFactory<StaffInviteCubit>(
      () => StaffInviteCubit(getIt<BusinessRepository>()),
    );
  }
  // BusinessRepository و BusinessService غالباً مسجلين أصلاً من initGetItCreateBusiness
  // - سجلهم بس لو مش مسجلين

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
