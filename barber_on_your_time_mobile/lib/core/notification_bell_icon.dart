import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/color/colors.dart';
import '../cubits/notifications/unread_count_cubit.dart';
import '../injections/bootStrap/auth/login_injection.dart';
import '../interfaces/notifications/notifications_screen.dart';

class NotificationBellIcon extends StatefulWidget {
  const NotificationBellIcon({super.key});

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon> {
  @override
  void initState() {
    super.initState();
    getIt<UnreadCountCubit>().fetchUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnreadCountCubit, int>(
      bloc: getIt<UnreadCountCubit>(),
      builder: (context, unreadCount) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
                getIt<UnreadCountCubit>().fetchUnreadCount();
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/*
NotificationBellIconStatefulWidgetودجة (Widget) تفاعلية تمثل أيقونة الجرس للاستخدام في شريط التطبيق (AppBar).initState()Methodتقوم بطلب عدد الإشعارات غير المقروءة من السيرفر بمجرد بناء الودجة لأول مرة.BlocBuilderWidgetيستمع للتغيرات في UnreadCountCubit ويعيد بناء الواجهة فور تغيّر عداد الإشعارات.IconButtonWidgetزر الجرس؛ عند الضغط عليه يفتح شاشة الإشعارات NotificationsScreen وعند العودة منها يعيد جلب العداد لتحديث الشارة.Stack / PositionedWidgetsتُستخدم لتراكب الأيقونة مع الشارة الحمراء وتحديد موقع الدائرة أعلى يمين الجرس.Container (الشارة)Widgetالدائرة الحمراء التي تعرض رقم الإشعارات. تعرِض 99+ إذا تجاوز الرقم 99، وتختفي تماماً إذا كان العدد 0.
* */
