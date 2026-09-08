import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/results_state.dart';
import '../../../cubits/staffInviteCubit/staff_invite_cubit.dart';
import '../../../models/staffInvite/staff_invite_model.dart';

// ----------------------------------------------------
// 💡 CustomPainter لرسم مسار الليد المتحرك على الحواف
// ----------------------------------------------------
class LedPathBorderPainter extends CustomPainter {
  final double animationValue;
  final Color glowColor;
  final double borderRadius;
  final double strokeWidth;

  LedPathBorderPainter({
    required this.animationValue,
    required this.glowColor,
    this.borderRadius = 26.0,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final basePaint = Paint()
      ..color = glowColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, basePaint);

    final double rotationAngle = animationValue * 2 * math.pi;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          glowColor.withOpacity(0.0),
          glowColor,
          glowColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.25, 0.5],
        transform: GradientRotation(rotationAngle),
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant LedPathBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.glowColor != glowColor;
  }
}

// ----------------------------------------------------
// 💡 الودجت المغلفة للتأثير المساري
// ----------------------------------------------------
class LedPathContainer extends StatelessWidget {
  final Widget child;
  final AnimationController animationController;
  final Color glowColor;
  final double borderRadius;

  const LedPathContainer({
    super.key,
    required this.child,
    required this.animationController,
    required this.glowColor,
    this.borderRadius = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return CustomPaint(
          foregroundPainter: LedPathBorderPainter(
            animationValue: animationController.value,
            glowColor: glowColor,
            borderRadius: borderRadius,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// 📱 شاشة دعوة الموظفين
// ----------------------------------------------------
class StaffInviteScreen extends StatefulWidget {
  const StaffInviteScreen({super.key});

  @override
  State<StaffInviteScreen> createState() => _StaffInviteScreenState();
}

class _StaffInviteScreenState extends State<StaffInviteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ledPathController;

  @override
  void initState() {
    super.initState();
    _ledPathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _ledPathController.dispose();
    super.dispose();
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ الكود! 🎉'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            'دعوة موظف جديد',
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        body: Stack(
          children: [
            // ✂️ خلفية أدوات الحلاقة (Barber Pattern Background)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15, // وضوح متناسق مع باقي الشاشات
                child: Wrap(
                  spacing: 35,
                  runSpacing: 40,
                  alignment: WrapAlignment.spaceAround,
                  children: List.generate(40, (index) {
                    final icons = [
                      Icons.content_cut_rounded, // مقص
                      Icons.brush_rounded, // فرشاة
                      Icons.face_rounded, // لحية/وجه
                      Icons.dry_cleaning_rounded, // أدوات
                    ];
                    return Transform.rotate(
                      angle: (index % 3 == 0) ? 0.3 : -0.4,
                      child: Icon(
                        icons[index % icons.length],
                        size: 46,
                        color: AppColors.accentColor,
                      ),
                    );
                  }),
                ),
              ),
            ),

            // المحتوى الرئيسي
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // كرت رأس الصفحة المؤطر بمسار الليد
                    LedPathContainer(
                      animationController: _ledPathController,
                      glowColor: AppColors.accentColor,
                      borderRadius: 26,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentColor.withOpacity(0.12),
                                border: Border.all(
                                  color: AppColors.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.card_giftcard_rounded,
                                color: AppColors.accentColor,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'رمز انضمام الموظف',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ولّد كود دعوة وشاركه مع الحلاق حتى ينضم لمحلك بكل سهولة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // منطقة توليد الكود والزر
                    Expanded(
                      child:
                          BlocConsumer<
                            StaffInviteCubit,
                            ResultState<StaffInviteModel>
                          >(
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
                              final isLoading = state.maybeWhen(
                                loading: () => true,
                                orElse: () => false,
                              );
                              final code = state.maybeWhen(
                                success: (r) => r.data?.code,
                                orElse: () => null,
                              );

                              return Column(
                                children: [
                                  if (code != null) ...[
                                    GestureDetector(
                                      onTap: () => _copyCode(context, code),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.accentColor
                                                .withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accentColor
                                                  .withOpacity(0.1),
                                              blurRadius: 15,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              code,
                                              style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 6,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.copy_rounded,
                                                  size: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'اضغط للنسخ',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  const Spacer(),

                                  // ✨ زر مفرغ الخلفية (Outlined Button)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: OutlinedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => context
                                                .read<StaffInviteCubit>()
                                                .generateInvite(),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: AppColors.accentColor,
                                          width: 1.8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        foregroundColor: AppColors.accentColor,
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: AppColors.accentColor,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Text(
                                              code == null
                                                  ? 'توليد كود'
                                                  : 'توليد كود جديد',
                                              style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
