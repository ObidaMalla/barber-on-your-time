import 'package:get_it/get_it.dart';

import '../../../cubits/availabilityOwnerCubit/answer_request_cubit.dart';
import '../../../cubits/availabilityOwnerCubit/owner_pending_requests_cubit.dart';
import '../../../repo/response_availability_owner/owner_requests_repo.dart';
import '../../../routes/availabilityOwner/owner_requests_service.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItOwnerRequests() {
  if (!getIt.isRegistered<OwnerPendingRequestsCubit>()) {
    getIt.registerFactory<OwnerPendingRequestsCubit>(
      () => OwnerPendingRequestsCubit(getIt<OwnerRequestsRepo>()),
    );
  }
  if (!getIt.isRegistered<AnswerRequestCubit>()) {
    getIt.registerFactory<AnswerRequestCubit>(
      () => AnswerRequestCubit(getIt<OwnerRequestsRepo>()),
    );
  }
  if (!getIt.isRegistered<OwnerRequestsRepo>()) {
    getIt.registerLazySingleton<OwnerRequestsRepo>(
      () => OwnerRequestsRepo(getIt<OwnerRequestsService>()),
    );
  }
  if (!getIt.isRegistered<OwnerRequestsService>()) {
    getIt.registerLazySingleton<OwnerRequestsService>(
      () => OwnerRequestsService(createAndSetupDio()),
    );
  }
}
