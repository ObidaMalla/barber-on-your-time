import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/notificateionService/notificationService.dart';
import 'cubits/availabilityCubit/add_availability_cubit.dart';
import 'cubits/availabilityCubit/free_slots_cubit.dart';
import 'cubits/availabilityCubit/get_availability_cubit.dart';
import 'cubits/availabilityCubit/request_availability_cubit.dart';
import 'cubits/availabilityCubit/request_deletion_cubit.dart';
import 'cubits/availabilityCubit/staff_free_slots_cubit.dart';
import 'cubits/availabilityOwnerCubit/answer_request_cubit.dart';
import 'cubits/availabilityOwnerCubit/owner_pending_requests_cubit.dart';
import 'cubits/bookingCubit/cancel_booking_cubit.dart';
import 'cubits/bookingCubit/complete_booking_cubit.dart';
import 'cubits/bookingCubit/create_booking_cubit.dart';
import 'cubits/bookingCubit/get_my_bookings_cubit.dart';
import 'cubits/bookingCubit/get_staff_bookings_cubit.dart';
import 'cubits/bookingCubit/owner_staff_stats_cubit.dart';
import 'cubits/bookingCubit/request_completion_cubit.dart';
import 'cubits/bookingCubit/respond_booking_cubit.dart';
import 'cubits/bookingCubit/staff_statistics_cubit.dart';
import 'cubits/businessCubit/business_cubit.dart';
import 'cubits/businessCubit/business_get_all_staff_cubit.dart';
import 'cubits/businessCubit/delete_staff_cubit.dart';
import 'cubits/businessCubit/get_all_businesses_cubit.dart';
import 'cubits/businessCubit/get_staff_by_business_id_cubit.dart';
import 'cubits/joinBusinessCubit/join_business_cubit.dart';
import 'cubits/loginCubit/login_cubit.dart';
import 'cubits/logoutCubit/logout_cubit.dart';
import 'cubits/notifications/notifications_list_cubit.dart';
import 'cubits/notifications/unread_count_cubit.dart';
import 'cubits/profileCubit/profile_cubit.dart';
import 'cubits/profileCubit/updateDataProfileCubit/update_data_profile_cubit.dart';
import 'cubits/profileCubit/updatePasswordProfileCubit/update_password_cubit.dart';
import 'cubits/registerCubit/register_cubit.dart';
import 'cubits/servicesCubit/add_service_cubit.dart';
import 'cubits/servicesCubit/deleteServiceCubit.dart';
import 'cubits/servicesCubit/get_services_by_business_cubit.dart';
import 'cubits/servicesCubit/get_services_cubit.dart';
import 'cubits/servicesCubit/updateServiceCubit/update_service_cubit.dart';
import 'cubits/staffInviteCubit/staff_invite_cubit.dart';
import 'injections/bootStrap/bootStrap_all_injection.dart';
import 'interfaces/SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase
  await Firebase.initializeApp();

  // 2. تهيئة الـ Dependency Injection
  setupDependencies();

  // 3. تشغيل الواجهات مباشرة لمنع التجميد الشاشة السوداء
  runApp(const MyApp());

  // 4. تهيئة الإشعارات وجلب الـ Token آمن في الخلفية
  _initFcmTokenSafely();
}

