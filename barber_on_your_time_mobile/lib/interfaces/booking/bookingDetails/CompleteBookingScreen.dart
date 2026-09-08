import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/bookingCubit/complete_booking_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../injections/bootStrap/auth/login_injection.dart';
import '../../../models/booking/completeBooking/complete_booking_model.dart';

class CompleteBookingScreen extends StatefulWidget {
  final int bookingId;

  const CompleteBookingScreen({super.key, required this.bookingId});

  @override
  State<CompleteBookingScreen> createState() => _CompleteBookingScreenState();
}

class _CompleteBookingScreenState extends State<CompleteBookingScreen> {
  late final CompleteBookingCubit _completeCubit;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _completeCubit = getIt<CompleteBookingCubit>();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      _completeCubit.completeBooking(bookingId: widget.bookingId, code: code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال كود مكون من 6 أرقام'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _completeCubit,
      child: BlocConsumer<CompleteBookingCubit, ResultState<CompleteBookingModel>>(
        listener: (context, state) {
          state.whenOrNull(
            loading: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentColor,
                  ),
                ),
              );
            },
            success: (data) {
              Navigator.pop(context); // إغلاق الـ Dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    data.message ?? 'تم تأكيد اكتمال الخدمة بنجاح 🎉',
                  ),
                  backgroundColor: AppColors.successColor,
                ),
              );
              Navigator.pop(
                context,
                true,
              ); // إغلاق الشاشة وإرجاع نجاح للواجهة القادمة منها
            },
            error: (message) {
              Navigator.pop(context); // إغلاق الـ Dialog
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
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'تأكيد اكتمال الخدمة',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 80,
                      color: AppColors.accentColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'أدخل رمز التأكيد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يرجى إدخال الكود المكون من 6 أرقام المستلم لتأكيد إتمام الخدمة بنجاح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          letterSpacing: 10,
                        ),
                        filled: true,
                        fillColor: AppColors.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppColors.accentColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'تأكيد الإكمال',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
