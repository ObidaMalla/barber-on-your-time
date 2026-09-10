import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/bookingCubit/respond_booking_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../injections/bootStrap/auth/login_injection.dart';
import '../../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import '../../../models/booking/respondBooking/respond_booking_model.dart';
import 'CompleteBookingScreen.dart';

enum CountdownPhase { invalid, upcoming, inProgress, finished }

class BookingDetailsScreen extends StatefulWidget {
  final StaffBookingData booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with TickerProviderStateMixin {
  late final RespondBookingCubit _respondCubit;
  late final AnimationController _ledController;

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isValidStartTime = true;
  CountdownPhase _countdownPhase = CountdownPhase.invalid;

  bool _canEnterCode = false;

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
    _respondCubit = getIt<RespondBookingCubit>();
    _ledController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _startCountdown();
  }

  void _startCountdown() {
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (widget.booking.status == 'COMPLETED') {
      _countdownTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isValidStartTime = true;
        _countdownPhase = CountdownPhase.finished;
        _remainingTime = Duration.zero;
        _canEnterCode = false;
      });
      return;
    }

    final rawStartTime = widget.booking.startTime;

    if (rawStartTime == null || rawStartTime.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isValidStartTime = false;
        _countdownPhase = CountdownPhase.invalid;
        _remainingTime = Duration.zero;
        _canEnterCode = false;
      });
      return;
    }

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
        _canEnterCode = false;
      });
      return;
    }

    final startUtc = parsedStartTime.toUtc();
    final nowUtc = DateTime.now().toUtc();
    final durationMinutes = widget.booking.service?.durationMinutes ?? 0;
    final endUtc = startUtc.add(Duration(minutes: durationMinutes));

    final halfTimeUtc = startUtc.add(
      Duration(minutes: (durationMinutes / 2).round()),
    );

    CountdownPhase phase;
    Duration remaining;

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

      // الشرط المنطقي: إذا انتهى الوقت (وصل للصفر) والحالة ما زالت PENDING، قم بتحويلها تلقائياً إلى مرفوض
      if (widget.booking.status == 'PENDING') {
        _respondAutomaticReject();
      }
    }

    final reachedHalfTime =
        nowUtc.isAfter(halfTimeUtc) || nowUtc.isAtSameMomentAs(halfTimeUtc);
    final showCodeIcon = reachedHalfTime;

    if (!mounted) return;

    setState(() {
      _isValidStartTime = true;
      _countdownPhase = phase;
      _remainingTime = remaining;
      _canEnterCode = showCodeIcon;
    });
  }

  void _respondAutomaticReject() {
    // لمنع التكرار المستمر إذا كان الطلب قيد التنفيذ أو تم إرساله مسبقاً
    if (widget.booking.status != 'PENDING') return;

    // تحديث الحالة محلياً منعاً لتكرار الطلب
    widget.booking.status =
        'CANCELLED'; // أو 'REJECTED' حسب القيمة المعتمدة في النظام لديك
    _respond('REJECT');
  }

  DateTime? _getLocalBookingDate() {
    final rawStartTime = widget.booking.startTime;
    if (rawStartTime == null || rawStartTime.trim().isEmpty) return null;

    String formattedIso = rawStartTime.trim().replaceAll(' ', 'T');
    if (!formattedIso.endsWith('Z') && !formattedIso.contains('+')) {
      formattedIso += 'Z';
    }

    return DateTime.tryParse(formattedIso)?.toLocal();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ledController.dispose();
    super.dispose();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'CONFIRMED':
      case 'COMPLETED':
        return AppColors.successColor;
      case 'PENDING':
        return Colors.orange;
      case 'NEEDS_OWNER':
        return AppColors.accentColor;
      case 'CANCELLED':
      case 'REJECTED':
        return AppColors.errorColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return 'مؤكد';
      case 'COMPLETED':
        return 'مكتمل';
      case 'PENDING':
        return 'بانتظار الرد';
      case 'NEEDS_OWNER':
        return 'يحتاج تدخل المدير';
      case 'CANCELLED':
      case 'REJECTED':
        return 'مرفوض';
      default:
        return status ?? '';
    }
  }

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

  void _respond(String decision) {
    _respondCubit.respondToBooking(
      bookingId: widget.booking.id ?? 0,
      decision: decision,
    );
  }

  void _navigateToCompleteBookingScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CompleteBookingScreen(bookingId: widget.booking.id ?? 0),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        widget.booking.status = 'COMPLETED';
        _canEnterCode = false;
        _updateRemainingTime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final date = _getLocalBookingDate();
    final statusColor = _statusColor(booking.status);
    final isPending = booking.status == 'PENDING';

    return BlocProvider.value(
      value: _respondCubit,
      child: BlocConsumer<RespondBookingCubit, ResultState<RespondBookingModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (data) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    data.message ?? 'تم إرسال ردك بنجاح 🎉',
                    textAlign: TextAlign.right,
                  ),
                  backgroundColor: AppColors.successColor,
                ),
              );
              Navigator.pop(context, true);
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message, textAlign: TextAlign.right),
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
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.accentColor,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'تفاصيل الحجز',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                if (_canEnterCode)
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    color: AppColors.accentColor,
                    tooltip: 'إدخال كود الإكمال',
                    onPressed: _navigateToCompleteBookingScreen,
                  ),
              ],
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
                    // بطاقة الحالة مع إضاءة Led
                    AnimatedBuilder(
                      animation: _ledController,
                      builder: (context, child) {
                        return CustomPaint(
                          foregroundPainter: LedBorderPainter(
                            animationValue: _ledController.value,
                            glowColor: statusColor,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _statusLabel(booking.status),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: statusColor,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // بطاقة التاريخ والوقت مع إضاءة Led
                    AnimatedBuilder(
                      animation: _ledController,
                      builder: (context, child) {
                        return CustomPaint(
                          foregroundPainter: LedBorderPainter(
                            animationValue: _ledController.value,
                            glowColor: AppColors.accentColor,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: date == null
                                ? Text(
                                    'وقت غير معروف',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildDateChip(
                                        icon: Icons.access_time_rounded,
                                        label: 'الساعة',
                                        value:
                                            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                      ),
                                      _buildDateChip(
                                        icon: Icons.calendar_today_rounded,
                                        label: 'التاريخ',
                                        value:
                                            '${date.day} ${_monthNames[date.month - 1]}',
                                      ),
                                      _buildDateChip(
                                        icon: Icons.event_rounded,
                                        label: 'اليوم',
                                        value: _dayNames[date.weekday - 1],
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // بطاقة العد التنازلي
                    _buildCountdownCard(),
                    const SizedBox(height: 24),

                    const Text(
                      'العميل',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // بطاقة العميل مع إضاءة Led
                    AnimatedBuilder(
                      animation: _ledController,
                      builder: (context, child) {
                        return CustomPaint(
                          foregroundPainter: LedBorderPainter(
                            animationValue: _ledController.value,
                            glowColor: AppColors.accentColor,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        booking.customer?.name ?? '',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.customer?.email ?? '',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.accentColor
                                      .withOpacity(0.15),
                                  child: Text(
                                    (booking.customer?.name?.isNotEmpty == true)
                                        ? booking.customer!.name![0]
                                              .toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppColors.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'الخدمة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // بطاقة الخدمة مع إضاءة Led
                    AnimatedBuilder(
                      animation: _ledController,
                      builder: (context, child) {
                        return CustomPaint(
                          foregroundPainter: LedBorderPainter(
                            animationValue: _ledController.value,
                            glowColor: AppColors.accentColor,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${booking.service?.price ?? 0} \$',
                                  style: TextStyle(
                                    color: AppColors.accentColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        booking.service?.name ?? '',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${booking.service?.durationMinutes ?? 0} دقيقة',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor.withOpacity(
                                      0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.cut_rounded,
                                    color: AppColors.accentColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    if (isPending) ...[
                      const SizedBox(height: 36),
                      Row(
                        children: [
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
                          const SizedBox(width: 14),
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

  Widget _buildCountdownCard() {
    final isCompleted = widget.booking.status == 'COMPLETED';
    final hasInvalidTime = _countdownPhase == CountdownPhase.invalid;
    final isInProgress = _countdownPhase == CountdownPhase.inProgress;
    final isFinished = _countdownPhase == CountdownPhase.finished;

    final countdownColor = (isCompleted || isInProgress || isFinished)
        ? AppColors.successColor
        : hasInvalidTime
        ? AppColors.errorColor
        : AppColors.accentColor;

    final countdownIcon = (isCompleted || isFinished)
        ? Icons.check_circle_outline_rounded
        : hasInvalidTime
        ? Icons.error_outline_rounded
        : isInProgress
        ? Icons.play_circle_outline_rounded
        : Icons.timer_outlined;

    final titleText = isCompleted
        ? 'حالة الخدمة'
        : isFinished
        ? 'حالة الموعد'
        : 'الوقت المتبقي';

    return AnimatedBuilder(
      animation: _ledController,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: LedBorderPainter(
            animationValue: _ledController.value,
            glowColor: countdownColor,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(countdownIcon, color: countdownColor, size: 30),
                const SizedBox(height: 10),
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRemainingTimeDisplay(countdownColor),
                if (!isCompleted) ...[
                  const SizedBox(height: 4),
                  Text(
                    _countdownSubtitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

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

    if (widget.booking.status == 'COMPLETED') {
      return Text(
        'تم تقديم الخدمة',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.successColor,
          fontSize: 22,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          part.unit,
          style: TextStyle(
            color: countdownColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${part.value}',
          style: TextStyle(
            color: countdownColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

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

class _TimePart {
  final int value;
  final String unit;
  const _TimePart(this.value, this.unit);
}

// رسم الإطار الضوئي المتوهج (Led Effect)
class LedBorderPainter extends CustomPainter {
  final double animationValue;
  final Color glowColor;

  LedBorderPainter({required this.animationValue, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rpath = RRect.fromRectAndRadius(rect, const Radius.circular(22));

    final basePaint = Paint()
      ..color = glowColor.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rpath, basePaint);

    const double sweepAngle = 2 * 3.141592653589793;
    final double startAngle = animationValue * sweepAngle;

    final ledPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          glowColor.withOpacity(0.1),
          glowColor,
          Colors.white,
          glowColor,
          glowColor.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.48, 0.5, 0.52, 0.6, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(rect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..shader = ledPaint.shader;

    canvas.drawRRect(rpath, glowPaint);
    canvas.drawRRect(rpath, ledPaint);
  }

  @override
  bool shouldRepaint(covariant LedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
