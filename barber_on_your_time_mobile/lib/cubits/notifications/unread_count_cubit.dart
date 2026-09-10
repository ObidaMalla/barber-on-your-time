import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repo/notifications/notifications_repo.dart';

class UnreadCountCubit extends Cubit<int> {
  final NotificationsRepository notificationsRepo;
  UnreadCountCubit(this.notificationsRepo) : super(0);

  Future<void> fetchUnreadCount() async {
    try {
      final response = await notificationsRepo.getUnreadCount();
      emit(response.data?.unreadCount ?? 0);
    } catch (_) {}
  }

  void reset() => emit(0);
}

/*

UnreadCountCubitCubit<int>كلاس يدير حالة مفردة من نوع رقم صحيح (int) تُمثّل العدد الإجمالي للإشعارات غير المقروءة. القيمة الابتدائية له هي 0.notificationsRepoRepositoryالمستودع المسؤول عن جلب بيانات الإشعارات من السيرفر (API).fetchUnreadCount()Methodيجلب عدد الإشعارات غير المقروءة من السيرفر، ويقوم بتحديث الحالة (emit) بالعدد الجديد. في حال حدوث خطأ، يتجاهله ويحافظ على العدد السابق.reset()Methodيُصفر العداد محلياً ويدوياً ليعود إلى 0 (يُستخدم عادةً عند تسجيل الخروج أو عند قراءة جميع الإشعارات دفعة واحدة).

*/
