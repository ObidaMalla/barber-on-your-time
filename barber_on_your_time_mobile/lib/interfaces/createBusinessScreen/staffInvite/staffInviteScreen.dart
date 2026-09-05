import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/results_state.dart';
import '../../../cubits/staffInviteCubit/staff_invite_cubit.dart';
import '../../../models/staffInvite/staff_invite_model.dart';

class StaffInviteScreen extends StatelessWidget {
  const StaffInviteScreen({super.key});

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ الكود!'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'دعوة موظف جديد',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.accentColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'ولّد كود دعوة، وشاركه مع الحلاق حتى ينضم لمحلك',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              BlocConsumer<StaffInviteCubit, ResultState<StaffInviteModel>>(
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
                      if (code != null)
                        GestureDetector(
                          onTap: () => _copyCode(context, code),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accentColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  code,
                                  style: TextStyle(
                                    color: AppColors.accentColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'اضغط للنسخ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => context
                                    .read<StaffInviteCubit>()
                                    .generateInvite(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            disabledBackgroundColor: AppColors.accentColor
                                .withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.backgroundColor,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  code == null ? 'توليد كود' : 'توليد كود جديد',
                                  style: TextStyle(
                                    color: AppColors.backgroundColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
