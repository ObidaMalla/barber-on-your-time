import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/businessCubit/get_staff_by_business_id_cubit.dart';
import '../../cubits/results_state.dart';
import '../../models/business/get_staff_by_business_id_model.dart';
import 'staff_free_slots_screen.dart';

class StaffSelectionScreen extends StatelessWidget {
  final GetStaffByBusinessIdCubit staffCubit;

  const StaffSelectionScreen({super.key, required this.staffCubit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.amber,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'اختر الحلاق',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          BlocBuilder<
            GetStaffByBusinessIdCubit,
            ResultState<GetStaffByBusinessIdModel>
          >(
            bloc: staffCubit,
            builder: (context, state) {
              return state.when(
                idle: () => const SizedBox.shrink(),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentColor,
                  ),
                ),
                error: (msg) => Center(
                  child: Text(
                    msg,
                    style: TextStyle(color: AppColors.errorColor),
                  ),
                ),
                success: (data) {
                  final staffList = data.data ?? [];
                  if (staffList.isEmpty) {
                    return Center(
                      child: Text(
                        'لا يوجد حلاقين متاحين حالياً',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.82,
                        ),
                    itemCount: staffList.length,
                    itemBuilder: (context, index) {
                      final staff = staffList[index];
                      final staffName = staff.user?.name ?? 'بدون اسم';

                      return _AnimatedStaffCard(
                        staffName: staffName,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StaffFreeSlotsScreen(
                                staffId: staff.id!,
                                staffName: staffName,
                              ),
                            ),
                          );
                        },
                      );
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
/// كرت اختيار الحلاق — حدود نيون متحركة بلا توقف + تصميم محسّن
/// ============================================================
class _AnimatedStaffCard extends StatefulWidget {
  final String staffName;
  final VoidCallback onTap;

  const _AnimatedStaffCard({required this.staffName, required this.onTap});

  @override
  State<_AnimatedStaffCard> createState() => _AnimatedStaffCardState();
}

class _AnimatedStaffCardState extends State<_AnimatedStaffCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // 🎨 لونين متدرجين للحدود المتوهجة (بنفسجي ⟶ سماوي)
  static const Color _glowColorA = Color(0xFF7C4DFF);
  static const Color _glowColorB = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // 👈 يلف للأبد بلا توقف
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _pulse(double t) {
    return 0.85 + (0.15 * (0.5 + 0.5 * (t < 0.5 ? t * 2 : (1 - t) * 2)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulseValue = _pulse(_controller.value);
        final blendedColor = Color.lerp(
          _glowColorA,
          _glowColorB,
          _controller.value,
        )!;

        return CustomPaint(
          foregroundPainter: _DualChasingBorderPainter(
            progress: _controller.value,
            colorA: _glowColorA,
            colorB: _glowColorB,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardColor,
                  AppColors.cardColor.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _glowColorA.withOpacity(0.15 * pulseValue),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✂️ دائرة الأيقونة مع نبضة توهج ناعمة
                      Transform.scale(
                        scale: pulseValue,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _glowColorA.withOpacity(0.18),
                                _glowColorB.withOpacity(0.12),
                              ],
                            ),
                            border: Border.all(
                              color: blendedColor.withOpacity(0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: blendedColor.withOpacity(0.35),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.content_cut_rounded,
                            size: 30,
                            color: blendedColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.staffName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // ⚡ زر عرض الأوقات بتدرج لوني
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _glowColorA.withOpacity(0.15),
                              _glowColorB.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _glowColorB.withOpacity(0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flash_on_rounded,
                              size: 13,
                              color: _glowColorB,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'عرض الأوقات',
                              style: TextStyle(
                                color: _glowColorB,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================
/// رسّام حدود متحركة بلا توقف، بتدرج لوني بين لونين
/// ============================================================
class _DualChasingBorderPainter extends CustomPainter {
  final double progress; // 0.0 ⟶ 1.0، بيتكرر للأبد
  final Color colorA;
  final Color colorB;
  final double radius;
  final double strokeWidth;

  _DualChasingBorderPainter({
    required this.progress,
    required this.colorA,
    required this.colorB,
    this.radius = 24,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    final blendedColor = Color.lerp(colorA, colorB, progress)!;

    canvas.drawPath(
      path,
      Paint()
        ..color = blendedColor.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final metric = path.computeMetrics().first;
    final segmentLength = metric.length * 0.28;
    final start = metric.length * progress;
    final end = start + segmentLength;

    Path segment;
    if (end <= metric.length) {
      segment = metric.extractPath(start, end);
    } else {
      segment = metric.extractPath(start, metric.length);
      segment.addPath(metric.extractPath(0, end - metric.length), Offset.zero);
    }

    canvas.drawPath(
      segment,
      Paint()
        ..color = blendedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 3.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    canvas.drawPath(
      segment,
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DualChasingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
