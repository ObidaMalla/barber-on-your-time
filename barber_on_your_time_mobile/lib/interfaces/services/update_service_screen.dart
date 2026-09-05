import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/results_state.dart';
import '../../cubits/servicesCubit/updateServiceCubit/update_service_cubit.dart';
import '../../main.dart';
import '../../models/services/getServices/get_services_model.dart';
import '../../models/services/updateService/update_service_model.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceData service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;

  late final UpdateServiceCubit _updateServiceCubit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name ?? '');
    _durationController = TextEditingController(
      text: (widget.service.durationMinutes ?? 0).toString(),
    );
    _priceController = TextEditingController(
      text: (widget.service.price ?? 0).toString(),
    );
    _updateServiceCubit = getIt<UpdateServiceCubit>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _updateServiceCubit,
      child: BlocConsumer<UpdateServiceCubit, ResultState<UpdateServiceModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (data) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data.message ?? 'تم تحديث الخدمة بنجاح 🎉'),
                  backgroundColor: AppColors.successColor,
                ),
              );
              Navigator.pop(context, true);
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

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'تعديل الخدمة',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 32),
                      Text(
                        'بيانات الخدمة',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'اسم الخدمة',
                        hint: 'مثال: قص شعر',
                        icon: Icons.content_cut_rounded,
                        keyboardType: TextInputType.text,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'يرجى إدخال اسم الخدمة'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        controller: _durationController,
                        label: 'المدة (دقيقة)',
                        hint: 'مثال: 30',
                        icon: Icons.access_time_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'يرجى إدخال المدة';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'يجب أن تكون رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        controller: _priceController,
                        label: 'السعر',
                        hint: 'مثال: 15',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'يرجى إدخال السعر';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'يجب أن يكون رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),
                      _buildSubmitButton(isLoading),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
            child: Icon(
              Icons.edit_note_rounded,
              color: AppColors.accentColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'تعديل بيانات الخدمة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عدّل الاسم أو المدة أو السعر وسيتم التحديث فوراً',
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
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
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

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  _updateServiceCubit.updateService(
                    serviceId: widget.service.id ?? 0,
                    name: _nameController.text.trim(),
                    durationMinutes: int.parse(_durationController.text.trim()),
                    price: double.parse(_priceController.text.trim()),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          disabledBackgroundColor: AppColors.accentColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 5,
          shadowColor: AppColors.accentColor.withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.backgroundColor,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'حفظ التعديلات',
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
