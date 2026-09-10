import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/notifications/notifications_list_cubit.dart';
import '../../injections/bootStrap/notifications/notifications_injection.dart';
import '../../models/notifications/notifications_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final NotificationsListCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<NotificationsListCubit>();
    _cubit.loadFirstPage();
    _scrollController.addListener(_onScroll);

    // أنيميشن لدوران الإضاءة (مسار الـ LED)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _cubit.loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          // 👈 سهم الرجوع بلون أصفر
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.accentColor,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'الإشعارات',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocConsumer<NotificationsListCubit, NotificationsListState>(
          bloc: _cubit,
          listener: (context, state) {
            if (state.deleteError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تعذر حذف الإشعار: ${state.deleteError}'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
              _cubit.clearDeleteError();
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.accentColor),
              );
            }

            if (state.error != null && state.items.isEmpty) {
              return Center(
                child: Text(
                  state.error!,
                  style: TextStyle(color: AppColors.errorColor, fontSize: 15),
                ),
              );
            }

            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.items.length + 1,
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return _buildLoadMoreArea(state);
                }
                return _buildNotificationTile(state.items[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreArea(NotificationsListState state) {
    if (!state.hasMore) return const SizedBox.shrink();

    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: OutlinedButton(
          onPressed: () => _cubit.loadMore(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.accentColor, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'عرض المزيد',
            style: TextStyle(
              color: AppColors.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    final isRead = item.isRead ?? false;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isRead
                    ? AppColors.accentColor.withValues(alpha: 0.05)
                    : AppColors.accentColor.withValues(alpha: 0.25),
                blurRadius: isRead ? 8 : 12,
                spreadRadius: isRead ? 0 : 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(1.2), // سُمك مسار الـ LED الخفيف
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: isRead
                  ? SweepGradient(
                      center: Alignment.center,
                      transform: GradientRotation(_glowController.value * 6.28),
                      colors: [
                        AppColors.accentColor.withValues(alpha: 0.02),
                        AppColors.accentColor.withValues(
                          alpha: 0.45,
                        ), // نبتة ضوئية خفيفة
                        AppColors.accentColor.withValues(alpha: 0.15),
                        AppColors.accentColor.withValues(alpha: 0.02),
                      ],
                      stops: const [0.0, 0.45, 0.55, 1.0],
                    )
                  : null, // للإشعارات غير المقروءة نستخدم حدود ثابتة قوية
              border: isRead
                  ? null
                  : Border.all(
                      color: AppColors.accentColor.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isRead
                    ? AppColors.cardColor
                    : AppColors.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(17),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () {
                  if (!isRead && item.id != null) {
                    _cubit.markAsRead(item.id!);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? AppColors.borderColor.withValues(alpha: 0.2)
                                  : AppColors.accentColor.withValues(
                                      alpha: 0.15,
                                    ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isRead
                                    ? AppColors.borderColor.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppColors.accentColor.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: Icon(
                              Icons.content_cut_rounded,
                              color: isRead
                                  ? AppColors.textSecondary
                                  : AppColors.accentColor,
                              size: 22,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardColor,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: isRead
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.message ?? '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.errorColor.withValues(alpha: 0.8),
                          size: 22,
                        ),
                        onPressed: () {
                          if (item.id != null) {
                            _confirmDelete(item.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'حذف الإشعار',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا الإشعار؟',
            textAlign: TextAlign.right,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _cubit.deleteNotification(id);
              },
              child: Text(
                'حذف',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
