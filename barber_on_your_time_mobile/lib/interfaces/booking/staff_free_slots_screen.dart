import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/availabilityCubit/staff_free_slots_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/availability/free_slots/free_slots_model.dart';

class StaffFreeSlotsScreen extends StatefulWidget {
  final int staffId;
  final String staffName;

  const StaffFreeSlotsScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffFreeSlotsScreen> createState() => _StaffFreeSlotsScreenState();
}

class _StaffFreeSlotsScreenState extends State<StaffFreeSlotsScreen> {
  late final StaffFreeSlotsCubit _freeSlotsCubit;

  @override
  void initState() {
    super.initState();
    _freeSlotsCubit = getIt<StaffFreeSlotsCubit>();
    _freeSlotsCubit.getStaffFreeSlots(widget.staffId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'جدول أوقات ${widget.staffName}',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<StaffFreeSlotsCubit, ResultState<FreeSlotsModel>>(
        bloc: _freeSlotsCubit,
        builder: (context, state) {
          return state.when(
            idle: () => const SizedBox.shrink(),
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            ),
            error: (msg) => Center(
              child: Text(msg, style: TextStyle(color: AppColors.errorColor)),
            ),
            success: (data) {
              final slots = data.data ?? [];
              if (slots.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد أوقات متاحة حالياً',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  return _AnimatedNeonDayCard(dayData: slots[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// ============================================================
/// كرت اليوم — بحدود LED متحركة بلا توقف + رسم بياني للتفرغ
/// ============================================================
class _AnimatedNeonDayCard extends StatefulWidget {
  final FreeSlotDay dayData;

  const _AnimatedNeonDayCard({required this.dayData});

  @override
  State<_AnimatedNeonDayCard> createState() => _AnimatedNeonDayCardState();
}

class _AnimatedNeonDayCardState extends State<_AnimatedNeonDayCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // 👈 يتكرر للأبد بلا توقف
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _toMinutes(String? hhmm) {
    if (hhmm == null) return 0;
    try {
      final parts = hhmm.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {
      return 0;
    }
  }

  // 👈 دالة لجلب اسم اليوم باللغة العربية من التاريخ
  String _getDayName(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      switch (dateTime.weekday) {
        case DateTime.monday:
          return 'الاثنين';
        case DateTime.tuesday:
          return 'الثلاثاء';
        case DateTime.wednesday:
          return 'الأربعاء';
        case DateTime.thursday:
          return 'الخميس';
        case DateTime.friday:
          return 'الجمعة';
        case DateTime.saturday:
          return 'السبت';
        case DateTime.sunday:
          return 'الأحد';
        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayData = widget.dayData;
    final freeWindows = dayData.freeWindows ?? [];

    final workStart = _toMinutes(dayData.workingHours?.startTime);
    final workEnd = _toMinutes(dayData.workingHours?.endTime);
    final totalWorkMinutes = (workEnd - workStart)
        .clamp(1, double.infinity)
        .toInt();

    final freeMinutes = freeWindows.fold<int>(0, (sum, w) {
      return sum + (_toMinutes(w.to) - _toMinutes(w.from));
    });
    final busyMinutes = (totalWorkMinutes - freeMinutes).clamp(
      0,
      totalWorkMinutes,
    );

    final freeRatio = freeMinutes / totalWorkMinutes; // 0.0 لغاية 1.0

    // الحكم على الحالة حسب النسبة الفعلية، مش عدد الفترات
    Color statusColor;
    String statusText;

    if (freeWindows.isEmpty || freeRatio == 0) {
      statusColor = const Color(0xFFFF3366); // أحمر نيون
      statusText = 'مكتمل الحجوزات';
    } else if (freeRatio < 0.4) {
      statusColor = const Color(0xFFFFB800); // أصفر نيون
      statusText = 'مزدحم';
    } else {
      statusColor = const Color(0xFF00FF88); // أخضر نيون
      statusText = 'تفرغ ممتاز';
    }

    final dayName = _getDayName(dayData.date);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _ChasingBorderPainter(
            progress: _controller.value,
            color: statusColor,
          ),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر: التاريخ واليوم + حالة الـ LED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.accentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dayName.isNotEmpty
                            ? '$dayName, ${dayData.date ?? ''}'
                            : dayData.date ?? '',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor,
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // أوقات الدوام الرسمية
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الدوام: ${dayData.workingHours?.startTime ?? ''} - ${dayData.workingHours?.endTime ?? ''}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ============================================
              // الرسم البياني — شريط نسبة الفراغ مقابل الازدحام
              // ============================================
              _buildAvailabilityBar(freeRatio),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'فاضي: $freeMinutes د',
                    style: const TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'محجوز: $busyMinutes د',
                    style: const TextStyle(
                      color: Color(0xFFFF3366),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: AppColors.borderColor.withOpacity(0.5), height: 1),
              const SizedBox(height: 16),

              Text(
                'الفترات المتاحة للحجز:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // عرض الفترات كأزرار Neon متوهجة
              if (freeWindows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'لا توجد فترات شاغرة لهذا اليوم',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: freeWindows.map((window) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentColor.withOpacity(0.7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentColor.withOpacity(0.15),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flash_on_rounded,
                            size: 14,
                            color: AppColors.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${window.from} - ${window.to}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityBar(double freeRatio) {
    final freePercent = (freeRatio * 100).clamp(0, 100).round();
    final busyPercent = 100 - freePercent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            if (freePercent > 0)
              Expanded(
                flex: freePercent,
                child: Container(color: const Color(0xFF00FF88)),
              ),
            if (busyPercent > 0)
              Expanded(
                flex: busyPercent,
                child: Container(
                  color: const Color(0xFFFF3366).withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// رسّام الحدود المتوهجة المتحركة (تدور حوالين الكرت بلا توقف)
/// ============================================================
class _ChasingBorderPainter extends CustomPainter {
  final double progress; // 0.0 ⟶ 1.0، بيتكرر للأبد
  final Color color;
  final double radius;
  final double strokeWidth;

  _ChasingBorderPainter({
    required this.progress,
    required this.color,
    this.radius = 20,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    // الإطار الخافت الثابت (خلفية الحدود)
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final metric = path.computeMetrics().first;
    final segmentLength = metric.length * 0.22; // طول القطعة المضيئة
    final start = metric.length * progress;
    final end = start + segmentLength;

    Path segment;
    if (end <= metric.length) {
      segment = metric.extractPath(start, end);
    } else {
      // القطعة تلف من نهاية الإطار لبدايتو (حركة مستمرة بلا قطع)
      segment = metric.extractPath(start, metric.length);
      segment.addPath(metric.extractPath(0, end - metric.length), Offset.zero);
    }

    // توهج خارجي (Blur) — إحساس النيون
    canvas.drawPath(
      segment,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 3
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // الخط المضيء الحاد بالمنتصف
    canvas.drawPath(
      segment,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChasingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
