import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/availabilityCubit/get_availability_cubit.dart';
import '../../cubits/availabilityCubit/request_deletion_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/availability/getAvailability/get_availability_model.dart';
import '../../models/availability/requestDeletion/request_deletion_model.dart';
import 'add_availability_screen.dart';
import 'request_availability_screen.dart';

class GetAvailabilityScreen extends StatefulWidget {
  const GetAvailabilityScreen({super.key});

  @override
  State<GetAvailabilityScreen> createState() => _GetAvailabilityScreenState();
}

class _GetAvailabilityScreenState extends State<GetAvailabilityScreen> {
  final GetAvailabilityCubit _availabilityCubit = getIt<GetAvailabilityCubit>();
  final RequestDeletionCubit _deletionCubit = getIt<RequestDeletionCubit>();

  static const Map<int, String> _daysMap = {
    0: 'الأحد',
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
  };

  List<AvailabilityData> _availabilityList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _deletionCubit.close();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _availabilityCubit.fetchAvailability();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _getDayName(int? dayIndex) {
    if (dayIndex == null) return 'غير محدد';
    return _daysMap[dayIndex] ?? 'يوم غير معروف';
  }

  Future<void> _navigateToRequestEdit(AvailabilityData item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestAvailabilityScreen(currentAvailability: item),
      ),
    );

    if (result == true && mounted) {
      _loadAll();
    }
  }

  Future<void> _confirmDelete(AvailabilityData item) async {
    if (item.id == null) return;

    final dayName = _getDayName(item.dayOfWeek);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'طلب حذف الدوام',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'بدك تبعت طلب حذف دوام $dayName؟ الطلب رح يروح لصاحب المحل للموافقة، وما رح يتحذف فعليًا إلا بعد موافقته.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'إرسال طلب الحذف',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      _deletionCubit.requestDeletion(availabilityId: item.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocListener(
        listeners: [
          BlocListener<GetAvailabilityCubit, ResultState<GetAvailabilityModel>>(
            bloc: _availabilityCubit,
            listener: (context, state) {
              state.whenOrNull(
                success: (data) {
                  setState(() => _availabilityList = data.data ?? []);
                },
                error: (message) {
                  setState(() => _errorMessage = message);
                },
              );
            },
          ),
          BlocListener<RequestDeletionCubit, ResultState<RequestDeletionModel>>(
            bloc: _deletionCubit,
            listener: (context, state) {
              state.whenOrNull(
                success: (data) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(data.message ?? 'تم إرسال طلب الحذف 🎉'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                  _deletionCubit.resetState();
                  _loadAll();
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                  _deletionCubit.resetState();
                },
              );
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'أوقات دوامي',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.accentColor,
                    size: 22,
                  ),
                ),
                onPressed: () async {
                  final existingDates = _availabilityList
                      .where((e) => e.date != null)
                      .map((e) => DateTime.tryParse(e.date!))
                      .whereType<DateTime>()
                      .toList();

                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddAvailabilityScreen(existingDates: existingDates),
                    ),
                  );
                  if (result == true) {
                    _loadAll();
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    if (_availabilityList.isEmpty) {
      return _buildEmptyState();
    }

    final sortedList = List<AvailabilityData>.from(_availabilityList)
      ..sort((a, b) {
        final da = a.date != null ? DateTime.tryParse(a.date!) : null;
        final db = b.date != null ? DateTime.tryParse(b.date!) : null;
        if (da == null || db == null) return 0;
        return da.compareTo(db);
      });

    return RefreshIndicator(
      color: AppColors.accentColor,
      backgroundColor: AppColors.cardColor,
      onRefresh: _loadAll,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: sortedList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = sortedList[index];
          return _buildAvailabilityCard(item);
        },
      ),
    );
  }

  Widget _buildAvailabilityCard(AvailabilityData item) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(item),
      child: _LightSweepBorder(
        borderRadius: 20,
        borderColor: AppColors.accentColor,
        borderThickness: 2.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentColor.withOpacity(0.15),
                  border: Border.all(
                    color: AppColors.accentColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(item.dayOfWeek),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'من: ${item.startTime ?? '--:--'}   إلى: ${item.endTime ?? '--:--'}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // أزرار التعديل والحذف
              InkWell(
                onTap: () => _navigateToRequestEdit(item),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _confirmDelete(item),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 70,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أوقات دوام مسجلة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم إدخال جدول الدوام الخاص بك بعد.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: _loadAll,
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.backgroundColor,
              ),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent.withOpacity(0.8),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _loadAll,
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// Light Sweep Animation Border Widget
// =========================================================
class _LightSweepBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double borderThickness;

  const _LightSweepBorder({
    required this.child,
    required this.borderRadius,
    required this.borderColor,
    this.borderThickness = 2.5,
  });

  @override
  State<_LightSweepBorder> createState() => _LightSweepBorderState();
}

class _LightSweepBorderState extends State<_LightSweepBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(widget.borderThickness),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              transform: GradientRotation(_controller.value * 6.283185),
              colors: [
                widget.borderColor.withOpacity(0.15),
                widget.borderColor,
                widget.borderColor.withOpacity(0.15),
              ],
              stops: const [0.0, 0.25, 0.5],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}