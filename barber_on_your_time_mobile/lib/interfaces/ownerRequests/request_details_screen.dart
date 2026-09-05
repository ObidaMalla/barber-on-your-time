import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/availabilityOwnerCubit/answer_request_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/availabilityOwner/answer_request_model.dart';
import '../../models/availabilityOwner/get_owner_pending_requests_model.dart';

class RequestDetailsScreen extends StatefulWidget {

  final OwnerPendingRequestData request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late final AnswerRequestCubit _cubit;

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
    'ADD': 'إضافة دوام جديد',
    'UPDATE': 'تعديل دوام موجود',
    'DELETE': 'حذف دوام',
  };

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AnswerRequestCubit>();
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

  void _answer(String decision) {
    if (widget.request.id == null) return;
    _cubit.answerRequest(requestId: widget.request.id!, decision: decision);
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final type = request.type ?? 'ADD';
    final typeLabel = _typeLabels[type] ?? type;
    final staffName = request.staff?.user?.name ?? 'موظف غير معروف';
    final staffEmail = request.staff?.user?.email;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AnswerRequestCubit, ResultState<AnswerRequestModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (data) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data.message ?? 'تم تسجيل الرد 🎉'),
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
                'تفاصيل الطلب',
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
                    _buildHeaderCard(typeLabel, staffName),
                    const SizedBox(height: 28),
                    Text(
                      'تفاصيل الموظف',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.person_rounded, 'الاسم', staffName),
                    if (staffEmail != null)
                      _buildInfoRow(
                        Icons.email_rounded,
                        'البريد الإلكتروني',
                        staffEmail,
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'تفاصيل الطلب',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.event_rounded,
                      'اليوم',
                      _getDayName(request.dayOfWeek),
                    ),
                    _buildInfoRow(
                      Icons.access_time_rounded,
                      'من',
                      request.startTime ?? '--:--',
                    ),
                    _buildInfoRow(
                      Icons.access_time_filled_rounded,
                      'إلى',
                      request.endTime ?? '--:--',
                    ),
                    if (request.availabilityId != null)
                      _buildInfoRow(
                        Icons.tag_rounded,
                        'رقم الدوام الأصلي',
                        '#${request.availabilityId}',
                      ),
                    const SizedBox(height: 40),
                    _buildActionButtons(isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(String typeLabel, String staffName) {
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
              Icons.fact_check_rounded,
              color: AppColors.accentColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            typeLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'مقدم من $staffName',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentColor),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => _answer('REJECT'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'رفض',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _answer('APPROVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                disabledBackgroundColor: AppColors.accentColor.withOpacity(
                  0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.backgroundColor,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                'موافقة',
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}