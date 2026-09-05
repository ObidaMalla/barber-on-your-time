import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/bookingCubit/create_booking_cubit.dart';
import '../../cubits/businessCubit/get_staff_by_business_id_cubit.dart';
import '../../cubits/results_state.dart';
import '../../cubits/servicesCubit/get_services_by_business_cubit.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/booking/createBooking/create_booking_model.dart';
import '../../models/business/get_services_by_business_model.dart';
import '../../models/business/get_staff_by_business_id_model.dart';

class CreateBookingScreen extends StatefulWidget {
  final int businessId;

  const CreateBookingScreen({super.key, required this.businessId});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late final GetServicesByBusinessCubit _servicesCubit;
  late final GetStaffByBusinessIdCubit _staffCubit;
  late final CreateBookingCubit _bookingCubit;

  int? _selectedServiceId;
  int? _selectedStaffId;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();

    _servicesCubit = getIt<GetServicesByBusinessCubit>();

    _staffCubit = getIt<GetStaffByBusinessIdCubit>();

    _bookingCubit = getIt<CreateBookingCubit>();

    _servicesCubit.getServicesByBusinessId(widget.businessId);

    _staffCubit.getStaffByBusinessId(widget.businessId);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ============================================================
  // اختيار التاريخ
  // ============================================================

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ============================================================
  // اختيار الوقت
  // ============================================================

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ============================================================
  // إرسال الحجز
  // ============================================================

  void _submitBooking() {
    if (_selectedServiceId == null) {
      _showSnackBar('يرجى اختيار الخدمة', AppColors.errorColor);
      return;
    }

    if (_selectedStaffId == null) {
      _showSnackBar('يرجى اختيار الموظف', AppColors.errorColor);
      return;
    }

    // الوقت المحلي الذي اختاره المستخدم
    final bookingDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // تحويل Local إلى UTC
    final utcBookingDateTime = bookingDateTime.toUtc();

    // Logs للتأكد من التوقيت
    debugPrint('🕐 Selected Local DateTime: $bookingDateTime');

    debugPrint('🌍 Selected UTC DateTime: $utcBookingDateTime');

    debugPrint(
      '📤 Sending startTime: '
      '${utcBookingDateTime.toIso8601String()}',
    );

    // إرسال UTC للـ Backend
    _bookingCubit.createBooking(
      serviceId: _selectedServiceId!,
      staffId: _selectedStaffId!,
      startTime: utcBookingDateTime.toIso8601String(),
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
          'حجز موعد',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocListener<CreateBookingCubit, ResultState<CreateBookingModel>>(
        bloc: _bookingCubit,

        listener: (context, state) {
          state.whenOrNull(
            // ----------------------------------------------------
            // Loading
            // ----------------------------------------------------
            loading: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                    ),
                  );
                },
              );
            },

            // ----------------------------------------------------
            // Success
            // ----------------------------------------------------
            success: (data) {
              Navigator.pop(context);

              _showSnackBar('تم الحجز بنجاح!', Colors.green);

              Navigator.pop(context);
            },

            // ----------------------------------------------------
            // Error
            // ----------------------------------------------------
            error: (message) {
              Navigator.pop(context);

              _showSnackBar(message, AppColors.errorColor);
            },
          );
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildSectionTitle('1. اختر الخدمة'),

              const SizedBox(height: 10),

              _buildServicesSection(),

              const SizedBox(height: 24),

              _buildSectionTitle('2. اختر الموظف (اختياري)'),

              const SizedBox(height: 10),

              _buildStaffSection(),

              const SizedBox(height: 24),

              _buildSectionTitle('3. تحديد الموعد'),

              const SizedBox(height: 10),

              _buildDateTimePicker(),

              const SizedBox(height: 32),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // عنوان القسم
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // الخدمات
  // ============================================================

  Widget _buildServicesSection() {
    return BlocBuilder<
      GetServicesByBusinessCubit,
      ResultState<GetServicesByBusinessModel>
    >(
      bloc: _servicesCubit,

      builder: (context, state) {
        return state.when(
          idle: () {
            return const SizedBox.shrink();
          },

          loading: () {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            );
          },

          error: (msg) {
            return Text(msg, style: TextStyle(color: AppColors.errorColor));
          },

          success: (data) {
            final services = data.data ?? [];

            if (services.isEmpty) {
              return Text(
                'لا توجد خدمات متاحة',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }

            return Column(
              children: services.map((service) {
                final isSelected = _selectedServiceId == service.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),

                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentColor.withOpacity(0.15)
                        : AppColors.cardColor,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentColor
                          : AppColors.borderColor,
                    ),
                  ),

                  // =================================================
                  // حل مشكلة ListTile:
                  // Material يجعل ink splash/background
                  // يظهر فوق الـ DecoratedBox بشكل صحيح
                  // =================================================
                  child: Material(
                    color: Colors.transparent,

                    borderRadius: BorderRadius.circular(12),

                    clipBehavior: Clip.antiAlias,

                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedServiceId = service.id;
                        });
                      },

                      title: Text(
                        service.name ?? '',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        '${service.price ?? 0} ل.س - '
                        '${service.durationMinutes ?? 0} دقيقة',

                        style: TextStyle(color: AppColors.textSecondary),
                      ),

                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.accentColor,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: AppColors.textSecondary,
                            ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // الموظفين
  // ============================================================

  Widget _buildStaffSection() {
    return BlocBuilder<
      GetStaffByBusinessIdCubit,
      ResultState<GetStaffByBusinessIdModel>
    >(
      bloc: _staffCubit,

      builder: (context, state) {
        return state.when(
          idle: () {
            return const SizedBox.shrink();
          },

          loading: () {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            );
          },

          error: (msg) {
            return Text(msg, style: TextStyle(color: AppColors.errorColor));
          },

          success: (data) {
            final staffList = data.data ?? [];

            if (staffList.isEmpty) {
              return Text(
                'لا يوجد موظفين متاحين',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: staffList.map((staff) {
                  final isSelected = _selectedStaffId == staff.id;

                  final staffName = staff.user?.name ?? 'بدون اسم';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStaffId = isSelected ? null : staff.id;
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(left: 12),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentColor
                            : AppColors.cardColor,

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentColor
                              : AppColors.borderColor,
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            staffName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // اختيار التاريخ والوقت
  // ============================================================

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,

            borderRadius: BorderRadius.circular(12),

            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.cardColor,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: AppColors.borderColor),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'التاريخ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${_selectedDate.year}-'
                    '${_selectedDate.month}-'
                    '${_selectedDate.day}',

                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: InkWell(
            onTap: _pickTime,

            borderRadius: BorderRadius.circular(12),

            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.cardColor,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: AppColors.borderColor),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'الوقت',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _selectedTime.format(context),

                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // زر تأكيد الحجز
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: ElevatedButton(
        onPressed: _submitBooking,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        child: const Text(
          'تأكيد الحجز',

          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
