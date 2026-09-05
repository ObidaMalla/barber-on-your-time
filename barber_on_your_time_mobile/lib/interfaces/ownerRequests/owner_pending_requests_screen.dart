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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                      // 👈 استدعاء دالة الجلب المعتمدة لديك في الـ Cubit
                      await _cubit.fetchPendingRequests();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentColor.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentColor.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.accentColor.withOpacity(0.25),
                ),
              ),
              child: Icon(icon, color: AppColors.accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDayName(item.dayOfWeek),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$typeLabel  •  $staffName',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'معلق',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
