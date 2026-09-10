import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/availabilityCubit/free_slots_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../injections/bootStrap/auth/login_injection.dart';
import '../../../models/availability/free_slots/free_slots_model.dart';
import 'daySlotsDetailScreen.dart';

class FreeSlotsScreen extends StatefulWidget {
  const FreeSlotsScreen({super.key});

  @override
  State<FreeSlotsScreen> createState() => _FreeSlotsScreenState();
}

class _FreeSlotsScreenState extends State<FreeSlotsScreen>
    with SingleTickerProviderStateMixin {
  final FreeSlotsCubit _freeSlotsCubit = getIt<FreeSlotsCubit>();
  late AnimationController _ledController;

  static const Map<int, String> _weekDaysMap = {
    DateTime.monday: 'الإثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
  };

  @override
  void initState() {
    super.initState();
    _ledController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _freeSlotsCubit.getFreeSlots();
  }

  @override
  void dispose() {
    _ledController.dispose();
    _freeSlotsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'أوقات الفراغ المتاحة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<FreeSlotsCubit, ResultState<FreeSlotsModel>>(
        bloc: _freeSlotsCubit,
        listener: (context, state) {
          state.whenOrNull(
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
          return state.when(
            idle: () => const SizedBox.shrink(),
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            ),
            error: (message) => _buildErrorWidget(message),
            success: (data) {
              final days = data.data ?? [];
              if (days.isEmpty) return _buildEmptyState();

              return RefreshIndicator(
                color: AppColors.accentColor,
                backgroundColor: AppColors.cardColor,
                onRefresh: () => _freeSlotsCubit.getFreeSlots(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    return _buildDayCard(day);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDayCard(FreeSlotDay day) {
    final rawDate = day.date;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final dayName = parsedDate != null
        ? _weekDaysMap[parsedDate.weekday]
        : null;

    return AnimatedBuilder(
      animation: _ledController,
      builder: (context, child) {
        final pulseValue = (1.0 + (_ledController.value * 0.4));

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DaySlotsDetailScreen(dayData: day),
              ),
            );
          },
          child: CustomPaint(
            foregroundPainter: LedBorderPainter(
              animationValue: _ledController.value,
              glowColor: AppColors.accentColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentColor.withOpacity(0.12),
                          border: Border.all(
                            color: AppColors.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dayName != null)
                              Text(
                                dayName,
                                style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            Text(
                              rawDate ?? 'تاريخ غير محدد',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    height: 1,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'الدوام:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildTimeBadge(
                        icon: Icons.play_circle_fill_rounded,
                        label: day.workingHours?.startTime ?? '--:--',
                        color: const Color(0xFF10B981),
                        pulseValue: pulseValue,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.double_arrow_rounded,
                          size: 14,
                          color: AppColors.textSecondary.withOpacity(0.4),
                        ),
                      ),
                      _buildTimeBadge(
                        icon: Icons.stop_circle_rounded,
                        label: day.workingHours?.endTime ?? '--:--',
                        color: Colors.amber,
                        pulseValue: pulseValue,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${day.freeWindows?.length ?? 0} فترات',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeBadge({
    required IconData icon,
    required String label,
    required Color color,
    required double pulseValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.35 * pulseValue),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15 * pulseValue),
            blurRadius: 6 * pulseValue,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 70,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أوقات فراغ متاحة',
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

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 14),
          Text(message, style: TextStyle(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
            ),
            onPressed: () => _freeSlotsCubit.getFreeSlots(),
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(color: AppColors.backgroundColor),
            ),
          ),
        ],
      ),
    );
  }
}

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
