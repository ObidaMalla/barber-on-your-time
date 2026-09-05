import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/results_state.dart';
import '../../../main.dart';
import '../../cubits/servicesCubit/add_service_cubit.dart';
import '../../models/services/add_services/add_service_model.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int? _selectedDurationMinutes;
  late final AddServiceCubit _addServiceCubit;

  @override
  void initState() {
    super.initState();
    _addServiceCubit = getIt<AddServiceCubit>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 🕒 نافذة اختيار المدة الزمنية باستخدام الـ Timer Picker
  void _showDurationPicker() {
    FocusScope.of(context).unfocus();
    Duration initialDuration = Duration(
      minutes: _selectedDurationMinutes ?? 30,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    'تحديد مدة الخدمة',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDurationMinutes = initialDuration.inMinutes;
                        _durationController.text =
                            '$_selectedDurationMinutes دقيقة';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'تم',
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: initialDuration,
                    onTimerDurationChanged: (Duration newDuration) {
                      initialDuration = newDuration;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _addServiceCubit.addService(
        name: _nameController.text.trim(),
        durationMinutes: _selectedDurationMinutes!,
        price: int.parse(_priceController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddServiceCubit, ResultState<AddServiceModel>>(
      bloc: _addServiceCubit,
      listener: (context, state) {
        state.whenOrNull(
          success: (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data.message ?? 'تمت إضافة الخدمة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'إضافة خدمة جديدة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardColor,
                      border: Border.all(
                        color: AppColors.accentColor.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentColor.withOpacity(0.15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_task_rounded,
                      size: 45,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // اسم الخدمة
                _buildFieldLabel('اسم الخدمة'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(
                    hintText: 'مثال: قص شعر + ذقن',
                    icon: Icons.content_cut_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم الخدمة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // مدة الخدمة (Time Picker)
                _buildFieldLabel('المدة المتوقعة'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _durationController,
                  readOnly: true,
                  onTap: _showDurationPicker,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(
                    hintText: 'اضغط لاختيار الوقت',
                    icon: Icons.access_time_filled_rounded,
                  ),
                  validator: (value) {
                    if (_selectedDurationMinutes == null ||
                        _selectedDurationMinutes! == 0) {
                      return 'يرجى تحديد مدة الخدمة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // السعر
                _buildFieldLabel('السعر (\$)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(
                    hintText: 'مثال: 50',
                    icon: Icons.attach_money_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال سعر الخدمة';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'أدخل رقماً صحيحاً';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // زر الحفظ / الإضافة
                BlocBuilder<AddServiceCubit, ResultState<AddServiceModel>>(
                  bloc: _addServiceCubit,
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );

                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: AppColors.backgroundColor,
                              )
                            : Text(
                                'حفظ الخدمة',
                                style: TextStyle(
                                  color: AppColors.backgroundColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.5),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.accentColor, size: 20),
      filled: true,
      fillColor: AppColors.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accentColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
