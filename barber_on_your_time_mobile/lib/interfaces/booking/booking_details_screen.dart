import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/bookingCubit/respond_booking_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import '../../models/booking/respondBooking/respond_booking_model.dart';

enum CountdownPhase { invalid, upcoming, inProgress, finished }

class BookingDetailsScreen extends StatefulWidget {
  final StaffBookingData booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late final RespondBookingCubit _cubit;

  Timer? _countdownTimer;

  Duration _remainingTime = Duration.zero;

  bool _isValidStartTime = true;

  CountdownPhase _countdownPhase = CountdownPhase.invalid;

  static const List<String> _dayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();

    _cubit = getIt<RespondBookingCubit>();

    _startCountdown();
  }

  // ============================================================
  // Countdown
  // ============================================================

  void _startCountdown() {
    // تحديث مباشر عند فتح الشاشة
    _updateRemainingTime();

    // تحديث مستمر كل ثانية
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final rawStartTime = widget.booking.startTime;

    if (rawStartTime == null || rawStartTime.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isValidStartTime = false;
        _countdownPhase = CountdownPhase.invalid;
        _remainingTime = Duration.zero;
      });
      return;
    }

    // 1. ضمان معالجة النص وتأكيده كـ UTC بإضافة Z إذا لم تكن موجودة
    String formattedIso = rawStartTime.trim().replaceAll(' ', 'T');
    if (!formattedIso.endsWith('Z') && !formattedIso.contains('+')) {
      formattedIso += 'Z';
    }

    final parsedStartTime = DateTime.tryParse(formattedIso);

    if (parsedStartTime == null) {
      if (!mounted) return;
      setState(() {
        _isValidStartTime = false;
        _countdownPhase = CountdownPhase.invalid;
        _remainingTime = Duration.zero;
      });
      return;
    }

    // 2. التحويل الصريح للـ UTC
    final startUtc = parsedStartTime.toUtc();
    final nowUtc = DateTime.now().toUtc();

    final durationMinutes = widget.booking.service?.durationMinutes ?? 0;
    final endUtc = startUtc.add(Duration(minutes: durationMinutes));

    CountdownPhase phase;
    Duration remaining;

    // 3. المقارنة بناءً على التوقيت العالمي UTC
    if (nowUtc.isBefore(startUtc)) {
      phase = CountdownPhase.upcoming;
      remaining = startUtc.difference(nowUtc);
    } else if (nowUtc.isBefore(endUtc)) {
      phase = CountdownPhase.inProgress;
      remaining = endUtc.difference(nowUtc);
    } else {
      phase = CountdownPhase.finished;
      remaining = Duration.zero;
      _countdownTimer?.cancel();
    }

    if (!mounted) return;

    setState(() {
      _isValidStartTime = true;
      _countdownPhase = phase;
      _remainingTime = remaining;
    });
  }

  // ============================================================
  // تحويل وقت الحجز للعرض المحلي
  // ============================================================

  DateTime? _getLocalBookingDate() {
    final rawStartTime = widget.booking.startTime;

    if (rawStartTime == null || rawStartTime.trim().isEmpty) {
      return null;
    }

    String formattedIso = rawStartTime.trim().replaceAll(' ', 'T');
    if (!formattedIso.endsWith('Z') && !formattedIso.contains('+')) {
      formattedIso += 'Z';
    }

    final parsed = DateTime.tryParse(formattedIso);

    if (parsed == null) {
      return null;
    }

    // UTC → Local للعرض فقط
    return parsed.toLocal();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // Status
  // ============================================================

  Color _statusColor(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return AppColors.successColor;

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

  // ============================================================
  // Countdown Parts (بدل نص واحد مدمج، منبني كل جزء كـ Widget مستقل
  // لتفادي مشكلة إعادة ترتيب الأرقام جوه النص العربي RTL)
  // ============================================================

  List<_TimePart> _remainingTimeParts() {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours.remainder(24);
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

    final List<_TimePart> parts = [];

    if (days > 0) parts.add(_TimePart(days, 'يوم'));
    if (hours > 0) parts.add(_TimePart(hours, 'ساعة'));
    if (minutes > 0) parts.add(_TimePart(minutes, 'دقيقة'));
    if (seconds > 0 || parts.isEmpty) parts.add(_TimePart(seconds, 'ثانية'));

    return parts;
  }

  // ============================================================
  // Countdown Subtitle
  // ============================================================

  String _countdownSubtitle() {
    switch (_countdownPhase) {
      case CountdownPhase.upcoming:
        return 'متبقي حتى بدء الحجز';

      case CountdownPhase.inProgress:
        return 'متبقي حتى انتهاء الحجز';

      case CountdownPhase.finished:
        return 'انتهى موعد الحجز';

      case CountdownPhase.invalid:
        return 'تعذر قراءة وقت الحجز';
    }
  }

  // ============================================================
  // Respond
  // ============================================================

  void _respond(String decision) {
    _cubit.respondToBooking(
      bookingId: widget.booking.id ?? 0,
      decision: decision,
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final date = _getLocalBookingDate();
    final statusColor = _statusColor(booking.status);
    final isPending = booking.status == 'PENDING';

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<RespondBookingCubit, ResultState<RespondBookingModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (data) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data.message ?? 'تم إرسال ردك بنجاح 🎉'),
                  backgroundColor: AppColors.successColor,
                ),
              );

              Navigator.pop(context, true);
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'تفاصيل الحجز',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // بطاقة الحالة
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: statusColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _statusLabel(booking.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // بطاقة التاريخ والوقت
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: date == null
                          ? Text(
                              'وقت غير معروف',
                              style: TextStyle(color: AppColors.textSecondary),
                            )
                          : Row(
                              children: [
                                _buildDateChip(
                                  icon: Icons.event_rounded,
                                  label: 'اليوم',
                                  value: _dayNames[date.weekday - 1],
                                ),
                                const SizedBox(width: 10),
                                _buildDateChip(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'التاريخ',
                                  value:
                                      '${date.day} ${_monthNames[date.month - 1]}',
                                ),
                                const SizedBox(width: 10),
                                _buildDateChip(
                                  icon: Icons.access_time_rounded,
                                  label: 'الساعة',
                                  value:
                                      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // Countdown Card
                    // ==================================================
                    _buildCountdownCard(),

                    const SizedBox(height: 24),

                    // ==================================================
                    // العميل
                    // ==================================================
                    Text(
                      'العميل',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.accentColor.withOpacity(
                              0.15,
                            ),
                            child: Text(
                              (booking.customer?.name?.isNotEmpty == true)
                                  ? booking.customer!.name![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.customer?.name ?? '',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.customer?.email ?? '',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // الخدمة
                    // ==================================================
                    Text(
                      'الخدمة',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cut_rounded,
                              color: AppColors.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.service?.name ?? '',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${booking.service?.durationMinutes ?? 0} دقيقة',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${booking.service?.price ?? 0} \$',
                            style: TextStyle(
                              color: AppColors.accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // أزرار القبول والرفض
                    // ==================================================
                    if (isPending) ...[
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _respond('REJECT'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.errorColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'رفض',
                                  style: TextStyle(
                                    color: AppColors.errorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _respond('ACCEPT'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentColor,
                                  disabledBackgroundColor: AppColors.accentColor
                                      .withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.backgroundColor,
                                        ),
                                      )
                                    : Text(
                                        'قبول',
                                        style: TextStyle(
                                          color: AppColors.backgroundColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // Countdown Card
  // ============================================================

  Widget _buildCountdownCard() {
    final hasInvalidTime = _countdownPhase == CountdownPhase.invalid;
    final isInProgress = _countdownPhase == CountdownPhase.inProgress;
    final isFinished = _countdownPhase == CountdownPhase.finished;

    final countdownColor = hasInvalidTime
        ? AppColors.errorColor
        : isInProgress || isFinished
        ? AppColors.successColor
        : AppColors.accentColor;

    final countdownIcon = hasInvalidTime
        ? Icons.error_outline_rounded
        : isFinished
        ? Icons.check_circle_outline_rounded
        : isInProgress
        ? Icons.play_circle_outline_rounded
        : Icons.timer_outlined;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: countdownColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: countdownColor.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Icon(countdownIcon, color: countdownColor, size: 30),
          const SizedBox(height: 10),
          Text(
            'الوقت المتبقي',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildRemainingTimeDisplay(countdownColor),
          const SizedBox(height: 4),
          Text(
            _countdownSubtitle(),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Remaining Time Display
  // كل جزء (رقم + وحدة) Widget مستقل بترتيب صريح، مش نص عربي مدمج
  // فيه أرقام لاتينية — هيك ما ينعكس ترتيب الأرقام بسبب bidi.
  // ============================================================

  Widget _buildRemainingTimeDisplay(Color countdownColor) {
    if (!_isValidStartTime) {
      return Text(
        'وقت الموعد غير معروف',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: countdownColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (_countdownPhase == CountdownPhase.finished) {
      return Text(
        'انتهى الحجز',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: countdownColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final parts = _remainingTimeParts();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _buildTimePartRow(parts[i], countdownColor),
        ],
      ],
    );
  }

  Widget _buildTimePartRow(_TimePart part, Color countdownColor) {
    // Row بترتيب widgets صريح (مش نص مدمج) لضمان إن الرقم يطلع
    // قبل الوحدة بصريًا بغض النظر عن اتجاه النص الطاغي بالتطبيق.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${part.value}',
          style: TextStyle(
            color: countdownColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          part.unit,
          style: TextStyle(
            color: countdownColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Date Chip
  // ============================================================

  Widget _buildDateChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentColor, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// نموذج بسيط لتمثيل جزء واحد من الوقت المتبقي (رقم + وحدة)
// ============================================================
class _TimePart {
  final int value;
  final String unit;

  const _TimePart(this.value, this.unit);
}
