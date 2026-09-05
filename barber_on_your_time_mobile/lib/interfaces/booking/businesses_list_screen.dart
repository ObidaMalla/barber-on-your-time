import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/businessCubit/get_all_businesses_cubit.dart';
import '../../cubits/results_state.dart';
import '../../injections/bootStrap/auth/login_injection.dart';
import '../../models/business/get_all_businesses_model.dart';
import 'create_booking_screen.dart';

class BusinessesListScreen extends StatefulWidget {
  const BusinessesListScreen({super.key});

  @override
  State<BusinessesListScreen> createState() => _BusinessesListScreenState();
}

class _BusinessesListScreenState extends State<BusinessesListScreen> {
  late final GetAllBusinessesCubit _businessesCubit;

  @override
  void initState() {
    super.initState();
    _businessesCubit = getIt<GetAllBusinessesCubit>();
    _businessesCubit.getAllBusinesses();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
          'اختر صالونك',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child:
            BlocConsumer<
              GetAllBusinessesCubit,
              ResultState<GetAllBusinessesModel>
            >(
              bloc: _businessesCubit,
              listener: (context, state) {
                state.whenOrNull(
                  error: (message) =>
                      _showSnackBar(message, AppColors.errorColor),
                );
              },
              builder: (context, state) {
                return state.when(
                  idle: () => const SizedBox.shrink(),
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                    ),
                  ),
                  error: (message) => Center(
                    child: Text(
                      message,
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ),
                  success: (data) {
                    final businesses = data.data ?? [];
                    if (businesses.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد صالونات متاحة حالياً',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.accentColor,
                      onRefresh: () async =>
                          _businessesCubit.getAllBusinesses(),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: businesses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final business = businesses[index];
                          return _buildBusinessCard(context, business);
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

  Widget _buildBusinessCard(BuildContext context, BusinessData business) {
    final businessName = business.name ?? 'بدون اسم';
    final ownerName = business.owner?.name ?? 'غير معروف';

    return InkWell(
      onTap: () {
        if (business.id == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateBookingScreen(businessId: business.id!),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_rounded,
                color: AppColors.accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          business.address ?? 'العنوان غير موضح',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'المالك: $ownerName',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.accentColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
