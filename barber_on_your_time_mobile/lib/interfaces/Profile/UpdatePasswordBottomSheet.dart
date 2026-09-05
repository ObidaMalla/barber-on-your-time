import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/profileCubit/updatePasswordProfileCubit/update_password_cubit.dart';
import '../../cubits/results_state.dart';
import '../../models/profile/updatePasswordProfile/update_password_model.dart';

class UpdatePasswordBottomSheet extends StatefulWidget {
  const UpdatePasswordBottomSheet({super.key});

  @override
  State<UpdatePasswordBottomSheet> createState() =>
      _UpdatePasswordBottomSheetState();
}

class _UpdatePasswordBottomSheetState extends State<UpdatePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color neonPink = Color(0xFFFF007F);
    const Color neonYellow = Color(0xFFCCFF00);
    const Color cardBg = Color(0xFF141419);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: neonPink.withOpacity(0.3), width: 1.5),
      ),
      child: BlocConsumer<UpdatePasswordCubit, ResultState<UpdatePasswordModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (data) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data.message ?? 'تم تحديث كلمة المرور بنجاح ⚡'),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context); // إغلاق النافذة بعد النجاح
            },
            error: (errorMessage) {
              // إظهار رسالة الخطأ فوراً للمستخدم عند الفشل (مثل: الباسورد القديم غلط)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: neonPink,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
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

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.lock_reset_rounded, color: neonPink, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'تحديث كلمة المرور',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // حقل كلمة المرور القديمة
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الحالية',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.lock_outline, color: neonPink),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOld ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () =>
                            setState(() => _obscureOld = !_obscureOld),
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: neonPink),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'يرجى إدخال كلمة المرور الحالية'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // حقل كلمة المرور الجديدة
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.key_rounded, color: neonYellow),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: neonYellow),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الجديدة';
                      }
                      if (val.length < 6) {
                        return 'يجب أن لا تقل عن 6 خانات';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // زر الحفظ والتأكيد
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<UpdatePasswordCubit>()
                                  .updatePassword(
                                    oldPassword: _oldPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonPink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'تأكيد التغيير ⚡',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
