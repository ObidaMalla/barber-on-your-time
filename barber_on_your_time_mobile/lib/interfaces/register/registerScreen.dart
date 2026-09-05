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

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // REGISTER
  // =========================

  void _submitRegister(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<RegisterCubit>().registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  // =========================
  // SNACKBAR
  // =========================

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: true,

      body: BlocConsumer<RegisterCubit, ResultState<RegisterModel>>(
        // ============================================================
        // LISTENER
        // ============================================================
        listener: (context, state) {
          state.whenOrNull(
            success: (userData) async {
              if (userData.success != true) {
                _showFloatingSnackBar(
                  userData.message ?? 'فشلت عملية إنشاء الحساب',
                  isSuccess: false,
                );
                return;
              }

              _showFloatingSnackBar(
                userData.message ?? 'تم إنشاء الحساب بنجاح 🚀',
                isSuccess: true,
              );

              await Future.delayed(const Duration(milliseconds: 900));

              if (!mounted) return;

              // بما إنه Register ما بيرجع Token، بنرجع لشاشة Login
              Navigator.pop(context);
            },

            // ========================================================
            // ERROR
            // ========================================================
            error: (error) {
              debugPrint('❌ [RegisterScreen] $error');
              _showFloatingSnackBar(error, isSuccess: false);
            },
          );
        },

        // ============================================================
        // BUILDER
        // ============================================================
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

                            // ==================================================
                            // LOGO
                            // ==================================================
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardColor,
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.35,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.18,
                                    ),
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
                                      AppColors.primaryColor,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.content_cut_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // TITLE
                            // ==================================================
                            Text(
                              'Create Account',
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
                              'Sign up to get started with BarberOnYourTime',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 34),

                            // ==================================================
                            // REGISTER CARD
                            // ==================================================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 1,
                                ),
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
                                    // =========================================
                                    // NAME
                                    // =========================================
                                    Text(
                                      'Name',
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
                                      cursorColor: AppColors.primaryColor,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter your full name',
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.errorColor,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.errorColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // =========================================
                                    // EMAIL
                                    // =========================================
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
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                      cursorColor: AppColors.primaryColor,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(
                                          r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value.trim())) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email address',
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.errorColor,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.errorColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // =========================================
                                    // PASSWORD
                                    // =========================================
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
                                      cursorColor: AppColors.primaryColor,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Create a password',
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
                                                ? Icons.visibility_off_outlined
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.errorColor,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.errorColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // =========================================
                                    // REGISTER BUTTON
                                    // =========================================
                                    SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => _submitRegister(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          disabledBackgroundColor: AppColors
                                              .primaryColor
                                              .withOpacity(0.45),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Text(
                                                  'Sign Up',
                                                  key: ValueKey('register'),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 26),

                            // ==================================================
                            // LOGIN LINK
                            // ==================================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
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
                                    'Sign in',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // FOOTER
                            // ==================================================
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
    );
  }
}
