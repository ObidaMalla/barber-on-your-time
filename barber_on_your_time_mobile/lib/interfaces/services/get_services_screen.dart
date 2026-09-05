import 'package:barber_on_your_time/interfaces/services/update_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/colors.dart';
import '../../../cubits/results_state.dart';
import '../../../main.dart';
import '../../cubits/servicesCubit/get_services_cubit.dart';
import '../../models/services/getServices/get_services_model.dart';
import '../../repo/response_services/delete_service_repo.dart';
import 'add_service_screen.dart';

class GetServicesScreen extends StatefulWidget {
  final String? userRole; // OWNER / STAFF / CUSTOMER

  const GetServicesScreen({super.key, this.userRole});

  @override
  State<GetServicesScreen> createState() => _GetServicesScreenState();
}

class _GetServicesScreenState extends State<GetServicesScreen> {
  late final GetServicesCubit _getServicesCubit;

  // ===== حالة وضع التحديد المتعدد =====
  bool _isSelectionMode = false;
  final Set<int> _selectedServiceIds = {};
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _getServicesCubit = getIt<GetServicesCubit>();
    _getServicesCubit.fetchServices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isOwner => widget.userRole == null || widget.userRole == 'OWNER';

  // 🔄 الانتقال لشاشة الإضافة
  Future<void> _navigateToAddService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddServiceScreen()),
    );
    if (result == true && mounted) {
      _getServicesCubit.fetchServices();
    }
  }

  Future<void> _navigateToEditService(ServiceData service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(service: service),
      ),
    );
    if (result == true && mounted) {
      _getServicesCubit.fetchServices();
    }
  }

  // ===== وضع التحديد =====
  void _enterSelectionMode(int serviceId) {
    setState(() {
      _isSelectionMode = true;
      _selectedServiceIds.add(serviceId);
    });
  }

  void _toggleSelection(int serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
      // لو ما ضل محدد ولا عنصر، منطلع من وضع التحديد تلقائياً
      if (_selectedServiceIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedServiceIds.clear();
    });
  }

  // ===== الحذف الجماعي =====
  Future<void> _confirmDeleteSelected() async {
    final count = _selectedServiceIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: Colors.redAccent, size: 40),
              const SizedBox(height: 16),
              Text(
                count == 1 ? 'حذف الخدمة المحددة؟' : 'حذف $count خدمات؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هاد الإجراء لا يمكن التراجع عنه',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('حذف'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      _deleteSelected();
    }
  }

  Future<void> _deleteSelected() async {
    setState(() => _isDeleting = true);

    final deleteRepo = getIt<DeleteServiceRepo>();
    int successCount = 0;
    String? lastError;

    for (final id in _selectedServiceIds) {
      try {
        await deleteRepo.deleteService(serviceId: id);
        successCount++;
      } catch (e) {
        lastError = e is String ? e : e.toString();
      }
    }

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
      _isSelectionMode = false;
      _selectedServiceIds.clear();
    });

    if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف $successCount خدمة بنجاح'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
    if (lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lastError),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }

    _getServicesCubit.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSelectionMode) {
          _exitSelectionMode();
          return false;
        }
        return true;
      },
      child: BlocListener<GetServicesCubit, ResultState<GetServicesModel>>(
        bloc: _getServicesCubit,
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
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: _isSelectionMode
              ? _buildSelectionAppBar()
              : _buildNormalAppBar(),

          floatingActionButton: (_isOwner && !_isSelectionMode)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: FloatingActionButton.extended(
                    onPressed: _navigateToAddService,
                    backgroundColor: AppColors.accentColor,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    icon: Icon(
                      Icons.add_rounded,
                      color: AppColors.backgroundColor,
                      size: 22,
                    ),
                    label: Text(
                      'إضافة خدمة',
                      style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : null,

          body: Stack(
            children: [
              BlocBuilder<GetServicesCubit, ResultState<GetServicesModel>>(
                bloc: _getServicesCubit,
                builder: (context, state) {
                  return state.when(
                    idle: () => const SizedBox.shrink(),
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                      ),
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
                            onPressed: () => _getServicesCubit.fetchServices(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إعادة المحاولة',
                              style: TextStyle(
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    success: (data) {
                      final servicesList = data.data ?? [];

                      if (servicesList.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        color: AppColors.accentColor,
                        backgroundColor: AppColors.cardColor,
                        onRefresh: () async =>
                            _getServicesCubit.fetchServices(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                          itemCount: servicesList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final service = servicesList[index];
                            return _buildServiceCard(service);
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              // ===== طبقة تحميل أثناء الحذف الجماعي =====
              if (_isDeleting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== AppBar العادي =====
  AppBar _buildNormalAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      title: Text(
        'خدمات المحل',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => _getServicesCubit.fetchServices(),
          icon: Icon(Icons.refresh_rounded, color: AppColors.accentColor),
        ),
      ],
    );
  }

  // ===== AppBar وضع التحديد =====
  AppBar _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardColor,
      elevation: 0,
      leading: IconButton(
        onPressed: _exitSelectionMode,
        icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
      ),
      title: Text(
        '${_selectedServiceIds.length} محدد',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _selectedServiceIds.isNotEmpty
              ? _confirmDeleteSelected
              : null,
          icon: Icon(
            Icons.delete_outline_rounded,
            color: _selectedServiceIds.isNotEmpty
                ? Colors.redAccent
                : AppColors.textSecondary.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 8),
      ],
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
              Icons.design_services_rounded,
              size: 50,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا يوجد خدمات مضافة حالياً',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة خدمات جديدة ليعرضها الزبائن في التطبيق',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceData service) {
    final serviceId = service.id ?? -1;
    final isSelected = _selectedServiceIds.contains(serviceId);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(serviceId);
        } else if (_isOwner) {
          _navigateToEditService(service);
        }
      },
      onLongPress: _isOwner ? () => _enterSelectionMode(serviceId) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentColor.withOpacity(0.10)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accentColor
                : AppColors.accentColor.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
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
            // ===== دائرة التحديد - تظهر بس بوضع التحديد =====
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSelectionMode
                  ? Padding(
                      key: const ValueKey('selector'),
                      padding: const EdgeInsets.only(right: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.accentColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentColor
                                : AppColors.textSecondary,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.backgroundColor,
                              )
                            : null,
                      ),
                    )
                  : const SizedBox(key: ValueKey('empty'), width: 0),
            ),

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentColor.withOpacity(0.12),
                border: Border.all(
                  color: AppColors.accentColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.cut_rounded,
                color: AppColors.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name ?? 'بدون اسم',
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
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes ?? 0} دقيقة',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                '${service.price ?? 0} \$',
                style: TextStyle(
                  color: AppColors.accentColor,
                  fontSize: 14,
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
