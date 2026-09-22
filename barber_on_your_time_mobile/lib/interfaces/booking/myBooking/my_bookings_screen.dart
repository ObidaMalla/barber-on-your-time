import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/color/colors.dart';
import '../../../core/notification_bell_icon.dart';
import '../../../cubits/bookingCubit/cancel_booking_cubit.dart';
import '../../../cubits/bookingCubit/get_my_bookings_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../injections/bootStrap/auth/login_injection.dart';
import '../../../models/booking/cancelBooking/cancel_booking_model.dart';
import '../../../models/booking/getMyBookings/get_my_bookings_model.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final GetMyBookingsCubit _cubit;
  late final CancelBookingCubit _cancelCubit;
  late final AnimationController _glowController;

  int? _selectedBookingId;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<GetMyBookingsCubit>();
    _cancelCubit = getIt<CancelBookingCubit>();
    _cubit.getMyBookings();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getStatusThemeColor(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blue;

      case 'COMPLETED':
        return Colors.green;

      case 'NO_SHOW':
      case 'CANCELLED':
        return Colors.red;

      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'PENDING':
        return 'قيد الانتظار';

      case 'CONFIRMED':
        return 'قيد التنفيذ';

      case 'COMPLETED':
        return 'مكتملة';

      case 'NO_SHOW':
        return 'عدم حضور';

      case 'CANCELLED':
        return 'ملغاة';

      default:
        return 'قيد الانتظار';
    }
  }

  String _formatDateTime(String? isoUtc) {
    if (isoUtc == null) return '';
    final utcDate = DateTime.parse(isoUtc);
    final localDate = utcDate.toLocal();
    return DateFormat('yyyy-MM-dd  •  hh:mm a').format(localDate);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _onLongPressCard(int bookingId) {
    setState(() {
      _selectedBookingId = bookingId;
    });
  }

  void _onTapCard(MyBookingData booking) {
    if (_selectedBookingId != null) {
      setState(() {
        _selectedBookingId = _selectedBookingId == booking.id
            ? null
            : booking.id;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(booking: booking),
        ),
      );
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedBookingId = null;
    });
  }

  Future<void> _confirmCancelBooking() async {
    if (_selectedBookingId == null) return;

    final bookingId = _selectedBookingId!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'تأكيد إلغاء الحجز',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'هل أنت متأكد من إلغاء هذا الحجز؟ لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'تراجع',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      _cancelCubit.cancelBooking(bookingId: bookingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectionMode = _selectedBookingId != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: isSelectionMode
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: _clearSelection,
                )
              : null,
          title: Text(
            isSelectionMode ? 'تم تحديد عنصر' : 'حجوزاتي',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            const NotificationBellIcon(),
            if (isSelectionMode)
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.errorColor),
                onPressed: _confirmCancelBooking,
              ),
          ],
        ),
        body: BlocListener<CancelBookingCubit, ResultState<CancelBookingModel>>(
          bloc: _cancelCubit,
          listener: (context, state) {
            state.whenOrNull(
              loading: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                      ),
                    );
                  },
                );
              },
              success: (data) {
                Navigator.pop(context);
                _showSnackBar('تم إلغاء الحجز بنجاح', Colors.green);
                _clearSelection();
                _cancelCubit.resetState();
                _cubit.getMyBookings();
              },
              error: (message) {
                Navigator.pop(context);
                _showSnackBar(message, AppColors.errorColor);
                _cancelCubit.resetState();
              },
            );
          },
          child:
              BlocBuilder<GetMyBookingsCubit, ResultState<GetMyBookingsModel>>(
                bloc: _cubit,
                builder: (context, state) {
                  return state.when(
                    idle: () => const SizedBox.shrink(),
                    loading: () {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentColor,
                        ),
                      );
                    },
                    error: (msg) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.errorColor,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                msg,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.errorColor),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _cubit.getMyBookings(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentColor,
                                ),
                                child: const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    success: (data) {
                      final bookings = (data.data ?? [])
                          .where((b) => b.status != 'CANCELLED')
                          .toList();

                      if (bookings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا توجد حجوزات بعد',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.accentColor,
                        onRefresh: () => _cubit.getMyBookings(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _buildGlowingBookingCard(bookings[index]);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildGlowingBookingCard(MyBookingData booking) {
    final themeColor = _getStatusThemeColor(booking.status);
    final bookingId = booking.id;
    final bool isSelected =
        bookingId != null && _selectedBookingId == bookingId;

    return GestureDetector(
      onLongPress: bookingId == null ? null : () => _onLongPressCard(bookingId),
      onTap: () => _onTapCard(booking),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: isSelected ? 52 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.15),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        gradient: SweepGradient(
                          center: Alignment.center,
                          transform: GradientRotation(
                            _glowController.value * 6.28,
                          ),
                          colors: [
                            themeColor.withOpacity(0.05),
                            themeColor,
                            themeColor.withOpacity(0.8),
                            themeColor.withOpacity(0.05),
                          ],
                          stops: const [0.0, 0.45, 0.55, 1.0],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(color: AppColors.cardColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking.service?.name ?? 'خدمة غير محددة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: themeColor.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _statusLabel(booking.status),
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payments_outlined,
                                  size: 16,
                                  color: themeColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${booking.service?.price ?? 0} ل.س',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${booking.service?.durationMinutes ?? 0} دقيقة',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: AppColors.textPrimary.withOpacity(0.08),
                                height: 1,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.inputColor,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: 14,
                                          color: themeColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          booking.staff?.user?.name ??
                                              'بدون اسم',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _formatDateTime(booking.startTime),
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
