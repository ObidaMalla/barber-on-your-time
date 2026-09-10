import 'package:barber_on_your_time/interfaces/ownerRequests/request_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/availabilityOwnerCubit/owner_pending_requests_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/availabilityOwner/get_owner_pending_requests_model.dart';

class OwnerPendingRequestsScreen extends StatefulWidget {
  const OwnerPendingRequestsScreen({super.key});

  @override
  State<OwnerPendingRequestsScreen> createState() =>
      _OwnerPendingRequestsScreenState();
}

class _OwnerPendingRequestsScreenState
    extends State<OwnerPendingRequestsScreen> {
  final OwnerPendingRequestsCubit _cubit = getIt<OwnerPendingRequestsCubit>();

  static const Map<int, String> _daysMap = {
    0: 'الأحد',
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
  };

  static const Map<String, String> _typeLabels = {
    'ADD': 'إضافة دوام',
    'UPDATE': 'تعديل دوام',
    'DELETE': 'حذف دوام',
  };

  static const Map<String, IconData> _typeIcons = {
    'ADD': Icons.add_circle_outline_rounded,
    'UPDATE': Icons.edit_calendar_rounded,
    'DELETE': Icons.delete_outline_rounded,
  };

  @override
  void initState() {
    super.initState();
    _cubit.fetchPendingRequests();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _getDayName(int? dayIndex) {
    if (dayIndex == null) return 'غير محدد';
    return _daysMap[dayIndex] ?? 'يوم غير معروف';
  }

  Future<void> _openDetails(OwnerPendingRequestData request) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RequestDetailsScreen(request: request)),
    );
    if (changed == true && mounted) {
      _cubit.fetchPendingRequests();
    }
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
          centerTitle: true,
          title: Text(
            'طلبات الدوام المعلقة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body:
            BlocBuilder<
              OwnerPendingRequestsCubit,
              ResultState<GetOwnerPendingRequestsModel>
            >(
              bloc: _cubit,
              builder: (context, state) {
                return state.when(
                  idle: () => const SizedBox.shrink(),
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                    ),
                  ),
                  error: (message) => _buildErrorWidget(message),
                  success: (data) {
                    final list = data.data ?? [];
                    if (list.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: AppColors.accentColor,
                      backgroundColor: AppColors.cardColor,
                      onRefresh: () async {
                        await _cubit.fetchPendingRequests();
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return _buildRequestCard(item);
                        },
                      ),
                    );
                  },
                );
              },
            ),
      ),
    );
  }

  Widget _buildRequestCard(OwnerPendingRequestData item) {
    final type = item.type ?? 'ADD';
    final icon = _typeIcons[type] ?? Icons.event_note_rounded;
    final typeLabel = _typeLabels[type] ?? type;
    final staffName = item.staff?.user?.name ?? 'موظف غير معروف';

    return InkWell(
      onTap: () => _openDetails(item),
      borderRadius: BorderRadius.circular(20),
      child: _LightSweepBorder(
        borderRadius: 20,
        borderColor: Colors.teal,
        borderThickness: 8,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.12),
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
                  color: Colors.orangeAccent.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.orangeAccent.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: Colors.orangeAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getDayName(item.dayOfWeek),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'بانتظار الرد',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$typeLabel  •  $staffName',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
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
              Icons.inbox_rounded,
              size: 70,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد طلبات معلقة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'كل طلبات الدوام تمت معالجتها',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
              onPressed: () => _cubit.fetchPendingRequests(),
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
      duration: const Duration(seconds: 10),
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
