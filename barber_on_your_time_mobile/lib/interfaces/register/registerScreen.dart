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
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 24),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.errorColor, width: 2),
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
              error: (error) {
                debugPrint('❌ [RegisterScreen] $error');
                _showFloatingSnackBar(error, isSuccess: false);
                _buttonKey.currentState?.shakeAndFlash();
              },
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.6),
                        radius: 1.2,
                        colors: [
                          accentColor.withOpacity(0.12),
                          AppColors.backgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          // LOGO
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cardColor,
                              border: Border.all(
                                color: accentColor.withOpacity(0.35),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.18),
                                  blurRadius: 24,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(10),
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
                                size: 46,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // TITLE
                          Text(
                            'إنشاء حساب جديد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // REGISTER CARD WITH BORDER BEAM
                          AnimatedBuilder(
                            animation: _ledController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _BorderBeamPainter(
                                  animationValue: _ledController.value,
                                  color: accentColor,
                                  borderRadius: 28.0,
                                ),
                                child: child,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.30),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _nameController,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                      ),
                                      cursorColor: accentColor,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'يرجى إدخال الاسم الكامل';
                                        }
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        hint: 'أدخل اسمك الكامل',
                                        icon: Icons.person_outline,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // EMAIL
                                    Text(
                                      'البريد الإلكتروني',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
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
                                      decoration: _inputDecoration(
                                        hint: 'أدخل بريدك الإلكتروني',
                                        icon: Icons.email_outlined,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // PASSWORD
                                    Text(
                                      'كلمة المرور',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                                        fontSize: 16,
                                      ),
                                      cursorColor: accentColor,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'يرجى إدخال كلمة المرور';
                                        }
                                        if (value.length < 6) {
                                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                        }
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        hint: 'أدخل كلمة المرور',
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordObscured =
                                              !_isPasswordObscured;
                                            });
                                          },
                                          icon: Icon(
                                            _isPasswordObscured
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.textSecondary,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    // REGISTER BUTTON
                                    _AnimatedSubmitButton(
                                      key: _buttonKey,
                                      isLoading: isLoading,
                                      label: 'إنشاء حساب',
                                      accentColor: AppColors.accentColor,
                                      onPressed: () => _submitRegister(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // LOGIN LINK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'لديك حساب بالفعل؟ ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
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
                                    fontSize: 15,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- Animated Submit Button & Border Beam Classes ---

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animOffset = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shakeAndFlash() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animOffset,
      builder: (context, child) {
        final sinVal = math.sin(_animOffset.value * math.pi * 2);
        return Transform.translate(offset: Offset(sinVal * 6, 0), child: child);
      },
      child: SizedBox(
        height: 58,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accentColor,
            foregroundColor: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: widget.isLoading
              ? SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.backgroundColor,
            ),
          )
              : Text(
            widget.label,
            style: TextStyle(
              color: AppColors.backgroundColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

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
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()..addRRect(rrect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BorderBeamPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}