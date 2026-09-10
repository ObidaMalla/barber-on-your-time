import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../core/notification_bell_icon.dart';
import '../../cubits/bookingCubit/get_staff_bookings_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import 'bookingDetails/booking_details_screen.dart';

class StaffBookingsScreen extends StatefulWidget {
  const StaffBookingsScreen({super.key});

  @override
  State<StaffBookingsScreen> createState() => _StaffBookingsScreenState();
}

class _StaffBookingsScreenState extends State<StaffBookingsScreen> {
  final GetStaffBookingsCubit _cubit = getIt<GetStaffBookingsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.fetchStaffBookings();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return AppColors.successColor; // الأخضر للـ CONFIRMED
      case 'PENDING':
        return Colors.orange;
      case 'NEEDS_OWNER':
        return AppColors.accentColor;
      case 'CANCELLED':
        return AppColors.errorColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return 'مؤكد';
      case 'PENDING':
        return 'بانتظار الرد';
      case 'NEEDS_OWNER':
        return 'يحتاج تدخل المدير';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status ?? '';
    }
  }

  // فصل التاريخ والوقت لعرشهما بكلمات صريحة
  Map<String, String> _formatDateTime(String? iso) {
    if (iso == null) return {'date': '', 'time': ''};
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return {'date': '', 'time': ''};

    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return {'date': formattedDate, 'time': formattedTime};
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
          title: Text(
            'حجوزات العملاء',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            const NotificationBellIcon(),
            IconButton(
              onPressed: () => _cubit.fetchStaffBookings(),
              icon: Icon(Icons.refresh_rounded, color: AppColors.accentColor),
            ),
          ],
        ),
        body:
            BlocBuilder<
              GetStaffBookingsCubit,
              ResultState<GetStaffBookingsModel>
            >(
              bloc: _cubit,
              builder: (context, state) {
                return state.when(
                  idle: () => const SizedBox.shrink(),
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                    ),
                  ),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  success: (data) {
                    final list = data.data ?? [];
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 70,
                              color: AppColors.textSecondary.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ما عندك حجوزات حالياً',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final sorted = List<StaffBookingData>.from(list)
                      ..sort(
                        (a, b) =>
                            (b.startTime ?? '').compareTo(a.startTime ?? ''),
                      );

                    return RefreshIndicator(
                      color: AppColors.accentColor,
                      backgroundColor: AppColors.cardColor,
                      onRefresh: () async => _cubit.fetchStaffBookings(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildBookingCard(sorted[index]);
                        },
                      ),
                    );
                  },
                );
              },
            ),
      ),
    );
  }

  Widget _buildBookingCard(StaffBookingData booking) {
    final statusColor = _statusColor(booking.status);
    final dateTimeMap = _formatDateTime(booking.startTime);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: booking),
          ),
        );
        if (result == true && mounted) {
          _cubit.fetchStaffBookings();
        }
      },
      child: _LightSweepBorder(
        borderRadius: 20,
        borderColor:
            statusColor, // إطار ضوئي أخضر إذا مؤكد، أو بلون الحالة المناسب
        borderThickness: 2.5, // تم زيادة سمك الخط
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة ماكينة الحلاقة بدلاً من الحرف الأبجدي/الصورة
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentColor.withOpacity(0.15),
                      border: Border.all(
                        color: AppColors.accentColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.content_cut_rounded, // أيقونة حلاقة
                      color: AppColors.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customer?.name ?? 'عميل',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // إضافة "نوع الخدمة:"
                        Text(
                          'نوع الخدمة: ${booking.service?.name ?? 'غير محدد'}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(booking.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // التوقيت والتاريخ بشكل صريح مع كلمتي التاريخ والوقت
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'التاريخ: ${dateTimeMap['date']}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'الوقت: ${dateTimeMap['time']}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (booking.service?.price != null)
                    Text(
                      '${booking.service!.price} \$',
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// Light Sweep Animation Border Widget (مع دعم زيادة السمك)
// =========================================================
class _LightSweepBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double borderThickness;

  const _LightSweepBorder({
    required this.child,
    required this.borderRadius,
    required this.borderColor,
    this.borderThickness = 2.5,
  });

  @override
  State<_LightSweepBorder> createState() => _LightSweepBorderState();
}

class _LightSweepBorderState extends State<_LightSweepBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(widget.borderThickness),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              transform: GradientRotation(_controller.value * 6.283185),
              colors: [
                widget.borderColor.withOpacity(0.15),
                widget.borderColor,
                widget.borderColor.withOpacity(0.15),
              ],
              stops: const [0.0, 0.25, 0.5],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
