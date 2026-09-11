import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/bookingCubit/staff_statistics_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../injections/bootStrap/booking/staff_statistics_injection.dart';
import '../../../models/booking/StaffStatistics/staff_statistics_model.dart';

class StaffStatisticsScreen extends StatefulWidget {
  const StaffStatisticsScreen({super.key});

  @override
  State<StaffStatisticsScreen> createState() => _StaffStatisticsScreenState();
}

class _StaffStatisticsScreenState extends State<StaffStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final StaffStatisticsCubit _cubit;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<StaffStatisticsCubit>();
    _cubit.getMyStats();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // 👈 أطول شوي لإحساس أنعم
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
            'الإحصائيات والأداء',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Stack(
          children: [
            // 🌌 خلفية زخرفية ناعمة (توهجات دائرية خافتة)
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(color: AppColors.accentColor, size: 220),
            ),
            Positioned(
              bottom: -60,
              left: -80,
              child: _GlowOrb(color: AppColors.errorColor, size: 200),
            ),

            BlocConsumer<
              StaffStatisticsCubit,
              ResultState<StaffStatisticsModel>
            >(
              bloc: _cubit,
              listener: (context, state) {
                state.whenOrNull(
                  success: (_) => _animController.forward(from: 0.0),
                  error: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  idle: () => const SizedBox.shrink(),
                  loading: () => _buildShimmerLoading(),
                  error: (msg) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.errorColor,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          msg,
                          style: TextStyle(color: AppColors.errorColor),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _cubit.getMyStats(),
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
                  success: (model) {
                    final data = model.data;
                    final thisWeek = data?.thisWeek;

                    final totalCompleted = data?.totalServicesCompleted ?? 0;
                    final totalRejected = data?.totalServicesRejected ?? 0;
                    final revenue = (thisWeek?.revenue ?? 0).toDouble();
                    final formattedTime =
                        thisWeek?.formattedWorkedTime ?? '0 دقيقة';

                    return RefreshIndicator(
                      color: AppColors.accentColor,
                      onRefresh: () async => _cubit.getMyStats(),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildAnimatedCard(
                            index: 0,
                            child: _buildPieChartCard(
                              completed: totalCompleted,
                              rejected: totalRejected,
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                            children: [
                              _buildAnimatedCard(
                                index: 1,
                                child: _buildStatCard(
                                  title: 'أرباح الأسبوع',
                                  numericValue: revenue,
                                  suffix: ' ل.س',
                                  icon: Icons.monetization_on_rounded,
                                  color: const Color(0xFF00E676),
                                ),
                              ),
                              _buildAnimatedCard(
                                index: 2,
                                child: _buildStatCard(
                                  title: 'ساعات العمل',
                                  staticValue: formattedTime,
                                  icon: Icons.access_time_filled_rounded,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                              _buildAnimatedCard(
                                index: 3,
                                child: _buildStatCard(
                                  title: 'خدمات مكتملة',
                                  numericValue: totalCompleted.toDouble(),
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.accentColor,
                                ),
                              ),
                              _buildAnimatedCard(
                                index: 4,
                                child: _buildStatCard(
                                  title: 'خدمات مرفوضة',
                                  numericValue: totalRejected.toDouble(),
                                  icon: Icons.cancel_rounded,
                                  color: AppColors.errorColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Staggered entrance animation (fade + slide-up)
  // ============================================================
  Widget _buildAnimatedCard({required int index, required Widget child}) {
    final double start = (index * 0.13).clamp(0.0, 0.6);
    final double end = (start + 0.45).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * 40),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ============================================================
  // كارت الرسم البياني الدائري — يترسم تدريجياً مع الأنيميشن
  // ============================================================
  Widget _buildPieChartCard({required int completed, required int rejected}) {
    final total = completed + rejected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardColor, AppColors.cardColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.donut_large_rounded,
                size: 18,
                color: AppColors.accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                'نسبة إنجاز الخدمات',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  // الدائرة تترسم من 0 لغاية نهايتها مع تقدم الأنيميشن
                  final progress = Curves.easeOutCubic.transform(
                    _animController.value.clamp(0.0, 1.0),
                  );
                  return SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        completed: completed.toDouble(),
                        rejected: rejected.toDouble(),
                        completedColor: AppColors.accentColor,
                        rejectedColor: AppColors.errorColor,
                        progress: progress,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _AnimatedCounterText(
                              targetValue: total.toDouble(),
                              progress: progress,
                              decimals: 0,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'إجمالي',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(
                    color: AppColors.accentColor,
                    label: 'مكتملة ($completed)',
                    percent: total > 0 ? (completed / total) * 100 : 0,
                  ),
                  const SizedBox(height: 12),
                  _buildLegend(
                    color: AppColors.errorColor,
                    label: 'مرفوضة ($rejected)',
                    percent: total > 0 ? (rejected / total) * 100 : 0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({
    required Color color,
    required String label,
    required double percent,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label - ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final progress = Curves.easeOutCubic.transform(
              _animController.value.clamp(0.0, 1.0),
            );
            return _AnimatedCounterText(
              targetValue: percent,
              progress: progress,
              decimals: 1,
              suffix: '%',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // كارت إحصائية مفرد — رقم متحرك (Count-up) بدل رقم ثابت
  // ============================================================
  Widget _buildStatCard({
    required String title,
    double? numericValue,
    String? staticValue,
    String suffix = '',
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.10), AppColors.cardColor],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: staticValue != null
                ? Text(
                    staticValue,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final progress = Curves.easeOutCubic.transform(
                        _animController.value.clamp(0.0, 1.0),
                      );
                      return _AnimatedCounterText(
                        targetValue: numericValue ?? 0,
                        progress: progress,
                        decimals: (numericValue ?? 0) % 1 == 0 ? 0 : 1,
                        suffix: suffix,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Shimmer بسيط أثناء التحميل (بلا مكتبات خارجية)
  // ============================================================
  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerBox(height: 210, radius: 22),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: List.generate(4, (_) => _shimmerBox(radius: 20)),
        ),
      ],
    );
  }

  Widget _shimmerBox({double? height, required double radius}) {
    return _ShimmerEffect(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ============================================================
// عداد رقمي متحرك (Count-up) — بيوصل للرقم النهائي مع الأنيميشن
// ============================================================
class _AnimatedCounterText extends StatelessWidget {
  final double targetValue;
  final double progress; // 0.0 ⟶ 1.0
  final int decimals;
  final String suffix;
  final TextStyle style;

  const _AnimatedCounterText({
    required this.targetValue,
    required this.progress,
    required this.style,
    this.decimals = 0,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = targetValue * progress;
    final text = decimals == 0
        ? currentValue.round().toString()
        : currentValue.toStringAsFixed(decimals);

    return Text('$text$suffix', style: style);
  }
}

// ============================================================
// توهج زخرفي خافت بالخلفية
// ============================================================
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 100,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// تأثير Shimmer بسيط بلا مكتبات خارجية
// ============================================================
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.5 + _controller.value * 3, 0),
              end: Alignment(-0.5 + _controller.value * 3, 0),
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.05),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ============================================================
// رسم الدائرة البيانية (Pie Chart) — بترسم تدريجياً حسب progress
// ============================================================
class _PieChartPainter extends CustomPainter {
  final double completed;
  final double rejected;
  final Color completedColor;
  final Color rejectedColor;
  final double progress; // 0.0 ⟶ 1.0

  _PieChartPainter({
    required this.completed,
    required this.rejected,
    required this.completedColor,
    required this.rejectedColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = completed + rejected;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    // خلفية خافتة ثابتة (تدل على الدائرة الكاملة)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..color = Colors.grey.withOpacity(0.08),
    );

    if (total == 0) return;

    final completedSweepAngle = (completed / total) * 2 * math.pi * progress;
    final rejectedSweepAngle = (rejected / total) * 2 * math.pi * progress;

    // توهج خلف القوس (إحساس نيون خفيف)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    glowPaint.color = completedColor.withOpacity(0.35);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      completedSweepAngle,
      false,
      glowPaint,
    );

    glowPaint.color = rejectedColor.withOpacity(0.35);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + completedSweepAngle,
      rejectedSweepAngle,
      false,
      glowPaint,
    );

    // القوس الحاد بالمنتصف
    basePaint.color = completedColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      completedSweepAngle,
      false,
      basePaint,
    );

    basePaint.color = rejectedColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + completedSweepAngle,
      rejectedSweepAngle,
      false,
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.completed != completed ||
      oldDelegate.rejected != rejected;
}
