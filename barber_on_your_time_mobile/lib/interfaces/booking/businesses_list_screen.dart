import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/businessCubit/get_all_businesses_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/business/get_all_businesses_model.dart';
import 'create_booking_screen.dart';

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
    this.borderRadius = 20.0,
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
  final bool isSelected;
  final AnimationController animationController;
  final Color glowColor;
  final double borderRadius;

  const LedPathContainer({
    super.key,
    required this.child,
    required this.isSelected,
    required this.animationController,
    required this.glowColor,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: child,
      );
    }

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
// 📱 شاشة عرض الصالونات
// ----------------------------------------------------
class BusinessesListScreen extends StatefulWidget {
  const BusinessesListScreen({super.key});

  @override
  State<BusinessesListScreen> createState() => _BusinessesListScreenState();
}

class _BusinessesListScreenState extends State<BusinessesListScreen>
    with SingleTickerProviderStateMixin {
  late final GetAllBusinessesCubit _businessesCubit;
  late final AnimationController _ledPathController;

  @override
  void initState() {
    super.initState();
    _businessesCubit = getIt<GetAllBusinessesCubit>();
    _businessesCubit.getAllBusinesses();

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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
            'اختر صالونك',
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child:
              BlocConsumer<
                GetAllBusinessesCubit,
                ResultState<GetAllBusinessesModel>
              >(
                bloc: _businessesCubit,
                listener: (context, state) {
                  state.whenOrNull(
                    error: (message) =>
                        _showSnackBar(message, AppColors.errorColor),
                  );
                },
                builder: (context, state) {
                  return state.when(
                    idle: () => const SizedBox.shrink(),
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                      ),
                    ),
                    error: (message) => Center(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: AppColors.errorColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    success: (data) {
                      final businesses = data.data ?? [];
                      if (businesses.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد صالونات متاحة حالياً',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.accentColor,
                        onRefresh: () async =>
                            _businessesCubit.getAllBusinesses(),
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          itemCount: businesses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final business = businesses[index];
                            return _buildBusinessCard(context, business);
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

  Widget _buildBusinessCard(BuildContext context, BusinessData business) {
    final businessName = business.name ?? 'بدون اسم';
    final ownerName = business.owner?.name ?? 'غير معروف';

    return LedPathContainer(
      isSelected: true,
      animationController: _ledPathController,
      glowColor: AppColors.accentColor,
      borderRadius: 20,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (business.id == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateBookingScreen(businessId: business.id!),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: AppColors.accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppColors
                                .accentColor, // ✨ تم إضافة لون Accent هنا
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.address ?? 'العنوان غير موضح',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: AppColors
                                .accentColor, // ✨ تم إضافة لون Accent هنا
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'المالك: $ownerName',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.accentColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
