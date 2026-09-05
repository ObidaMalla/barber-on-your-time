import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/availabilityCubit/add_availability_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/availability/addAvailability/add_availability_model.dart';

class AddAvailabilityScreen extends StatefulWidget {
  final List<int> existingDays; // 👈 قائمة الأيام المُضافة سابقاً

  const AddAvailabilityScreen({super.key, this.existingDays = const []});

  @override
  State<AddAvailabilityScreen> createState() => _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {
  final AddAvailabilityCubit _cubit = getIt<AddAvailabilityCubit>();

  int? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // 1️⃣ خريطة الأيام المحدثة
  static const Map<int, String> _daysMap = {
    0: 'الأحد',
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 17, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: AppColors.backgroundColor,
              surface: AppColors.cardColor,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.backgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _submit() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار يوم الدوام')));
      return;
    }

    // 🛑 الشرط: التحقق مما إذا كان اليوم مضافاً سابقاً
    if (widget.existingDays.contains(_selectedDay)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'أنت لديك دوام في هذا اليوم، قم بتعديل وقتك ولا يمكنك إضافة دوام بنفس اليوم.',
          ),
          backgroundColor: Colors.orangeAccent,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد وقت البدء والنهاية')),
      );
      return;
    }

    _cubit.addAvailability(
      dayOfWeek: _selectedDay!,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تحديد وقت دوام جديد',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body:
            BlocConsumer<
              AddAvailabilityCubit,
              ResultState<AddAvailabilityModel>
            >(
              listener: (context, state) {
                state.whenOrNull(
                  success: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response.message ?? 'تم تحديد الدوام بنجاح',
                        ),
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
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'اختر اليوم',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          dropdownColor: AppColors.cardColor,
                          value: _selectedDay,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.cardColor,
                            hintText: 'اختر اليوم...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _daysMap.entries
                              .where(
                                (e) => e.key != 7,
                              ) // تجنب التكرار في القائمة
                              .map(
                                (e) => DropdownMenuItem<int>(
                                  value: e.key,
                                  child: Text(e.value),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDay = val;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'أوقات العمل',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePickerTile(
                                title: 'وقت البدء',
                                time: _startTime,
                                onTap: () => _selectTime(isStartTime: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimePickerTile(
                                title: 'وقت النهاية',
                                time: _endTime,
                                onTap: () => _selectTime(isStartTime: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: AppColors.backgroundColor,
                                  )
                                : Text(
                                    'حفظ الدوام',
                                    style: TextStyle(
                                      color: AppColors.backgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: time != null
                ? AppColors.accentColor.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppColors.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  time != null ? time.format(context) : '--:--',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
