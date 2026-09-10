import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/businessCubit/business_get_all_staff_cubit.dart';
import '../../../cubits/businessCubit/delete_staff_cubit.dart';
import '../../../cubits/results_state.dart';
import '../../../main.dart';
import '../../../models/deleteStaff/delete_staff_model.dart';
import '../../../models/getAllStaff/get_staff_model.dart';

class GetStaffScreen extends StatefulWidget {
  const GetStaffScreen({super.key});

  @override
  State<GetStaffScreen> createState() => _GetStaffScreenState();
}

class _GetStaffScreenState extends State<GetStaffScreen> {
  late final GetStaffCubit _getStaffCubit;
  late final DeleteStaffCubit _deleteStaffCubit;

  @override
  void initState() {
    super.initState();
    _getStaffCubit = getIt<GetStaffCubit>();
    _deleteStaffCubit = getIt<DeleteStaffCubit>();
    _getStaffCubit.fetchStaff();
  }

  @override
  void dispose() {
    _getStaffCubit.close();
    _deleteStaffCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // استماع لحالة جلب الموظفين
        BlocListener<GetStaffCubit, ResultState<GetStaffModel>>(
          bloc: _getStaffCubit,
          listener: (context, state) {
            state.whenOrNull(
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            );
          },
        ),
        // استماع لحالة طرد الموظف
        BlocListener<DeleteStaffCubit, ResultState<DeleteStaffModel>>(
          bloc: _deleteStaffCubit,
          listener: (context, state) {
            state.whenOrNull(
              loading: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('جاري إنهاء الخدمات...'),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundColor,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.cardColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              success: (data) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      data.message ?? 'تم إنهاء خدمات الموظف بنجاح',
                      textAlign: TextAlign.right,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                // إعادة جلب القائمة بعد النجاح لتحديث الحالة في الواجهة
                _getStaffCubit.fetchStaff();
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
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
          title: Text(
            'فريق العمل',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<GetStaffCubit, ResultState<GetStaffModel>>(
          bloc: _getStaffCubit,
          builder: (context, state) {
            return state.when(
              idle: () => const SizedBox.shrink(),
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.accentColor),
              ),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.redAccent.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _getStaffCubit.fetchStaff(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyle(color: AppColors.backgroundColor),
                      ),
                    ),
                  ],
                ),
              ),
              success: (data) {
                final staffList = data.data ?? [];

                if (staffList.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.accentColor,
                  backgroundColor: AppColors.cardColor,
                  onRefresh: () async => _getStaffCubit.fetchStaff(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: staffList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final staff = staffList[index];
                      return _buildStaffCard(staff);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardColor,
              border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 50,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا يوجد موظفين حالياً',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتوليد كود دعوة لإضافة حلاقين إلى المحل',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffData staff) {
    final bool isActive = staff.active ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.accentColor.withOpacity(0.2)
              : Colors.redAccent.withOpacity(0.2),
        ),
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
          // 1. زر الخيارات (أقصى اليمين) إذا كان الموظف نشطاً
          if (isActive)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              color: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.accentColor.withOpacity(0.2)),
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmationDialog(staff);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'إنهاء الخدمات',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.person_remove_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),

          if (isActive) const SizedBox(width: 8),

          // 2. معلومات الموظف (الاسم، البريد، وحالة منتهي الخدمة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isActive) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'منتهي الخدمة',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      staff.user?.name ?? 'بدون اسم',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  staff.user?.email ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // 3. الأيقونة الخاصة بالموظف (أقصى اليسار داخل البطاقة)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.accentColor.withOpacity(0.12)
                  : Colors.redAccent.withOpacity(0.12),
              border: Border.all(
                color: isActive
                    ? AppColors.accentColor.withOpacity(0.3)
                    : Colors.redAccent.withOpacity(0.3),
              ),
            ),
            child: Icon(
              Icons.content_cut_rounded,
              color: isActive ? AppColors.accentColor : Colors.redAccent,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(StaffData staff) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'إنهاء خدمات الموظف؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'هل أنت متأكد من طرد "${staff.user?.name}"؟ سيتم تحويل حروجه المعلقة للحلاقين الآخرين.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          if (staff.id != null) {
                            _deleteStaffCubit.deleteStaff(staff.id!);
                          }
                        },
                        child: const Text(
                          'تأكيد الطرد',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
