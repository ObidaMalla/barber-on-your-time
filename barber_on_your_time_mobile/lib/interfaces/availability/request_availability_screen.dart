import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/availabilityCubit/request_availability_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/availability/getAvailability/get_availability_model.dart';
import '../../models/availability/requestAvailability/request_availability_model.dart';

class RequestAvailabilityScreen extends StatefulWidget {
  final AvailabilityData currentAvailability;

  const RequestAvailabilityScreen({
    super.key,
    required this.currentAvailability,
  });

  @override
  State<RequestAvailabilityScreen> createState() =>
      _RequestAvailabilityScreenState();
}

class _RequestAvailabilityScreenState extends State<RequestAvailabilityScreen> {
  late final RequestAvailabilityCubit _cubit;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedDayOfWeek;

  static const Map<int, String> _daysMap = {
    0: 'الأحد',
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
  };

  @override
  void initState() {
    super.initState();
    _cubit = getIt<RequestAvailabilityCubit>();
    _selectedDayOfWeek = widget.currentAvailability.dayOfWeek ?? 0;
    _startTime =
        _parseTime(widget.currentAvailability.startTime) ??
        const TimeOfDay(hour: 9, minute: 0);
    _endTime =
        _parseTime(widget.currentAvailability.endTime) ??
        const TimeOfDay(hour: 17, minute: 0);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) return null;
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: AppColors.backgroundColor,
              surface: AppColors.cardColor,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    final startStr = _formatTime(_startTime);
    final endStr = _formatTime(_endTime);

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('وقت النهاية لازم يكون بعد وقت البداية'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (widget.currentAvailability.id == null) return;

    _cubit.requestChange(
      availabilityId: widget.currentAvailability.id!,
      dayOfWeek: _selectedDayOfWeek,
      startTime: startStr,
      endTime: endStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayName = _daysMap[_selectedDayOfWeek] ?? 'غير محدد';

    return BlocProvider.value(
      value: _cubit,
      child:
          BlocConsumer<
            RequestAvailabilityCubit,
            ResultState<RequestAvailabilityModel>
          >(
            listener: (context, state) {
              state.whenOrNull(
                success: (data) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(data.message ?? 'تم إرسال طلب التعديل 🎉'),
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
                    'طلب تعديل الدوام',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(dayName),
                        const SizedBox(height: 32),
                        Text(
                          'اليوم المطلوب',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borderColor.withOpacity(0.5),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedDayOfWeek,
                              isExpanded: true,
                              dropdownColor: AppColors.cardColor,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.accentColor,
                              ),
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _daysMap.entries.map((entry) {
                                return DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.event_rounded,
                                        color: AppColors.accentColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(entry.value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedDayOfWeek = value);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'الوقت الجديد المطلوب',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePicker(
                                label: 'من',
                                time: _startTime,
                                onTap: () => _pickTime(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildTimePicker(
                                label: 'إلى',
                                time: _endTime,
                                onTap: () => _pickTime(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        _buildSubmitButton(isLoading),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildHeaderCard(String dayName) {
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
              Icons.edit_calendar_rounded,
              color: AppColors.accentColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'طلب تعديل دوام $dayName',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الطلب رح يروح لصاحب المحل للموافقة، وما رح يتغير دوامك فعلياً إلا بعد موافقته',
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

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.inputColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppColors.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(time),
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

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
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
                'إرسال طلب التعديل',
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
