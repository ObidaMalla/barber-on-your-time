// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../core/color/colors.dart';
// import '../../cubits/availabilityCubit/get_availability_cubit.dart';
// import '../../cubits/availabilityCubit/get_pending_requests_cubit.dart';
// import '../../cubits/availabilityCubit/request_deletion_cubit.dart';
// import '../../cubits/results_state.dart';
// import '../../injections/bootStrap/auth/login_injection.dart';
// import '../../models/availability/getAvailability/get_availability_model.dart';
// import '../../models/availability/requestAvailability/get_pending_requests_model.dart';
// import '../../models/availability/requestAvailability/request_availability_model.dart';
// import '../../models/availability/requestDeletion/request_deletion_model.dart';
// import 'add_availability_screen.dart';
// import 'request_availability_screen.dart';
//
// class GetAvailabilityScreen extends StatefulWidget {
//   const GetAvailabilityScreen({super.key});
//
//   @override
//   State<GetAvailabilityScreen> createState() => _GetAvailabilityScreenState();
// }
//
// class _GetAvailabilityScreenState extends State<GetAvailabilityScreen> {
//   final GetAvailabilityCubit _availabilityCubit = getIt<GetAvailabilityCubit>();
//   final GetPendingRequestsCubit _pendingCubit =
//       getIt<GetPendingRequestsCubit>();
//   final RequestDeletionCubit _deletionCubit = getIt<RequestDeletionCubit>();
//
//   static const Map<int, String> _daysMap = {
//     0: 'الأحد',
//     1: 'الإثنين',
//     2: 'الثلاثاء',
//     3: 'الأربعاء',
//     4: 'الخميس',
//     5: 'الجمعة',
//     6: 'السبت',
//   };
//
//   List<AvailabilityData> _availabilityList = [];
//   List<RequestAvailabilityData> _pendingRequests = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAll();
//   }
//
//   @override
//   void dispose() {
//     _availabilityCubit.close();
//     _pendingCubit.close();
//     _deletionCubit.close();
//     super.dispose();
//   }
//
//   Future<void> _loadAll() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     await Future.wait([
//       _availabilityCubit.fetchAvailability(),
//       _pendingCubit.fetchPendingRequests(),
//     ]);
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   String _getDayName(int? dayIndex) {
//     if (dayIndex == null) return 'غير محدد';
//     return _daysMap[dayIndex] ?? 'يوم غير معروف';
//   }
//
//   RequestAvailabilityData? _pendingFor(int? availabilityId) {
//     if (availabilityId == null) return null;
//     for (final req in _pendingRequests) {
//       if (req.availabilityId == availabilityId) return req;
//     }
//     return null;
//   }
//
//   Future<void> _navigateToRequestEdit(AvailabilityData item) async {
//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => RequestAvailabilityScreen(currentAvailability: item),
//       ),
//     );
//
//     if (result == true && mounted) {
//       _loadAll();
//     }
//   }
//
//   Future<void> _confirmDelete(AvailabilityData item) async {
//     if (item.id == null) return;
//
//     final dayName = _getDayName(item.dayOfWeek);
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: AppColors.cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(
//           'طلب حذف الدوام',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Text(
//           'بدك تبعت طلب حذف دوام $dayName؟ الطلب رح يروح لصاحب المحل للموافقة، وما رح يتحذف فعليًا إلا بعد موافقته.',
//           style: TextStyle(color: AppColors.textSecondary, height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, false),
//             child: Text(
//               'إلغاء',
//               style: TextStyle(color: AppColors.textSecondary),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, true),
//             child: Text(
//               'إرسال طلب الحذف',
//               style: TextStyle(
//                 color: AppColors.errorColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       _deletionCubit.requestDeletion(availabilityId: item.id!);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<GetAvailabilityCubit, ResultState<GetAvailabilityModel>>(
//           bloc: _availabilityCubit,
//           listener: (context, state) {
//             state.whenOrNull(
//               success: (data) {
//                 setState(() => _availabilityList = data.data ?? []);
//               },
//               error: (message) {
//                 setState(() => _errorMessage = message);
//               },
//             );
//           },
//         ),
//         BlocListener<
//           GetPendingRequestsCubit,
//           ResultState<GetPendingRequestsModel>
//         >(
//           bloc: _pendingCubit,
//           listener: (context, state) {
//             state.whenOrNull(
//               success: (data) {
//                 setState(() => _pendingRequests = data.data ?? []);
//               },
//             );
//           },
//         ),
//         BlocListener<RequestDeletionCubit, ResultState<RequestDeletionModel>>(
//           bloc: _deletionCubit,
//           listener: (context, state) {
//             state.whenOrNull(
//               success: (data) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(data.message ?? 'تم إرسال طلب الحذف 🎉'),
//                     backgroundColor: AppColors.successColor,
//                   ),
//                 );
//                 _deletionCubit.resetState();
//                 _loadAll();
//               },
//               error: (message) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(message),
//                     backgroundColor: AppColors.errorColor,
//                   ),
//                 );
//                 _deletionCubit.resetState();
//               },
//             );
//           },
//         ),
//       ],
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           title: Text(
//             'أوقات دوامي',
//             style: TextStyle(
//               color: AppColors.textPrimary,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: AppColors.accentColor.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.add_rounded,
//                   color: AppColors.accentColor,
//                   size: 22,
//                 ),
//               ),
//               onPressed: () async {
//                 final existingDates = _availabilityList
//                     .where((e) => e.date != null)
//                     .map((e) => DateTime.tryParse(e.date!))
//                     .whereType<DateTime>()
//                     .toList();
//
//                 final result = await Navigator.push<bool>(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AddAvailabilityScreen(
//                       existingDates: existingDates,
//                     ), // 👈 هاد التغيير المطلوب
//                   ),
//                 );
//                 if (result == true) {
//                   _loadAll();
//                 }
//               },
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
//         body: _buildBody(),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(
//         child: CircularProgressIndicator(color: AppColors.accentColor),
//       );
//     }
//
//     if (_errorMessage != null) {
//       return _buildErrorWidget(_errorMessage!);
//     }
//
//     if (_availabilityList.isEmpty) {
//       return _buildEmptyState();
//     }
//     final sortedList = List<AvailabilityData>.from(_availabilityList)
//       ..sort((a, b) {
//         final da = a.date != null ? DateTime.tryParse(a.date!) : null;
//         final db = b.date != null ? DateTime.tryParse(b.date!) : null;
//         if (da == null || db == null) return 0;
//         return da.compareTo(db);
//       });
//     return RefreshIndicator(
//       color: AppColors.accentColor,
//       backgroundColor: AppColors.cardColor,
//       onRefresh: _loadAll,
//       child: ListView.separated(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//         itemCount: sortedList.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 12),
//         itemBuilder: (context, index) {
//           final item = sortedList[index];
//           final pendingRequest = _pendingFor(item.id);
//           return _buildAvailabilityCard(item, pendingRequest);
//         },
//       ),
//     );
//   }
//
//   Widget _buildAvailabilityCard(
//     AvailabilityData item,
//     RequestAvailabilityData? pendingRequest,
//   ) {
//     final isPending = pendingRequest != null;
//     final isDeleteRequest = pendingRequest?.type == 'DELETE';
//
//     return GestureDetector(
//       onLongPress: isPending ? null : () => _confirmDelete(item),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isPending
//               ? (isDeleteRequest
//                     ? AppColors.errorColor.withOpacity(0.10)
//                     : Colors.orange.withOpacity(0.10))
//               : AppColors.cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isPending
//                 ? (isDeleteRequest
//                       ? AppColors.errorColor.withOpacity(0.5)
//                       : Colors.orange.withOpacity(0.5))
//                 : AppColors.accentColor.withOpacity(0.18),
//             width: isPending ? 1.5 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isPending
//                     ? (isDeleteRequest
//                           ? AppColors.errorColor.withOpacity(0.15)
//                           : Colors.orange.withOpacity(0.15))
//                     : AppColors.accentColor.withOpacity(0.1),
//                 border: Border.all(
//                   color: isPending
//                       ? (isDeleteRequest
//                             ? AppColors.errorColor.withOpacity(0.4)
//                             : Colors.orange.withOpacity(0.4))
//                       : AppColors.accentColor.withOpacity(0.25),
//                 ),
//               ),
//               child: Icon(
//                 isPending
//                     ? (isDeleteRequest
//                           ? Icons.delete_outline_rounded
//                           : Icons.hourglass_top_rounded)
//                     : Icons.calendar_today_rounded,
//                 color: isPending
//                     ? (isDeleteRequest ? AppColors.errorColor : Colors.orange)
//                     : AppColors.accentColor,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         _getDayName(item.dayOfWeek),
//                         style: TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       if (isPending) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isDeleteRequest
//                                 ? AppColors.errorColor.withOpacity(0.2)
//                                 : Colors.orange.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             isDeleteRequest
//                                 ? 'طلب حذف معلق'
//                                 : 'بانتظار الموافقة',
//                             style: TextStyle(
//                               color: isDeleteRequest
//                                   ? AppColors.errorColor
//                                   : Colors.orange,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.access_time_rounded,
//                         size: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${item.startTime ?? '--:--'}  إلى  ${item.endTime ?? '--:--'}',
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (isPending && !isDeleteRequest) ...[
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.arrow_forward_rounded,
//                           size: 14,
//                           color: Colors.orange,
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             '${_getDayName(pendingRequest!.dayOfWeek)}  •  ${pendingRequest.startTime ?? '--:--'} إلى ${pendingRequest.endTime ?? '--:--'}',
//                             style: TextStyle(
//                               color: Colors.orange,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//
//             // ===== أزرار التعديل والحذف (تظهر بس لو مافي طلب معلق) =====
//             if (!isPending) ...[
//               InkWell(
//                 onTap: () => _navigateToRequestEdit(item),
//                 borderRadius: BorderRadius.circular(20),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.edit_rounded,
//                     size: 18,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () => _confirmDelete(item),
//                 borderRadius: BorderRadius.circular(20),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.delete_outline_rounded,
//                     size: 18,
//                     color: AppColors.errorColor,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.event_busy_rounded,
//               size: 70,
//               color: AppColors.textSecondary.withOpacity(0.4),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'لا توجد أوقات دوام مسجلة',
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'لم يتم إدخال جدول الدوام الخاص بك بعد.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.accentColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//               ),
//               onPressed: _loadAll,
//               icon: Icon(
//                 Icons.refresh_rounded,
//                 color: AppColors.backgroundColor,
//               ),
//               label: Text(
//                 'إعادة المحاولة',
//                 style: TextStyle(
//                   color: AppColors.backgroundColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorWidget(String message) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               size: 60,
//               color: Colors.redAccent.withOpacity(0.8),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.accentColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//               ),
//               onPressed: _loadAll,
//               child: Text(
//                 'إعادة المحاولة',
//                 style: TextStyle(
//                   color: AppColors.backgroundColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
      builder: (dialogContext) => AlertDialog(
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
    );

    if (confirmed == true) {
      _deletionCubit.requestDeletion(availabilityId: item.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
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
          backgroundColor: Colors.transparent,
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: sortedList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentColor.withOpacity(0.18),
            width: 1,
          ),
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
              child: Icon(
                Icons.calendar_today_rounded,
                color: AppColors.accentColor,
                size: 22,
              ),
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
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.startTime ?? '--:--'}  إلى  ${item.endTime ?? '--:--'}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
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
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            InkWell(
              onTap: () => _confirmDelete(item),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8),
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
