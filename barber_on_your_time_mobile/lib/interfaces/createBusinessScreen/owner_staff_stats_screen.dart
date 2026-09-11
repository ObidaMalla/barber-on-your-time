import 'dart:math' as math;

import 'package:barber_on_your_time/core/color/colors.dart';
import 'package:barber_on_your_time/cubits/bookingCubit/owner_staff_stats_cubit.dart';
import 'package:barber_on_your_time/cubits/results_state.dart';
import 'package:barber_on_your_time/main.dart';
import 'package:barber_on_your_time/models/booking/ownerStaffStats/owner_staff_stats_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerStaffStatsScreen extends StatefulWidget {
  final int staffId;
  final String staffName;

  const OwnerStaffStatsScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<OwnerStaffStatsScreen> createState() => _OwnerStaffStatsScreenState();
}

class _OwnerStaffStatsScreenState extends State<OwnerStaffStatsScreen>
    with TickerProviderStateMixin {
  late final OwnerStaffStatsCubit _cubit;

  // إينيميشن الدخول (الكروت تنزلق وتظهر)
  late final AnimationController _entranceController;
  // إينيميشن مستمر بلا توقف (خلفية متوهجة تتحرك)
  late final AnimationController _ambientController;
  // إينيميشن حلقة الدوران حوالين الرسم البياني
  late final AnimationController _ringController;
  // نبضة خفيفة مستمرة على الكروت
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<OwnerStaffStatsCubit>();
    _cubit.getStaffStatisticsForOwner(widget.staffId);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cubit.close();
    _entranceController.dispose();
    _ambientController.dispose();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'إحصائيات ${widget.staffName}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              shadows: [
                Shadow(
                  color: AppColors.accentColor.withOpacity(0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // 🌌 خلفية متحركة بلا توقف — دوائر متوهجة تتنفس وتتحرك
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                final t = _ambientController.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + (30 * math.sin(t * 2 * math.pi)),
                      right: -80 + (20 * math.cos(t * 2 * math.pi)),
                      child: _GlowOrb(
                        color: AppColors.accentColor,
                        size: 260,
                        opacity: 0.09 + 0.04 * math.sin(t * 2 * math.pi),
                      ),
                    ),
                    Positioned(
                      bottom: -80 + (25 * math.cos(t * 2 * math.pi)),
                      left: -90 + (25 * math.sin(t * 2 * math.pi)),
                      child: _GlowOrb(
                        color: Colors.redAccent,
                        size: 240,
                        opacity: 0.07 + 0.04 * math.cos(t * 2 * math.pi),
                      ),
                    ),
                    Positioned(
                      top: 260 + (15 * math.sin(t * 2 * math.pi + 1)),
                      left: 40 + (15 * math.cos(t * 2 * math.pi + 1)),
                      child: _GlowOrb(
                        color: const Color(0xFFFFD700),
                        size: 140,
                        opacity: 0.05,
                      ),
                    ),
                  ],
                );
              },
            ),

            BlocConsumer<
              OwnerStaffStatsCubit,
              ResultState<OwnerStaffStatsModel>
            >(
              bloc: _cubit,
              listener: (context, state) {
                state.whenOrNull(
                  success: (_) => _entranceController.forward(from: 0.0),
                  error: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  idle: () => const SizedBox.shrink(),
                  loading: () => _buildLoadingShimmer(),
                  error: (msg) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          msg,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              _cubit.getStaffStatisticsForOwner(widget.staffId),
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
                      onRefresh: () async =>
                          _cubit.getStaffStatisticsForOwner(widget.staffId),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          MediaQuery.of(context).padding.top +
                              kToolbarHeight +
                              12,
                          16,
                          24,
                        ),
                        children: [
                          _buildEntranceItem(
                            index: 0,
                            child: _buildStaffBadge(),
                          ),
                          const SizedBox(height: 18),
                          _buildEntranceItem(
                            index: 1,
                            child: _buildPieChartCard(
                              completed: totalCompleted,
                              rejected: totalRejected,
                            ),
                          ),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.1,
                            children: [
                              _buildEntranceItem(
                                index: 2,
                                child: _buildStatCard(
                                  title: 'أرباح الأسبوع',
                                  numericValue: revenue,
                                  suffix: ' ل.س',
                                  icon: Icons.monetization_on_rounded,
                                  color: const Color(0xFF00E676),
                                ),
                              ),
                              _buildEntranceItem(
                                index: 3,
                                child: _buildStatCard(
                                  title: 'ساعات العمل',
                                  staticValue: formattedTime,
                                  icon: Icons.access_time_filled_rounded,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                              _buildEntranceItem(
                                index: 4,
                                child: _buildStatCard(
                                  title: 'خدمات مكتملة',
                                  numericValue: totalCompleted.toDouble(),
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.accentColor,
                                ),
                              ),
                              _buildEntranceItem(
                                index: 5,
                                child: _buildStatCard(
                                  title: 'خدمات مرفوضة',
                                  numericValue: totalRejected.toDouble(),
                                  icon: Icons.cancel_rounded,
                                  color: Colors.redAccent,
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
  // دخول العناصر — تكبير + انزلاق + شفافية، بتتابع (Stagger)
  // ============================================================
  Widget _buildEntranceItem({required int index, required Widget child}) {
    final double start = (index * 0.1).clamp(0.0, 0.6);
    final double end = (start + 0.5).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Transform.scale(
            scale: 0.85 + (0.15 * value),
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
      child: child,
    );
  }

  // ============================================================
  // بطاقة اسم الحلاق بأعلى الصفحة — بتوهج نابض مستمر
  // ============================================================
  Widget _buildStaffBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = 0.6 + (_pulseController.value * 0.4);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentColor.withOpacity(0.18),
                AppColors.cardColor,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentColor.withOpacity(0.35 * pulse),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentColor.withOpacity(0.18 * pulse),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentColor,
                      AppColors.accentColor.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentColor.withOpacity(0.4 * pulse),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.staffName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'تقرير الأداء الأسبوعي',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // كارت الرسم البياني الدائري — بحلقة دوارة بلا توقف حوالينه
  // ============================================================
  Widget _buildPieChartCard({required int completed, required int rejected}) {
    final total = completed + rejected;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardColor, AppColors.cardColor.withOpacity(0.65)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
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
                size: 20,
                color: AppColors.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'نسبة إنجاز الخدمات',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _entranceController,
                  _ringController,
                ]),
                builder: (context, child) {
                  final progress = Curves.easeOutCubic.transform(
                    _entranceController.value.clamp(0.0, 1.0),
                  );
                  return SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // حلقة دوارة زخرفية بلا توقف، حوالين الدائرة الأساسية
                        Transform.rotate(
                          angle: _ringController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(130, 130),
                            painter: _OrbitDotsPainter(
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 104,
                          height: 104,
                          child: CustomPaint(
                            painter: _PieChartPainter(
                              completed: completed.toDouble(),
                              rejected: rejected.toDouble(),
                              completedColor: AppColors.accentColor,
                              rejectedColor: Colors.redAccent,
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
                                      fontSize: 22,
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
                        ),
                      ],
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
                  const SizedBox(height: 14),
                  _buildLegend(
                    color: Colors.redAccent,
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
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.5 + (_pulseController.value * 0.5);
        return Row(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.7 * glow),
                    blurRadius: 8,
                    spreadRadius: 2,
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
              animation: _entranceController,
              builder: (context, child) {
                final progress = Curves.easeOutCubic.transform(
                  _entranceController.value.clamp(0.0, 1.0),
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
      },
    );
  }

  // ============================================================
  // كارت إحصائية — نابض بلطف بشكل مستمر + توهج
  // ============================================================
  Widget _buildStatCard({
    required String title,
    double? numericValue,
    String? staticValue,
    String suffix = '',
    required IconData icon,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.5 + (_pulseController.value * 0.5);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.14), AppColors.cardColor],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15 * glow),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.18),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35 * glow),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              if (numericValue != null)
                AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    final progress = Curves.easeOutCubic.transform(
                      _entranceController.value.clamp(0.0, 1.0),
                    );
                    return _AnimatedCounterText(
                      targetValue: numericValue,
                      progress: progress,
                      suffix: suffix,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    );
                  },
                )
              else
                Text(
                  staticValue ?? '',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // Shimmer بسيط أثناء التحميل
  // ============================================================
  Widget _buildLoadingShimmer() {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + kToolbarHeight + 12,
        16,
        24,
      ),
      children: [
        _shimmerBox(height: 70, radius: 20),
        const SizedBox(height: 18),
        _shimmerBox(height: 220, radius: 26),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: List.generate(4, (_) => _shimmerBox(radius: 22)),
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
// توهج زخرفي — الآن بشفافية متغيرة (يتنفس مع الوقت)
// ============================================================
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowOrb({
    required this.color,
    required this.size,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity * 0.6),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: 90,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// نقاط تدور حوالين الرسم البياني بلا توقف (زخرفة مدارية)
// ============================================================
class _OrbitDotsPainter extends CustomPainter {
  final Color color;
  _OrbitDotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const dotCount = 3;

    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * math.pi / dotCount) * i;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final paint = Paint()
        ..color = color.withOpacity(0.7 - (i * 0.15))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(dotCenter, 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitDotsPainter oldDelegate) => false;
}

// ============================================================
// عداد رقمي متحرك (Count-up)
// ============================================================
class _AnimatedCounterText extends StatelessWidget {
  final double targetValue;
  final double progress;
  final int decimals;
  final String suffix;
  final TextStyle style;

  const _AnimatedCounterText({
    required this.targetValue,
    required this.progress,
    this.decimals = 0,
    this.suffix = '',
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = targetValue * progress;
    final formatted = currentValue.toStringAsFixed(decimals);
    return Text('$formatted$suffix', style: style);
  }
}

// ============================================================
// Shimmer بسيط بلا مكتبات خارجية
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
// رسم الدائرة البيانية — بترسم تدريجياً
// ============================================================
class _PieChartPainter extends CustomPainter {
  final double completed;
  final double rejected;
  final Color completedColor;
  final Color rejectedColor;
  final double progress;

  _PieChartPainter({
    required this.completed,
    required this.rejected,
    required this.completedColor,
    required this.rejectedColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 13.0;
    final total = completed + rejected;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (total == 0 || progress <= 0) return;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final completedAngle = (completed / total) * 2 * math.pi * progress;
    final rejectedAngle = (rejected / total) * 2 * math.pi * progress;

    const startAngle = -math.pi / 2;

    // توهج خلف القوس
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    if (completed > 0) {
      glowPaint.color = completedColor.withOpacity(0.4);
      canvas.drawArc(rect, startAngle, completedAngle, false, glowPaint);
    }
    if (rejected > 0) {
      glowPaint.color = rejectedColor.withOpacity(0.4);
      canvas.drawArc(
        rect,
        startAngle + completedAngle,
        rejectedAngle,
        false,
        glowPaint,
      );
    }

    final completedPaint = Paint()
      ..color = completedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rejectedPaint = Paint()
      ..color = rejectedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (completed > 0) {
      canvas.drawArc(rect, startAngle, completedAngle, false, completedPaint);
    }
    if (rejected > 0) {
      canvas.drawArc(
        rect,
        startAngle + completedAngle,
        rejectedAngle,
        false,
        rejectedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.completed != completed ||
        oldDelegate.rejected != rejected;
  }
}
