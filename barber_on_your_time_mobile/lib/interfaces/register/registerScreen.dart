import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/registerCubit/register_cubit.dart';
import '../../cubits/results_state.dart';
import '../../models/register/register_model.dart';
import '../login/loginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  late final AnimationController _ledController;
  final GlobalKey<_AnimatedSubmitButtonState> _buttonKey = GlobalKey();

  // اللون الأصفر المطلوب
  static const Color accentColor = Color(0xFFE1FF20);

  @override
  void initState() {
    super.initState();
    _ledController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _ledController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // REGISTER
  void _submitRegister(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _buttonKey.currentState?.shakeAndFlash();
      return;
    }
    context.read<RegisterCubit>().registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  // SNACKBAR
  void _showFloatingSnackBar(String message, {required bool isSuccess}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isSuccess
              ? AppColors.successColor
              : AppColors.dangerColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<RegisterCubit, ResultState<RegisterModel>>(
          // LISTENER
          listener: (context, state) {
            state.whenOrNull(
              success: (userData) async {
                if (userData.success != true) {
                  _showFloatingSnackBar(
                    userData.message ?? 'فشلت عملية إنشاء الحساب',
                    isSuccess: false,
                  );
                  _buttonKey.currentState?.shakeAndFlash();
                  return;
                }
                _showFloatingSnackBar(
                  userData.message ?? 'تم إنشاء الحساب بنجاح 🚀',
                  isSuccess: true,
                );
                await Future.delayed(const Duration(milliseconds: 900));
                if (!mounted) return;
                Navigator.pop(context);
              },
              // ERROR
              error: (error) {
                debugPrint('❌ [RegisterScreen] $error');
                _showFloatingSnackBar(error, isSuccess: false);
                _buttonKey.currentState?.shakeAndFlash();
              },
            );
          },
          // BUILDER
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            return SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 56,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const Spacer(),
                              // LOGO
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.cardColor,
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.18),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accentColor,
                                        accentColor.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.content_cut_rounded,
                                    color: AppColors.backgroundColor,
                                    size: 42,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // TITLE
                              Text(
                                'إنشاء حساب جديد',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'سجل لتبدأ استخدام تطبيقنا',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 34),

                              // REGISTER CARD WITH BORDER BEAM
                              AnimatedBuilder(
                                animation: _ledController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: _BorderBeamPainter(
                                      animationValue: _ledController.value,
                                      color: accentColor,
                                      borderRadius: 24.0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.30),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // NAME
                                        Text(
                                          'الاسم الكامل',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 9),
                                        TextFormField(
                                          controller: _nameController,
                                          textInputAction: TextInputAction.next,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                          cursorColor: accentColor,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'يرجى إدخال الاسم الكامل';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'أدخل اسمك الكامل',
                                            hintStyle: TextStyle(
                                              color: AppColors.hintColor,
                                              fontSize: 14,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.person_outline,
                                              color: AppColors.textSecondary,
                                              size: 21,
                                            ),
                                            filled: true,
                                            fillColor: AppColors.inputColor,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 17,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: accentColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.errorColor,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  borderSide: BorderSide(
                                                    color: AppColors.errorColor,
                                                    width: 1.5,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // EMAIL
                                        Text(
                                          'البريد الإلكتروني',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 9),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                          cursorColor: accentColor,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'يرجى إدخال البريد الإلكتروني';
                                            }
                                            if (!RegExp(
                                              r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                                            ).hasMatch(value.trim())) {
                                              return 'يرجى إدخال بريد إلكتروني صالح';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'أدخل بريدك الإلكتروني',
                                            hintStyle: TextStyle(
                                              color: AppColors.hintColor,
                                              fontSize: 14,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                              color: AppColors.textSecondary,
                                              size: 21,
                                            ),
                                            filled: true,
                                            fillColor: AppColors.inputColor,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 17,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: accentColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.errorColor,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  borderSide: BorderSide(
                                                    color: AppColors.errorColor,
                                                    width: 1.5,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // PASSWORD
                                        Text(
                                          'كلمة المرور',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 9),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _isPasswordObscured,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) {
                                            if (!isLoading) {
                                              _submitRegister(context);
                                            }
                                          },
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                          cursorColor: accentColor,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'يرجى إدخال كلمة المرور';
                                            }
                                            if (value.length < 6) {
                                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'أدخل كلمة المرور',
                                            hintStyle: TextStyle(
                                              color: AppColors.hintColor,
                                              fontSize: 14,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              color: AppColors.textSecondary,
                                              size: 21,
                                            ),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordObscured =
                                                      !_isPasswordObscured;
                                                });
                                              },
                                              icon: Icon(
                                                _isPasswordObscured
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AppColors.textSecondary,
                                                size: 21,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: AppColors.inputColor,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 17,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: accentColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: AppColors.errorColor,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  borderSide: BorderSide(
                                                    color: AppColors.errorColor,
                                                    width: 1.5,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        // REGISTER BUTTON (OUTLINED & SHAKING)
                                        _AnimatedSubmitButton(
                                          key: _buttonKey,
                                          isLoading: isLoading,
                                          label: 'إنشاء حساب',
                                          accentColor: AppColors.accentColor,
                                          onPressed: () =>
                                              _submitRegister(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              // LOGIN LINK
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'لديك حساب بالفعل؟ ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          },
                                    child: Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // FOOTER
                              Text(
                                'BARBER ON YOUR TIME',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.footerColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// كلاس رسم مسار الضوء المتحرك (Border Beam)
class _BorderBeamPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double borderRadius;

  _BorderBeamPainter({
    required this.animationValue,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // إطار خافت وثابت للخلفية
    final basePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rRect, basePaint);

    // مسار الضوء المتحرك
    final path = Path()..addRRect(rRect);
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final length = metric.length;

    const beamLength = 150.0;
    final currentPosition = animationValue * length;

    final extractPath = metric.extractPath(
      currentPosition,
      (currentPosition + beamLength) % length,
    );

    final paint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.transparent, color, Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (currentPosition + beamLength > length) {
      final extraPath = metric.extractPath(
        0.0,
        (currentPosition + beamLength) % length,
      );
      canvas.drawPath(extraPath, paint);
    }

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BorderBeamPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}

// زر إنشاء الحساب المفرغ الذي يهتز عمودياً ويومض
class _AnimatedSubmitButton extends StatefulWidget {
  final bool isLoading;
  final String label;
  final Color accentColor;
  final VoidCallback onPressed;

  const _AnimatedSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  State<_AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<_AnimatedSubmitButton>
    with TickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _shakeController;
  late final AnimationController _flashController;
  late final Animation<Color?> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = ColorTween(
      begin: widget.accentColor,
      end: AppColors.errorColor,
    ).animate(_flashController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void shakeAndFlash() {
    _shakeController.forward(from: 0.0);
    _flashController.forward().then((_) {
      _flashController.reverse();
    });
  }

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeController, _flashController]),
      builder: (context, child) {
        final sineValue =
            math.sin(_shakeController.value * 4 * math.pi) *
            (_shakeController.value < 1.0
                ? (1.0 - _shakeController.value) * 12.0
                : 0.0);

        final currentColor = _flashAnimation.value ?? widget.accentColor;

        return Transform.translate(
          offset: Offset(sineValue, 0),
          child: GestureDetector(
            onTapDown: widget.isLoading ? null : (_) => _setScale(0.96),
            onTapUp: widget.isLoading ? null : (_) => _setScale(1.0),
            onTapCancel: widget.isLoading ? null : () => _setScale(1.0),
            onTap: widget.isLoading ? null : widget.onPressed,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: currentColor, width: 2),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: currentColor,
                          ),
                        )
                      : Text(
                          widget.label,
                          key: const ValueKey('label'),
                          style: TextStyle(
                            color: currentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
