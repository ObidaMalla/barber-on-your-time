import 'dart:async';
import 'dart:math' as math;

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
import 'staff_selection_screen.dart';

// ----------------------------------------------------
// 💡 CustomPainter لرسم مسار الليد المتحرك على الحواف
// ----------------------------------------------------
class LedPathBorderPainter extends CustomPainter {
  final double animationValue;
  final Color glowColor;
  final double borderRadius;
  final double strokeWidth;

  LedPathBorderPainter({
    required this.animationValue,
    required this.glowColor,
    this.borderRadius = 14.0,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final basePaint = Paint()
      ..color = glowColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, basePaint);

    final double rotationAngle = animationValue * 2 * math.pi;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          glowColor.withOpacity(0.0),
          glowColor,
          glowColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.25, 0.5],
        transform: GradientRotation(rotationAngle),
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant LedPathBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.glowColor != glowColor;
  }
}

// ----------------------------------------------------
// 💡 الودجت المغلفة للتأثير المساري
// ----------------------------------------------------
class LedPathContainer extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final AnimationController animationController;
  final Color glowColor;
  final double borderRadius;

  const LedPathContainer({
    super.key,
    required this.child,
    required this.isSelected,
    required this.animationController,
    required this.glowColor,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return CustomPaint(
          foregroundPainter: LedPathBorderPainter(
            animationValue: animationController.value,
            glowColor: glowColor,
            borderRadius: borderRadius,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// 📱 شاشة الحجز الرئيسية
// ----------------------------------------------------
class CreateBookingScreen extends StatefulWidget {
  final int businessId;

  const CreateBookingScreen({super.key, required this.businessId});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen>
    with SingleTickerProviderStateMixin {
  late final GetServicesByBusinessCubit _servicesCubit;
  late final GetStaffByBusinessIdCubit _staffCubit;
  late final CreateBookingCubit _bookingCubit;

  late final AnimationController _ledPathController;

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

    _ledPathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _ledPathController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: Colors.black,
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: Colors.black,
              surface: AppColors.cardColor,
              onSurface: AppColors.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.cardColor,
              hourMinuteColor: AppColors.backgroundColor,
              hourMinuteTextColor: AppColors.accentColor,
              // تغيير لون خلفية AM/PM بناءً على حالة التحديد
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.accentColor; // اللون عند التحديد
                }
                return AppColors.backgroundColor; // اللون العادي
              }),
              // تغيير لون النص بناءً على حالة التحديد
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.black; // لون النص عند التحديد
                }
                return AppColors.textSecondary; // لون النص العادي
              }),
              dayPeriodBorderSide: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showPastTimeWarning() {
    Timer? timer;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        timer = Timer(const Duration(seconds: 3), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.errorColor),
              const SizedBox(width: 8),
              Text(
                'وقت غير صالح',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'ما فيك تحجز بوقت مضى بالفعل. يرجى اختيار تاريخ أو وقت لاحق.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                timer?.cancel();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'إلغاء',
                style: TextStyle(color: AppColors.accentColor, fontSize: 15),
              ),
            ),
          ],
        );
      },
    ).then((_) => timer?.cancel());
  }

  void _submitBooking() {
    if (_selectedServiceId == null) {
      _showSnackBar('يرجى اختيار الخدمة', AppColors.errorColor);
      return;
    }
    if (_selectedStaffId == null) {
      _showSnackBar('يرجى اختيار الحلاق', AppColors.errorColor);
      return;
    }

    final bookingDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (bookingDateTime.isBefore(DateTime.now())) {
      _showPastTimeWarning();
      return;
    }

    final utcBookingDateTime = bookingDateTime.toUtc();

    _bookingCubit.createBooking(
      serviceId: _selectedServiceId!,
      staffId: _selectedStaffId!,
      startTime: utcBookingDateTime.toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.accentColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'حجز موعد',
            style: TextStyle(
              color: AppColors.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocListener<CreateBookingCubit, ResultState<CreateBookingModel>>(
          bloc: _bookingCubit,
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
                Navigator.pop(context);
                _showSnackBar('تم الحجز بنجاح!', Colors.green);
                Navigator.pop(context);
              },
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
                const SizedBox(height: 20),
                _buildSectionTitle('2. اختر الحلاق'),
                const SizedBox(height: 10),
                _buildStaffSection(),
                const SizedBox(height: 20),
                _buildSectionTitle('3. تحديد الموعد'),
                const SizedBox(height: 10),
                _buildDateTimePicker(),
                // نزّلنا الأزرار لتحت قليلاً بمقدار 40 بكسل
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 14),
                _buildStaffGridButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServicesSection() {
    return BlocBuilder<
      GetServicesByBusinessCubit,
      ResultState<GetServicesByBusinessModel>
    >(
      bloc: _servicesCubit,
      builder: (context, state) {
        return state.when(
          idle: () => const SizedBox.shrink(),
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.accentColor),
          ),
          error: (msg) => Text(
            msg,
            style: TextStyle(color: AppColors.errorColor, fontSize: 14),
          ),
          success: (data) {
            final services = data.data ?? [];
            if (services.isEmpty) {
              return Text(
                'لا توجد خدمات متاحة',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              );
            }

            return Column(
              children: services.map((service) {
                final isSelected = _selectedServiceId == service.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LedPathContainer(
                    isSelected: isSelected,
                    animationController: _ledPathController,
                    glowColor: AppColors.accentColor,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () =>
                            setState(() => _selectedServiceId = service.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name ?? '',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.payments_outlined,
                                              size: 16,
                                              color: AppColors.accentColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'السعر: ',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              '${service.price ?? 0} ل.س',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: AppColors.accentColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'الوقت: ',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              '${service.durationMinutes ?? 0} دقيقة',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? AppColors.accentColor
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildStaffSection() {
    return BlocBuilder<
      GetStaffByBusinessIdCubit,
      ResultState<GetStaffByBusinessIdModel>
    >(
      bloc: _staffCubit,
      builder: (context, state) {
        return state.when(
          idle: () => const SizedBox.shrink(),
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.accentColor),
          ),
          error: (msg) => Text(
            msg,
            style: TextStyle(color: AppColors.errorColor, fontSize: 14),
          ),
          success: (data) {
            final staffList = data.data ?? [];
            if (staffList.isEmpty) {
              return Text(
                'لا يوجد حلاقين متاحين',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: staffList.map((staff) {
                  final isSelected = _selectedStaffId == staff.id;
                  final staffName = staff.user?.name ?? 'بدون اسم';

                  return Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: LedPathContainer(
                      isSelected: isSelected,
                      animationController: _ledPathController,
                      glowColor: AppColors.accentColor,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStaffId = isSelected ? null : staff.id;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 20,
                                color: isSelected
                                    ? AppColors.accentColor
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                staffName,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.accentColor
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: LedPathContainer(
            isSelected: true,
            animationController: _ledPathController,
            glowColor: AppColors.accentColor,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: Icon(
                Icons.calendar_today_rounded,
                color: AppColors.accentColor,
                size: 20,
              ),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'التاريخ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LedPathContainer(
            isSelected: true,
            animationController: _ledPathController,
            glowColor: AppColors.accentColor,
            child: OutlinedButton.icon(
              onPressed: _pickTime,
              icon: Icon(
                Icons.access_time_rounded,
                color: AppColors.accentColor,
                size: 20,
              ),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'الوقت',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: LedPathContainer(
        isSelected: true,
        animationController: _ledPathController,
        glowColor: AppColors.accentColor,
        child: OutlinedButton(
          onPressed: _submitBooking,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.cardColor,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'تأكيد الحجز',
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffGridButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: LedPathContainer(
        isSelected: true,
        animationController: _ledPathController,
        glowColor: AppColors.accentColor,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffSelectionScreen(staffCubit: _staffCubit),
              ),
            );
          },
          icon: Icon(
            Icons.access_time_filled,
            color: AppColors.accentColor,
            size: 20,
          ),
          label: Text(
            'أوقات الحلاقين المتاحة',
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.cardColor,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
