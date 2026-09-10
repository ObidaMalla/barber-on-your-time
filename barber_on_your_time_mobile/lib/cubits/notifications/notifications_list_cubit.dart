import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/notifications/notifications_model.dart';
import '../../repo/notifications/notifications_repo.dart';
import 'unread_count_cubit.dart';

//يُمثل الحالة الحالية للشاشة (تخزين عناصر القائمة، مؤشرات التحميل، رقم الصفحة الحالية، وجود المزيد من البيانات، والأخطاء).
class NotificationsListState {
  final List<NotificationItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final String? deleteError; // 👈 جديد

  const NotificationsListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
    this.deleteError,
  });

  // يُستعمل لإنشاء نسخة جديدة من الحالة وتحديث بعض القيم فقط دون تغيير بقية البيانات المتبقية (تطبيق مفهوم Immutable State).
  NotificationsListState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
    String? deleteError,
  }) {
    return NotificationsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      deleteError: deleteError,

      /// 👈 مهم: مش fallback لـ this.deleteError، حتى نقدر نصفرها لـ null بعد ما نعرضها
    );
  }
}

class NotificationsListCubit extends Cubit<NotificationsListState> {
  final NotificationsRepository notificationsRepo;
  final UnreadCountCubit unreadCountCubit; // 👈 جديد
  static const int _limit = 10;

  NotificationsListCubit(this.notificationsRepo, this.unreadCountCubit)
    : super(const NotificationsListState());

  //يجلب الصفحة الأولى عند فتح الشاشة أو عند السحب للتحديث (Refresh)، ويقوم بإعادة تعيين القائمة وتحديد وجود صفحات إضافية.
  Future<void> loadFirstPage() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await notificationsRepo.getNotifications(
        page: 1,
        limit: _limit,
      );
      final items = response.data?.notifications ?? [];
      final totalPages = response.data?.pagination?.totalPages ?? 1;

      emit(
        state.copyWith(
          items: items,
          isLoading: false,
          currentPage: 1,
          hasMore: 1 < totalPages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  ///يجلب الصفحة التالية عند التمرير لأسفل الشاشة ويقوم بدمج العناصر الجديدة [...state.items, ...newItems] مع القديمة.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final response = await notificationsRepo.getNotifications(
        page: nextPage,
        limit: _limit,
      );
      final newItems = response.data?.notifications ?? [];
      final totalPages = response.data?.pagination?.totalPages ?? nextPage;

      emit(
        state.copyWith(
          items: [...state.items, ...newItems],
          isLoadingMore: false,
          currentPage: nextPage,
          hasMore: nextPage < totalPages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  // 👇 جديد
  Future<void> markAsRead(String id) async {
    final target = state.items.firstWhere(
      (n) => n.id == id,
      orElse: () => NotificationItem(),
    );
    if (target.isRead == true) return; // أصلاً مقروء، ما داعي نعمل شي

    // تحديث متفائل فوري بالواجهة
    final updated = state.items.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
    emit(state.copyWith(items: updated));

    try {
      await notificationsRepo.markAsRead(id);
      unreadCountCubit.fetchUnreadCount(); // 👈 يحدّث العداد فوراً بنفس اللحظة
    } catch (e) {
      // فشل السيرفر ⟶ رجّع الحالة القديمة (غير مقروء)
      final reverted = state.items.map((n) {
        if (n.id == id) n.isRead = false;
        return n;
      }).toList();
      emit(state.copyWith(items: reverted, deleteError: e.toString()));
    }
  }

  ///يرسل طلب حذف للسيرفر، ثم يحذف العنصر محلياً من القائمة المخرجة في الشاشة مباشرة بدون إعادة تحميل القائمة بالكامل.
  Future<void> deleteNotification(String id) async {
    // نحتفظ بنسخة الإشعار قبل الحذف، لو احتجنا نرجعها عند الفشل
    final previousItems = state.items;
    final updated = state.items.where((n) => n.id != id).toList();

    // تحديث متفائل (Optimistic) للواجهة فوراً
    emit(state.copyWith(items: updated));

    try {
      await notificationsRepo.deleteNotification(id);
    } catch (e) {
      // 👇 فشل الحذف بالسيرفر — نرجع الإشعار للقائمة ونبلغ المستخدم
      emit(state.copyWith(items: previousItems, deleteError: e.toString()));
    }
  }

  // 👇 جديد — لتصفير رسالة الخطأ بعد ما الشاشة تعرضها (تمنع تكرار الـ SnackBar)
  void clearDeleteError() {
    emit(state.copyWith(deleteError: null));
  }
}
