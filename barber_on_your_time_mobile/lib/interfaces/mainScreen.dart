import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/color/colors.dart';
import 'Profile/ProfileScreen.dart';
import 'availability/freeSlots/freeSlotsScreen.dart';
import 'availability/get_availability_screen.dart';
import 'booking/businesses_list_screen.dart';
import 'booking/my_bookings_screen.dart';
import 'booking/staff_bookings_screen.dart';
import 'createBusinessScreen/GetStaffScreen.dart';
import 'createBusinessScreen/businessScreen.dart';
import 'homePage/homePageScreen.dart';
import 'ownerRequests/owner_pending_requests_screen.dart';
import 'services/get_services_screen.dart';

class MainScreen extends StatefulWidget {
  final String userRole; // OWNER / STAFF / CUSTOMER

  const MainScreen({super.key, required this.userRole});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final PageController _pageController;

  late final List<Widget> _pages;
  late final List<_NavItemData> _navItems;

  late final AnimationController _glowController;

  // يمنع فتح أكثر من Dialog بنفس الوقت
  bool _isExitDialogShowing = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // ============================================================
    // PAGES
    // ============================================================

    _pages = [
      // OWNER
      if (widget.userRole == 'OWNER') const HomeScreen(),

      // STAFF
      if (widget.userRole == 'STAFF') const StaffBookingsScreen(),

      // CUSTOMER
      if (widget.userRole == 'CUSTOMER') const MyBookingsScreen(),

      // OWNER
      if (widget.userRole == 'OWNER') const GetServicesScreen(),

      if (widget.userRole == 'OWNER') const OwnerPendingRequestsScreen(),

      if (widget.userRole == 'OWNER') const GetStaffScreen(),

      // STAFF
      if (widget.userRole == 'STAFF') const GetAvailabilityScreen(),
      if (widget.userRole == 'STAFF')
        const FreeSlotsScreen(), // 👈 إضافة الشاشة هنا بعد أوقاتي
      // CUSTOMER
      if (widget.userRole == 'CUSTOMER') const BusinessesListScreen(),

      if (widget.userRole == 'CUSTOMER') const BusinessOnboardingScreen(),

      // ALL
      const ProfileScreen(),
    ];

    // ============================================================
    // NAV ITEMS
    // ============================================================

    _navItems = [
      // FIRST
      _NavItemData(
        icon: widget.userRole == 'OWNER'
            ? Icons.home_rounded
            : Icons.calendar_month_rounded,
        label: widget.userRole == 'OWNER' ? 'الرئيسية' : 'حجوزاتي',
      ),

      // OWNER
      if (widget.userRole == 'OWNER')
        const _NavItemData(
          icon: Icons.cleaning_services_rounded,
          label: 'الخدمات',
        ),

      if (widget.userRole == 'OWNER')
        const _NavItemData(
          icon: Icons.pending_actions_rounded,
          label: 'الطلبات',
        ),

      if (widget.userRole == 'OWNER')
        const _NavItemData(icon: Icons.badge_rounded, label: 'الموظفين'),

      // STAFF
      if (widget.userRole == 'STAFF')
        const _NavItemData(
          icon: Icons.access_time_filled_rounded,
          label: 'أوقاتي',
        ),

      if (widget.userRole == 'STAFF')
        const _NavItemData(
          icon: Icons.event_available_rounded,
          label: 'المتاحة', // 👈 إضافة التبويب في الشريط السفلي
        ),

      // CUSTOMER
      if (widget.userRole == 'CUSTOMER')
        const _NavItemData(icon: Icons.storefront_rounded, label: 'الصالونات'),

      if (widget.userRole == 'CUSTOMER')
        const _NavItemData(icon: Icons.store_rounded, label: 'إنشاء محل'),

      // PROFILE
      const _NavItemData(icon: Icons.person_rounded, label: 'الملف الشخصي'),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();

    super.dispose();
  }

  // ============================================================
  // ANDROID BACK BUTTON
  // ============================================================

  Future<void> _handleBackButton() async {
    if (_currentIndex != 0) {
      _onTabTapped(0);
      return;
    }

    if (_isExitDialogShowing) {
      return;
    }

    _isExitDialogShowing = true;

    final shouldExit = await _showExitConfirmationDialog();

    _isExitDialogShowing = false;

    if (!mounted) {
      return;
    }

    if (shouldExit) {
      await SystemNavigator.pop();
    }
  }

  // ============================================================
  // EXIT DIALOG
  // ============================================================

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.accentColor.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 35,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.05),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentColor.withOpacity(0.10),
                    border: Border.all(
                      color: AppColors.accentColor.withOpacity(0.20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(0.10),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.accentColor,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'إغلاق التطبيق؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'هل أنت متأكد من رغبتك في إغلاق التطبيق؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _dialogButton(
                        label: 'إلغاء',
                        filled: false,
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogButton(
                        label: 'خروج',
                        filled: true,
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
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

    return result ?? false;
  }

  Widget _dialogButton({
    required String label,
    required bool filled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: Material(
        color: filled ? AppColors.accentColor : AppColors.inputColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled
                    ? AppColors.backgroundColor
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAB
  // ============================================================

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _handleBackButton();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBody: true,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: AppColors.accentColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index: index, item: _navItems[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required _NavItemData item}) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowValue = isSelected ? _glowController.value : 0.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: isSelected
                  ? AppColors.accentColor.withOpacity(0.12)
                  : Colors.transparent,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(
                          0.15 + (glowValue * 0.15),
                        ),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: isSelected ? 22 : 20,
                  color: isSelected
                      ? AppColors.accentColor
                      : AppColors.textSecondary.withOpacity(0.6),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.accentColor
                        : AppColors.textSecondary.withOpacity(0.6),
                    fontSize: isSelected ? 10 : 9,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({required this.icon, required this.label});
}
