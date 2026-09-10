import 'package:flutter/material.dart';

import '../../../core/color/colors.dart';
import '../../../models/availability/free_slots/free_slots_model.dart';

class DaySlotsDetailScreen extends StatefulWidget {
  final FreeSlotDay dayData;

  const DaySlotsDetailScreen({super.key, required this.dayData});

  @override
  State<DaySlotsDetailScreen> createState() => _DaySlotsDetailScreenState();
}

class _DaySlotsDetailScreenState extends State<DaySlotsDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ledController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ledController.dispose();
    super.dispose();
  }

  // حساب الفرق بين وقتين بالدقائق
  int _calculateDurationInMinutes(String? from, String? to) {
    if (from == null || to == null) return 0;
    try {
      final fromParts = from.split(':').map(int.parse).toList();
      final toParts = to.split(':').map(int.parse).toList();

      final fromMinutes = fromParts[0] * 60 + fromParts[1];
      final toMinutes = toParts[0] * 60 + toParts[1];

      return toMinutes >= fromMinutes
          ? toMinutes - fromMinutes
          : (24 * 60 - fromMinutes) + toMinutes;
    } catch (_) {
      return 0;
    }
  }

  // صيغة عرض المدة (ساعة / دقيقة)
  String _formatDuration(int minutes) {
    if (minutes <= 0) return '';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '$hours س و $mins د';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$mins دقيقة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final freeWindows = widget.dayData.freeWindows ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
          title: Column(
            children: [
              const Text(
                'جدول أوقات الفراغ',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.dayData.date ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صندوقان متجاوران في بداية الـ Body (التاريخ واليوم)
              _buildTodayHeaderRow(),
              const SizedBox(height: 18),

              // بطاقة المخطط البصري لساعات الدوام
              _buildHeaderDashboard(freeWindows.length),
              const SizedBox(height: 28),

              // عنوان القائمة مع شارة حية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentColor.withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'أوقات الفراغ المتاحة',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
                      color: AppColors.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${freeWindows.length} فترات',
                      style: const TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // قائمة الفترات أو حالة الفراغ
              if (freeWindows.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: freeWindows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final window = freeWindows[index];
                    return _buildWindowCard(window, index + 1);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // صندوقان في أول البودي (التاريخ واليوم المختار) مع إضاءة Led
  Widget _buildTodayHeaderRow() {
    final rawDate = widget.dayData.date;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final dayName = parsedDate != null
        ? _weekDaysMap[parsedDate.weekday] ?? ''
        : '';

    return Row(
      children: [
        // صندوق التاريخ
        Expanded(
          flex: 3,
          child: AnimatedBuilder(
            animation: _ledController,
            builder: (context, child) {
              return CustomPaint(
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
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentColor.withOpacity(0.12),
                          border: Border.all(
                            color: AppColors.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التاريخ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rawDate ?? 'غير محدد',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // صندوق اليوم
        Expanded(
          flex: 2,
          child: AnimatedBuilder(
            animation: _ledController,
            builder: (context, child) {
              return CustomPaint(
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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اليوم',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayName.isNotEmpty ? dayName : '—',
                        style: const TextStyle(
                          color: AppColors.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Dashboard بطاقة أعلى الشاشة مع إطار متوهج
  Widget _buildHeaderDashboard(int freeSlotsCount) {
    final startTime = widget.dayData.workingHours?.startTime ?? '--:--';
    final endTime = widget.dayData.workingHours?.endTime ?? '--:--';

    return AnimatedBuilder(
      animation: _ledController,
      builder: (context, child) {
        return CustomPaint(
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
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time_filled_rounded,
                            color: AppColors.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'نطاق الدوام الكامل',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    _buildPulseStatusBadge(freeSlotsCount > 0),
                  ],
                ),
                const SizedBox(height: 20),

                // المخطط البياني المتوهج لساعات الدوام
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x80FFD700),
                                AppColors.accentColor,
                                Colors.amberAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentColor.withOpacity(
                                  0.3 + (_pulseController.value * 0.3),
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn(
                      'بداية الدوام',
                      startTime,
                      Icons.play_circle_fill_rounded,
                      const Color(0xFF10B981),
                    ),
                    _buildTimeColumn(
                      'نهاية الدوام',
                      endTime,
                      Icons.stop_circle_rounded,
                      Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // مؤشر النبض التفاعلي لحالة اليوم
  Widget _buildPulseStatusBadge(bool hasSlots) {
    final color = hasSlots ? const Color(0xFF10B981) : Colors.redAccent;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color.withOpacity(0.3 + (_pulseController.value * 0.4)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 4 * _pulseController.value,
                      spreadRadius: 2 * _pulseController.value,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                hasSlots ? 'متاح للطلب' : 'مكتمل',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(
    String label,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // بطاقات فترات الفراغ مع تأثير الإطار المتوهج
  Widget _buildWindowCard(FreeWindow window, int index) {
    final durationMinutes = _calculateDurationInMinutes(window.from, window.to);
    final durationText = _formatDuration(durationMinutes);

    return AnimatedBuilder(
      animation: _ledController,
      builder: (context, child) {
        return CustomPaint(
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
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // شارة رقم الفترة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentColor.withOpacity(0.25),
                        AppColors.accentColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'فترة $index',
                    style: const TextStyle(
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // تفاصيل الوقت المنتصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            window.from ?? '--:--',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_right_alt_rounded,
                              color: AppColors.accentColor,
                              size: 20,
                            ),
                          ),
                          Text(
                            window.to ?? '--:--',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // شارة مدة الفترة بالوقت
                if (durationText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColors.accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          durationText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // شاشة الشاغر الفارغ
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 56,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا تتوفر فترات فراغ بهذا اليوم',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'يبدو أن جدول هذا اليوم ممتلئ بالكامل',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
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
