import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/color/colors.dart';
import '../../../cubits/bookingCubit/request_completion_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../injections/bootStrap/auth/login_injection.dart';
import '../../../models/booking/getMyBookings/get_my_bookings_model.dart';
import '../../../models/booking/requestCompletion/request_completion_model.dart';
import '../../../token/token_storage.dart';

class BookingDetailsScreen extends StatefulWidget {
  final MyBookingData booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final RequestCompletionCubit _requestCompletionCubit;
  late final AnimationController _glowController;
  bool _isRequestSent = false;

  @override
  void initState() {
    super.initState();
    _requestCompletionCubit = getIt<RequestCompletionCubit>();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _loadCompletionRequestStatus();
  }

  Future<void> _loadCompletionRequestStatus() async {
    if (widget.booking.id != null) {
      final isSent = await TokenStorage.isCompletionRequested(
        widget.booking.id!,
      );
      if (mounted) {
        setState(() {
          _isRequestSent = isSent;
        });
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _formatDateTime(String? isoUtc) {
    if (isoUtc == null) return 'غير محدد';
    final utcDate = DateTime.parse(isoUtc);
    final localDate = utcDate.toLocal();
    return DateFormat('yyyy-MM-dd  •  hh:mm a').format(localDate);
  }

  void _confirmRequestCompletion() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'تأكيد استلام الخدمة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'هل أنت متأكد أنك استلمت الخدمة؟ سيتم تنبيه الحلاق لإعطائك رمز التأكيد.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'تراجع',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (widget.booking.id != null) {
                    _requestCompletionCubit.requestCompletion(
                      bookingId: widget.booking.id!,
                    );
                  }
                },
                child: const Text(
                  'نعم، أرسل التنبيه',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isConfirmed = booking.status == 'CONFIRMED';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تفاصيل الحجز',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body:
            BlocConsumer<
              RequestCompletionCubit,
              ResultState<RequestCompletionModel>
            >(
              bloc: _requestCompletionCubit,
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
                  success: (data) async {
                    Navigator.pop(context);

                    if (widget.booking.id != null) {
                      await TokenStorage.saveCompletionRequested(
                        widget.booking.id!,
                      );
                      if (mounted) {
                        setState(() {
                          _isRequestSent = true;
                        });
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(data.message ?? 'تم تنبيه الحلاق بنجاح'),
                        backgroundColor: AppColors.successColor,
                      ),
                    );
                    _requestCompletionCubit.resetState();
                  },
                  error: (message) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                    _requestCompletionCubit.resetState();
                  },
                );
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentColor
                                            .withOpacity(0.15),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: SweepGradient(
                                        center: Alignment.center,
                                        transform: GradientRotation(
                                          _glowController.value * 6.28,
                                        ),
                                        colors: [
                                          AppColors.accentColor.withOpacity(
                                            0.1,
                                          ),
                                          AppColors.accentColor,
                                          AppColors.accentColor.withOpacity(
                                            0.9,
                                          ),
                                          AppColors.accentColor.withOpacity(
                                            0.1,
                                          ),
                                        ],
                                        stops: const [0.0, 0.45, 0.55, 1.0],
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                              booking.service?.name ??
                                                  'خدمة غير محددة',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Divider(
                                            color: AppColors.textPrimary
                                                .withOpacity(0.08),
                                            height: 1,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDetailRow(
                                            Icons.person_outline,
                                            'الحلاق',
                                            booking.staff?.user?.name ??
                                                'غير محدد',
                                          ),
                                          _buildDetailRow(
                                            Icons.payments_outlined,
                                            'السعر',
                                            '${booking.service?.price ?? 0} ل.س',
                                          ),
                                          _buildDetailRow(
                                            Icons.timer_outlined,
                                            'المدة',
                                            '${booking.service?.durationMinutes ?? 0} دقيقة',
                                          ),
                                          _buildDetailRow(
                                            Icons.schedule_rounded,
                                            'الموعد',
                                            _formatDateTime(booking.startTime),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      if (isConfirmed) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRequestSent
                                  ? Colors.grey
                                  : AppColors.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: _isRequestSent ? 0 : 4,
                            ),
                            onPressed: _isRequestSent
                                ? null
                                : _confirmRequestCompletion,
                            icon: Icon(
                              _isRequestSent
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isRequestSent
                                  ? 'تم طلب تأكيد الخدمة'
                                  : 'تم استلام الخدمة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.accentColor),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
