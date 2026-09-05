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

  void _submitLogin(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            error: (error) => _showFloatingSnackBar(error, isSuccess: false),
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Stack(
            children: [
              // خلفية متدرجة مع توهج خفيف خلف الشعار
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.6),
                      radius: 1.2,
                      colors: [
                        AppColors.primaryColor.withOpacity(0.12),
                        AppColors.backgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
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

                                // LOGO مع أنيميشن نبض دخول
                                ScaleTransition(
                                  scale: _logoScale,
                                  child: _AnimatedLogo(),
                                ),

                                const SizedBox(height: 24),

                                FadeTransition(
                                  opacity: _cardFade,
                                  child: SlideTransition(
                                    position: _cardSlide,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Welcome Back',
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
                                          'Sign in to book your next cut',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 34),
                                        _LoginCard(
                                          formKey: _formKey,
                                          emailController: _emailController,
                                          passwordController:
                                              _passwordController,
                                          isPasswordObscured:
                                              _isPasswordObscured,
                                          onToggleObscure: () => setState(
                                            () => _isPasswordObscured =
                                                !_isPasswordObscured,
                                          ),
                                          isLoading: isLoading,
                                          onSubmit: () => _submitLogin(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 26),

                                FadeTransition(
                                  opacity: _cardFade,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
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
                                                    pageBuilder:
                                                        (
                                                          _,
                                                          animation,
                                                          __,
                                                        ) => FadeTransition(
                                                          opacity: animation,
                                                          child:
                                                              const RegisterScreen(),
                                                        ),
                                                  ),
                                                );
                                              },
                                        child: Text(
                                          'Create account',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 14,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

// =========================================================
// LOGO - مع نبض خفيف مستمر
// =========================================================
class _AnimatedLogo extends StatefulWidget {
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
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardColor,
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(glow),
                blurRadius: 34,
                spreadRadius: 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryColor, AppColors.primaryDark],
          ),
        ),
        child: const Icon(
          Icons.content_cut_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}

// =========================================================
// LOGIN CARD
// =========================================================
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordObscured;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordObscured,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
  });

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.inputColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: border(AppColors.borderColor),
      enabledBorder: border(AppColors.borderColor),
      focusedBorder: border(AppColors.primaryColor, 1.5),
      errorBorder: border(AppColors.errorColor),
      focusedErrorBorder: border(AppColors.errorColor, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Email',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              cursorColor: AppColors.primaryColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              decoration: _decoration(
                hint: 'Enter your email address',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Password',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: passwordController,
              obscureText: isPasswordObscured,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!isLoading) onSubmit();
              },
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              cursorColor: AppColors.primaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              decoration: _decoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  onPressed: onToggleObscure,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isPasswordObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey(isPasswordObscured),
                      color: AppColors.textSecondary,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _AnimatedSubmitButton(
              isLoading: isLoading,
              label: 'Sign In',
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// زر بتأثير ضغطة (scale down عند الضغط)
// =========================================================
class _AnimatedSubmitButton extends StatefulWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _AnimatedSubmitButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<_AnimatedSubmitButton> {
  double _scale = 1.0;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _setScale(0.96),
      onTapUp: widget.isLoading ? null : (_) => _setScale(1.0),
      onTapCancel: widget.isLoading ? null : () => _setScale(1.0),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [
                      AppColors.primaryColor.withOpacity(0.45),
                      AppColors.primaryDark.withOpacity(0.45),
                    ]
                  : [AppColors.primaryColor, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.label,
                    key: const ValueKey('label'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
