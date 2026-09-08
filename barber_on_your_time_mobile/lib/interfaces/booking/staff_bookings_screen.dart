import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/bookingCubit/get_staff_bookings_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import 'bookingDetails/booking_details_screen.dart';

class StaffBookingsScreen extends StatefulWidget {
  const StaffBookingsScreen({super.key});

  @override
  State<StaffBookingsScreen> createState() => _StaffBookingsScreenState();
}

class _StaffBookingsScreenState extends State<StaffBookingsScreen> {
  final GetStaffBookingsCubit _cubit = getIt<GetStaffBookingsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.fetchStaffBookings();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return AppColors.successColor;
      case 'PENDING':
        return Colors.orange;
      case 'NEEDS_OWNER':
        return AppColors.accentColor;
      case 'CANCELLED':
        return AppColors.errorColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return 'مؤكد';
      case 'PENDING':
        return 'بانتظار الرد';
      case 'NEEDS_OWNER':
        return 'يحتاج تدخل المدير';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status ?? '';
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'حجوزاتي',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _cubit.fetchStaffBookings(),
            icon: Icon(Icons.refresh_rounded, color: AppColors.accentColor),
          ),
        ],
      ),
      body:
          BlocBuilder<
            GetStaffBookingsCubit,
            ResultState<GetStaffBookingsModel>
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
                error: (message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                success: (data) {
                  final list = data.data ?? [];
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 70,
                            color: AppColors.textSecondary.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ما عندك حجوزات حالياً',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // الأحدث أول
                  final sorted = List<StaffBookingData>.from(list)
                    ..sort(
                      (a, b) =>
                          (b.startTime ?? '').compareTo(a.startTime ?? ''),
                    );

                  return RefreshIndicator(
                    color: AppColors.accentColor,
                    backgroundColor: AppColors.cardColor,
                    onRefresh: () async => _cubit.fetchStaffBookings(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildBookingCard(sorted[index]);
                      },
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildBookingCard(StaffBookingData booking) {
    final statusColor = _statusColor(booking.status);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: booking),
          ),
        );
        if (result == true && mounted) {
          _cubit.fetchStaffBookings();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accentColor.withOpacity(0.15),
                  child: Text(
                    (booking.customer?.name?.isNotEmpty == true)
                        ? booking.customer!.name![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customer?.name ?? 'عميل',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.service?.name ?? '',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(booking.startTime),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (booking.service?.price != null)
                  Text(
                    '${booking.service!.price} \$',
                    style: TextStyle(
                      color: AppColors.accentColor,
                      fontSize: 13,
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
