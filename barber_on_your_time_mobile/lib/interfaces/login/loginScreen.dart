import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/loginCubit/login_cubit.dart';
import '../../cubits/results_state.dart';
import '../../models/login/login_model.dart';
import '../mainScreen.dart';
import '../register/registerScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  late final AnimationController _entryController;
  late final Animation<double> _logoScale;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );

    _cardFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(
    BuildContext context,
    GlobalKey<_AnimatedSubmitButtonState> buttonKey,
  ) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      buttonKey.currentState?.shakeAndFlash();
      return;
    }
    context.read<LoginCubit>().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

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
              : AppColors.errorColor,
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

  @override
  Widget build(BuildContext context) {
    final GlobalKey<_AnimatedSubmitButtonState> buttonKey = GlobalKey();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<LoginCubit, ResultState<LoginModel>>(
          listener: (context, state) {
            state.whenOrNull(
              success: (userData) async {
                if (userData.success != true) {
                  _showFloatingSnackBar(
                    userData.message ?? 'فشلت عملية تسجيل الدخول',
                    isSuccess: false,
                  );
                  buttonKey.currentState?.shakeAndFlash();
                  return;
                }
                _showFloatingSnackBar(
                  userData.message ?? 'تم تسجيل الدخول بنجاح 🚀',
                  isSuccess: true,
                );
                await Future.delayed(const Duration(milliseconds: 700));
                if (!mounted) return;

                final role = userData.data?.user?.role ?? 'CUSTOMER';

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreen(userRole: role)),
                  (route) => false,
                );
              },
              error: (error) {
                _showFloatingSnackBar(error, isSuccess: false);
                buttonKey.currentState?.shakeAndFlash();
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
                          AppColors.accentColor.withOpacity(0.12),
                          AppColors.backgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
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
                          ScaleTransition(
                            scale: _logoScale,
                            child: const _AnimatedLogo(),
                          ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _cardFade,
                            child: SlideTransition(
                              position: _cardSlide,
                              child: Column(
                                children: [
                                  Text(
                                    'أهلاً بك مجدداً',
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
                                    'سجل دخولك لحجز موعدك القادم',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _LoginCard(
                                    key: const ValueKey('loginCard'),
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    isPasswordObscured: _isPasswordObscured,
                                    onToggleObscure: () => setState(
                                      () => _isPasswordObscured =
                                          !_isPasswordObscured,
                                    ),
                                    isLoading: isLoading,
                                    onSubmit: () =>
                                        _submitLogin(context, buttonKey),
                                    buttonKey: buttonKey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeTransition(
                            opacity: _cardFade,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "ليس لديك حساب؟ ",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 350,
                                                  ),
                                              pageBuilder: (_, animation, __) =>
                                                  FadeTransition(
                                                    opacity: animation,
                                                    child:
                                                        const RegisterScreen(),
                                                  ),
                                            ),
                                          );
                                        },
                                  child: Text(
                                    'إنشاء حساب جديد',
                                    style: TextStyle(
                                      color: AppColors.accentColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'BARBER ON YOUR TIME',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
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

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.18 + (_pulseController.value * 0.12);
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardColor,
            border: Border.all(
              color: AppColors.accentColor.withOpacity(0.35),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentColor.withOpacity(glow),
                blurRadius: 34,
                spreadRadius: 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentColor,
              AppColors.accentColor.withOpacity(0.7),
            ],
          ),
        ),
        child: const Icon(
          Icons.content_cut_rounded,
          color: AppColors.backgroundColor,
          size: 46,
        ),
      ),
    );
  }
}

class _LoginCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordObscured;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSubmit;
  final GlobalKey<_AnimatedSubmitButtonState> buttonKey;

  const _LoginCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordObscured,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
    required this.buttonKey,
  });

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ledController;

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
    super.dispose();
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 24),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.inputColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: border(AppColors.borderColor.withOpacity(0.5)),
      enabledBorder: border(AppColors.borderColor.withOpacity(0.5)),
      focusedBorder: border(AppColors.accentColor, 2),
      errorBorder: border(AppColors.errorColor),
      focusedErrorBorder: border(AppColors.errorColor, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ledController,
      builder: (context, child) {
        return CustomPaint(
          painter: _BorderBeamPainter(
            animationValue: _ledController.value,
            color: AppColors.accentColor,
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
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                cursorColor: AppColors.accentColor,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(
                    r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value.trim())) {
                    return 'يرجى إدخال بريد إلكتروني صالح';
                  }
                  return null;
                },
                decoration: _decoration(
                  hint: 'أدخل بريدك الإلكتروني',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 20),
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
                controller: widget.passwordController,
                obscureText: widget.isPasswordObscured,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!widget.isLoading) widget.onSubmit();
                },
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                cursorColor: AppColors.accentColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
                decoration: _decoration(
                  hint: 'أدخل كلمة المرور',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: widget.onToggleObscure,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        widget.isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        key: ValueKey(widget.isPasswordObscured),
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _AnimatedSubmitButton(
                key: widget.buttonKey,
                isLoading: widget.isLoading,
                label: 'تسجيل الدخول',
                onPressed: widget.onSubmit,
              ),
            ],
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
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final basePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rRect, basePaint);

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
      ..strokeWidth = 10
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

class _AnimatedSubmitButton extends StatefulWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _AnimatedSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
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
  late final Animation<double> _shakeAnimation;
  late final Animation<Color?> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = ColorTween(
      begin: AppColors.accentColor,
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

        final currentColor = _flashAnimation.value ?? AppColors.accentColor;

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
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: currentColor, width: 2),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: currentColor,
                          ),
                        )
                      : Text(
                          widget.label,
                          key: const ValueKey('label'),
                          style: TextStyle(
                            color: currentColor,
                            fontSize: 17,
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
