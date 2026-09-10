import 'package:get_it/get_it.dart';

import '../../../cubits/notifications/notifications_list_cubit.dart';
import '../../../cubits/notifications/unread_count_cubit.dart';
import '../../../repo/notifications/notifications_repo.dart';
import '../../../routes/notifications/notifications_routes.dart';
import '../../dio_config.dart';

final getIt = GetIt.instance;

void initGetItNotifications() {
  if (!getIt.isRegistered<NotificationsListCubit>()) {
    getIt.registerFactory<NotificationsListCubit>(
      () => NotificationsListCubit(
        getIt<NotificationsRepository>(),
        getIt<
          UnreadCountCubit
        >(), // 👈 جديد — لازم UnreadCountCubit مسجّل قبلها بنفس الدالة
      ),
    );
  }
  if (!getIt.isRegistered<UnreadCountCubit>()) {
    getIt.registerLazySingleton<UnreadCountCubit>(
      () => UnreadCountCubit(getIt<NotificationsRepository>()),
    );
  }
  if (!getIt.isRegistered<NotificationsRepository>()) {
    getIt.registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepository(getIt<NotificationsService>()),
    );
  }
  if (!getIt.isRegistered<NotificationsService>()) {
    getIt.registerLazySingleton<NotificationsService>(
      () => NotificationsService(createAndSetupDio()),
    );
  }
}