/// دالة جلب الـ Token في الخلفية مع حماية من الأخطاء لتفادي تعليق الشاشة
Future<void> _initFcmTokenSafely() async {
  try {
    await NotificationService.initialize();

    String? fcmToken = await NotificationService.getFcmToken();

    debugPrint('==================== FCM TOKEN ====================');
    debugPrint(fcmToken ?? 'Token is null');
    debugPrint('==================================================');
  } catch (e) {
    debugPrint('⚠️ تعذر جلب FCM Token حالياً (سيتم الإرسال أثناء Login): $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(create: (_) => getIt<RegisterCubit>()),
        BlocProvider<LoginCubit>(create: (_) => getIt<LoginCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()),
        BlocProvider<UpdateProfileCubit>(
          create: (_) => getIt<UpdateProfileCubit>(),
        ),
        BlocProvider<UpdatePasswordCubit>(
          create: (_) => getIt<UpdatePasswordCubit>(),
        ),
        BlocProvider<CreateBusinessCubit>(
          create: (_) => getIt<CreateBusinessCubit>(),
        ),
        BlocProvider<StaffInviteCubit>(
          create: (_) => getIt<StaffInviteCubit>(),
        ),
        BlocProvider<JoinBusinessCubit>(
          create: (_) => getIt<JoinBusinessCubit>(),
        ),
        BlocProvider<GetStaffCubit>(create: (_) => getIt<GetStaffCubit>()),
        BlocProvider<DeleteStaffCubit>(
          create: (_) => getIt<DeleteStaffCubit>(),
        ),
        BlocProvider<GetServicesCubit>(
          create: (_) => getIt<GetServicesCubit>(),
        ),
        BlocProvider<AddServiceCubit>(create: (_) => getIt<AddServiceCubit>()),
        BlocProvider<UpdateServiceCubit>(
          create: (_) => getIt<UpdateServiceCubit>(),
        ),
        BlocProvider<DeleteServiceCubit>(
          create: (_) => getIt<DeleteServiceCubit>(),
        ),
        BlocProvider<GetAvailabilityCubit>(
          create: (_) => getIt<GetAvailabilityCubit>(),
        ),
        BlocProvider<AddAvailabilityCubit>(
          create: (_) => getIt<AddAvailabilityCubit>(),
        ),
        BlocProvider<RequestAvailabilityCubit>(
          create: (_) => getIt<RequestAvailabilityCubit>(),
        ),
        /* BlocProvider<GetPendingRequestsCubit>(
          create: (_) => getIt<GetPendingRequestsCubit>(),
        ),*/
        BlocProvider<RequestDeletionCubit>(
          create: (_) => getIt<RequestDeletionCubit>(),
        ),
        BlocProvider<OwnerPendingRequestsCubit>(
          create: (_) => getIt<OwnerPendingRequestsCubit>(),
        ),
        BlocProvider<AnswerRequestCubit>(
          create: (_) => getIt<AnswerRequestCubit>(),
        ),
        BlocProvider<CreateBookingCubit>(
          create: (_) => getIt<CreateBookingCubit>(),
        ),
        BlocProvider<GetAllBusinessesCubit>(
          create: (_) => getIt<GetAllBusinessesCubit>(),
        ),
        BlocProvider<GetServicesByBusinessCubit>(
          create: (_) => getIt<GetServicesByBusinessCubit>(),
        ),
        BlocProvider<GetStaffByBusinessIdCubit>(
          create: (_) => getIt<GetStaffByBusinessIdCubit>(),
        ),
        BlocProvider<GetStaffBookingsCubit>(
          create: (_) => getIt<GetStaffBookingsCubit>(),
        ),
        BlocProvider<RespondBookingCubit>(
          create: (_) => getIt<RespondBookingCubit>(),
        ),
        BlocProvider<GetMyBookingsCubit>(
          create: (_) => getIt<GetMyBookingsCubit>(),
        ),
        BlocProvider<CancelBookingCubit>(
          create: (_) => getIt<CancelBookingCubit>(),
        ),
        BlocProvider<LogoutCubit>(create: (_) => getIt<LogoutCubit>()),

        BlocProvider<FreeSlotsCubit>(create: (_) => getIt<FreeSlotsCubit>()),
        BlocProvider<StaffFreeSlotsCubit>(
          create: (_) => getIt<StaffFreeSlotsCubit>(),
        ),
        BlocProvider<RequestCompletionCubit>(
          create: (_) => getIt<RequestCompletionCubit>(),
        ),
        BlocProvider<CompleteBookingCubit>(
          create: (_) => getIt<CompleteBookingCubit>(),
        ),
        BlocProvider<UnreadCountCubit>(
          create: (_) => getIt<UnreadCountCubit>(),
        ),
        BlocProvider<NotificationsListCubit>(
          create: (_) => getIt<NotificationsListCubit>(),
        ),
        BlocProvider<StaffStatisticsCubit>(
          create: (_) => getIt<StaffStatisticsCubit>(),
        ),

        BlocProvider<OwnerStaffStatsCubit>(
          create: (_) => getIt<OwnerStaffStatsCubit>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF4F46E5),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
