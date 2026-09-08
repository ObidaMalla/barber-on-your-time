import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/businessCubit/business_cubit.dart';
import '../../cubits/joinBusinessCubit/join_business_cubit.dart';
import '../../cubits/results_state.dart';
import '../../models/CreateBusiness/business_model.dart';
import '../../models/joinBusiness/join_business_model.dart';
import '../mainScreen.dart';

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
// 📱 الشاشة الرئيسية
// ----------------------------------------------------
class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _ledPathController;
  double _pageFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _pageFraction = _pageController.page ?? 0.0;
      });
    });

    _ledPathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ledPathController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
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
            'ابدأ رحلتك',
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            // ✂️ خلفية أدوات الحلاقة (تم زيادة الوضوح والشفافية)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15, // رفع الشفافية لتكون واضحة وممتازة Visual Impact
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
                        size: 46, // تكبير الأيقونات لتبدو أوضح
                        color: AppColors.accentColor,
                      ),
                    );
                  }),
                ),
              ),
            ),

            // المحتوى الرئيسي
            Column(
              children: [
                // شريط التبويبات المتزامن مع السحب
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _SegmentedTabs(
                    pageFraction: _pageFraction,
                    onTabTap: _goToPage,
                  ),
                ),

                // المحتوى
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _CreateBusinessForm(
                        ledAnimationController: _ledPathController,
                      ),
                      _JoinBusinessForm(
                        ledAnimationController: _ledPathController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// شريط التبويبات الثابت - Segmented Control بمؤشر متحرك
// =========================================================
class _SegmentedTabs extends StatelessWidget {
  final double pageFraction;
  final ValueChanged<int> onTabTap;

  const _SegmentedTabs({required this.pageFraction, required this.onTabTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / 2;
        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: Duration.zero,
                right: pageFraction.clamp(0.0, 1.0) * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _tabLabel(
                      label: 'إنشاء محل',
                      icon: Icons.storefront_rounded,
                      index: 0,
                    ),
                  ),
                  Expanded(
                    child: _tabLabel(
                      label: 'انضمام كموظف',
                      icon: Icons.badge_rounded,
                      index: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabLabel({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isActive = (pageFraction.round() == index);
    return GestureDetector(
      onTap: () => onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? AppColors.backgroundColor
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.backgroundColor
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// فورم إنشاء محل
// =========================================================
class _CreateBusinessForm extends StatefulWidget {
  final AnimationController ledAnimationController;

  const _CreateBusinessForm({required this.ledAnimationController});

  @override
  State<_CreateBusinessForm> createState() => _CreateBusinessFormState();
}

class _CreateBusinessFormState extends State<_CreateBusinessForm>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<CreateBusinessCubit, ResultState<CreateBusinessModel>>(
      listener: (context, state) {
        state.whenOrNull(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data.message ?? 'تم إنشاء المحل بنجاح 🎉'),
                backgroundColor: AppColors.successColor,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(userRole: 'OWNER'),
              ),
              (route) => false,
            );
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

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LedPathContainer(
                  animationController: widget.ledAnimationController,
                  glowColor: AppColors.accentColor,
                  borderRadius: 26,
                  child: _buildHeaderCard(
                    icon: Icons.add_business_rounded,
                    title: 'إنشاء محل جديد',
                    subtitle:
                        'قم بإدخال تفاصيل صالونك للانتقال إلى حساب OWNER وإدارة المواعيد',
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'بيانات المحل',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'اسم المحل',
                  hint: 'مثال: صالون الحلاقة الذهبي',
                  icon: Icons.storefront_rounded,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'يرجى إدخال اسم المحل'
                      : null,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _addressController,
                  label: 'العنوان',
                  hint: 'مثال: دمشق - الصالحية',
                  icon: Icons.location_on_rounded,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'يرجى إدخال العنوان'
                      : null,
                ),
                const SizedBox(height: 36),
                _buildOutlinedSubmitButton(
                  isLoading: isLoading,
                  label: 'إنشاء المحل',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<CreateBusinessCubit>().createBusiness(
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================
// فورم الانضمام بكود دعوة
// =========================================================
class _JoinBusinessForm extends StatefulWidget {
  final AnimationController ledAnimationController;

  const _JoinBusinessForm({required this.ledAnimationController});

  @override
  State<_JoinBusinessForm> createState() => _JoinBusinessFormState();
}

class _JoinBusinessFormState extends State<_JoinBusinessForm>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<JoinBusinessCubit, ResultState<JoinBusinessModel>>(
      listener: (context, state) {
        state.whenOrNull(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data.message ?? 'تم الانضمام بنجاح 🎉'),
                backgroundColor: AppColors.successColor,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(userRole: 'STAFF'),
              ),
              (route) => false,
            );
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

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LedPathContainer(
                  animationController: widget.ledAnimationController,
                  glowColor: AppColors.accentColor,
                  borderRadius: 26,
                  child: _buildHeaderCard(
                    icon: Icons.badge_rounded,
                    title: 'انضم كموظف',
                    subtitle:
                        'أدخل كود الدعوة يلي أعطاك ياه صاحب المحل للانتقال إلى حساب STAFF',
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'كود الدعوة',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _codeController,
                  label: 'الكود',
                  hint: 'مثال: A3F92B1C',
                  icon: Icons.qr_code_rounded,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'يرجى إدخال الكود' : null,
                ),
                const SizedBox(height: 36),
                _buildOutlinedSubmitButton(
                  isLoading: isLoading,
                  label: 'انضمام',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<JoinBusinessCubit>().joinBusiness(
                        code: _codeController.text.trim(),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================
// عناصر مشتركة بين الفورمين
// =========================================================
Widget _buildHeaderCard({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
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
            border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
          ),
          child: Icon(icon, color: AppColors.accentColor, size: 34),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  TextCapitalization textCapitalization = TextCapitalization.none,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    textCapitalization: textCapitalization,
    style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.4),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.accentColor, size: 20),
      filled: true,
      fillColor: AppColors.inputColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );
}

Widget _buildOutlinedSubmitButton({
  required bool isLoading,
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.accentColor, width: 1.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
              label,
              style: TextStyle(
                color: AppColors.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}
