import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/color/colors.dart';
import '../../cubits/logoutCubit/logout_cubit.dart';
import '../../cubits/profileCubit/profile_cubit.dart';
import '../../cubits/profileCubit/updateDataProfileCubit/update_data_profile_cubit.dart';
import '../../cubits/profileCubit/updatePasswordProfileCubit/update_password_cubit.dart';
import '../../cubits/results_state.dart';
import '../../models/logout/logout_model.dart';
import '../../models/profile/profile_model.dart';
import '../../models/profile/updateDataProfile/update_profile_model.dart';
import '../../models/profile/updatePasswordProfile/update_password_model.dart';
import '../createBusinessScreen/staffInvite/staffInviteScreen.dart';
import '../login/loginScreen.dart';

// =========================================================
// Profile Screen Implementation
// =========================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _avatarPulse;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    _avatarPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _avatarPulse.dispose();
    super.dispose();
  }

  // =========================================================
  // Logout Flow: Confirm Dialog & Navigation
  // =========================================================
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _LogoutConfirmationSheet(),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.accentColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'OWNER':
        return 'Shop Owner 👑';
      case 'STAFF':
        return 'Barber ✂️';
      case 'CUSTOMER':
      default:
        return 'Customer 💈';
    }
  }

  void _copyEmail(String email) {
    if (email.isEmpty) return;
    Clipboard.setData(ClipboardData(text: email));
    HapticFeedback.lightImpact();
    _showCopiedBubble();
  }

  void _showCopiedBubble() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CopiedBubble(onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }

  void _onAvatarTap() {
    HapticFeedback.mediumImpact();
    _avatarPulse.forward().then((_) => _avatarPulse.reverse());
  }

  Future<void> _openEditNameSheet(String currentName) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditNameSheet(
        initialName: currentName,
        onSaved: () => context.read<ProfileCubit>().fetchProfile(),
      ),
    );
  }

  Future<void> _openEditEmailSheet(String currentEmail) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditEmailSheet(
        initialEmail: currentEmail,
        onSaved: () => context.read<ProfileCubit>().fetchProfile(),
      ),
    );
  }

  Future<void> _openEditPasswordSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EditPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<ProfileCubit, ResultState<ProfileModel>>(
        listener: (context, state) {
          state.whenOrNull(success: (_) => _entryController.forward(from: 0));
        },
        builder: (context, state) {
          return state.when(
            idle: () => const SizedBox.shrink(),
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.accentColor),
            ),
            error: (message) => Center(
              child: Text(
                "حدث خطأ: $message",
                style: TextStyle(color: AppColors.accentSecondary),
              ),
            ),
            success: (profile) {
              final user = profile.data;
              final isOwner = user?.role == 'OWNER';

              return Stack(
                children: [
                  // ابحث عن هذا الجزء داخل Widget build وعدله كالتالي:
                  Positioned.fill(
                    child: Opacity(
                      opacity:
                          0.15, // تم رفع الشفافية لتظهر الأيقونات بوضوح بدلاً من 0.04
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 35,
                              crossAxisSpacing: 35,
                            ),
                        itemCount: 40,
                        itemBuilder: (context, index) {
                          final icons = [
                            Icons.content_cut_rounded,
                            Icons.brush_rounded,
                            Icons.face_retouching_natural_rounded,
                            Icons.dry_cleaning_rounded,
                          ];
                          return Icon(
                            icons[index % icons.length],
                            color: AppColors
                                .accentColor, // يمكنك استخدام اللون الذهبي بدلاً من الأبيض لبروز أكبر
                            size: 36,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentColor.withOpacity(0.12),
                            blurRadius: 100,
                            spreadRadius: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: -60,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentSecondary.withOpacity(0.1),
                            blurRadius: 90,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isOwner)
                                _InviteIconButton(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StaffInviteScreen(),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'الملف الشخصي ⚡',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    _buildHeroProfileCard(
                                      name: user?.name ?? 'عميل',
                                      onAvatarTap: _onAvatarTap,
                                      onEditName: () =>
                                          _openEditNameSheet(user?.name ?? ''),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildSettingsSection(
                                      email: user?.email ?? '',
                                      roleDisplay: _roleLabel(user?.role),
                                      onCopyEmail: () =>
                                          _copyEmail(user?.email ?? ''),
                                      onEditEmail: () => _openEditEmailSheet(
                                        user?.email ?? '',
                                      ),
                                      onEditPassword: _openEditPasswordSheet,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroProfileCard({
    required String name,
    required VoidCallback onAvatarTap,
    required VoidCallback onEditName,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: AnimatedBuilder(
              animation: _avatarPulse,
              builder: (context, child) {
                final glow = 0.5 + _avatarPulse.value * 3;
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentSecondary,
                        AppColors.accentColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(
                          glow.clamp(0.0, 1.0),
                        ),
                        blurRadius: 14 + (_avatarPulse.value * 40),
                        spreadRadius: _avatarPulse.value * 6,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.backgroundColor,
                child: Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEditName,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 15,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String email,
    required String roleDisplay,
    required VoidCallback onCopyEmail,
    required VoidCallback onEditEmail,
    required VoidCallback onEditPassword,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
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
              Icon(
                Icons.shield_outlined,
                color: AppColors.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'بيانات الحساب والأمان ✨',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'البريد الإلكتروني',
            value: email.isNotEmpty ? email : 'غير متوفر',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onCopyEmail,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _PressableChip(
                  label: 'تغيير ✏️',
                  color: AppColors.accentColor,
                  onTap: onEditEmail,
                ),
              ],
            ),
          ),
          Divider(color: AppColors.textPrimary.withOpacity(0.06), height: 24),
          _buildInfoRow(
            icon: Icons.lock_outline_rounded,
            label: 'كلمة المرور',
            value: '••••••••••••',
            trailing: _PressableChip(
              label: 'تغيير ✏️',
              color: AppColors.accentSecondary,
              onTap: onEditPassword,
            ),
          ),
          Divider(color: AppColors.textPrimary.withOpacity(0.06), height: 24),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'الدور',
            value: roleDisplay,
          ),
          Divider(color: AppColors.textPrimary.withOpacity(0.06), height: 24),
          _buildActionRow(
            icon: Icons.logout_rounded,
            label: 'تسجيل الخروج',
            color: Colors.redAccent,
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}

// =========================================================
// _LogoutConfirmationSheet Implementation (الوضع الطبيعي الاصلي)
// =========================================================
class _LogoutConfirmationSheet extends StatefulWidget {
  const _LogoutConfirmationSheet();

  @override
  State<_LogoutConfirmationSheet> createState() =>
      _LogoutConfirmationSheetState();
}

class _LogoutConfirmationSheetState extends State<_LogoutConfirmationSheet> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'تسجيل الخروج',
      icon: Icons.logout_rounded,
      accent: Colors.redAccent,
      child: BlocConsumer<LogoutCubit, ResultState<LogoutModel>>(
        listener: (context, state) async {
          state.whenOrNull(
            success: (response) async {
              if (!context.mounted) return;
              Navigator.of(context).pop(); // إغلاق الـ BottomSheet
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            error: (message) {
              setState(() => _errorMessage = message);
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'هل أنت تأكيد رغبتك في تسجيل الخروج؟ ستلاحظ توقف تنبيهاتك وتوجيهك لصفحة الدخول.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                _ErrorBanner(message: _errorMessage!),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetSubmitButton(
                      isLoading: isLoading,
                      label: 'تأكيد الخروج',
                      color: Colors.redAccent,
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        context.read<LogoutCubit>().logoutUser();
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// =========================================================
// Components / Helpers
// =========================================================

class _InviteIconButton extends StatefulWidget {
  final VoidCallback onTap;
  const _InviteIconButton({required this.onTap});

  @override
  State<_InviteIconButton> createState() => _InviteIconButtonState();
}

class _InviteIconButtonState extends State<_InviteIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glow = 0.15 + (_pulse.value * 0.15);
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentColor.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(glow),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Icon(
          Icons.person_add_alt_1_rounded,
          color: AppColors.accentColor,
          size: 20,
        ),
      ),
    );
  }
}

class _CopiedBubble extends StatefulWidget {
  final VoidCallback onDone;
  const _CopiedBubble({required this.onDone});

  @override
  State<_CopiedBubble> createState() => _CopiedBubbleState();
}

class _CopiedBubbleState extends State<_CopiedBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final opacity = t < 0.15
                ? t / 0.15
                : (t > 0.75 ? (1 - t) / 0.25 : 1.0);
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, -10 * (1 - (t < 0.15 ? t / 0.15 : 1.0))),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.backgroundColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Copied!',
                  style: TextStyle(
                    color: AppColors.backgroundColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PressableChip extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PressableChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PressableChip> createState() => _PressableChipState();
}

class _PressableChipState extends State<_PressableChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;

  const _SheetShell({
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: accent.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

InputDecoration _sheetInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.inputColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppColors.borderColor),
    enabledBorder: border(AppColors.borderColor),
    focusedBorder: border(AppColors.accentColor, 1.5),
    errorBorder: border(AppColors.errorColor),
    focusedErrorBorder: border(AppColors.errorColor, 1.5),
  );
}

class _SheetSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SheetSubmitButton({
    required this.isLoading,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          foregroundColor: AppColors.backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.backgroundColor,
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

// =========================================================
// Bottom Sheets للتعديل
// =========================================================

class _EditNameSheet extends StatefulWidget {
  final String initialName;
  final VoidCallback onSaved;

  const _EditNameSheet({required this.initialName, required this.onSaved});

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'تعديل الاسم',
      icon: Icons.badge_outlined,
      accent: AppColors.accentColor,
      child: BlocConsumer<UpdateProfileCubit, ResultState<UpdateProfileModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (response) {
              setState(() => _errorMessage = null);
              widget.onSaved();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message ?? 'تم تحديث الاسم بنجاح'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            error: (message) {
              setState(() => _errorMessage = message);
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _controller,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _sheetInputDecoration(
                    hint: 'الاسم الجديد',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 20),
                _SheetSubmitButton(
                  isLoading: isLoading,
                  label: 'حفظ الاسم',
                  color: AppColors.accentColor,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _errorMessage = null);
                    context.read<UpdateProfileCubit>().updateProfile(
                      name: _controller.text.trim(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditEmailSheet extends StatefulWidget {
  final String initialEmail;
  final VoidCallback onSaved;

  const _EditEmailSheet({required this.initialEmail, required this.onSaved});

  @override
  State<_EditEmailSheet> createState() => _EditEmailSheetState();
}

class _EditEmailSheetState extends State<_EditEmailSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'تعديل الإيميل',
      icon: Icons.alternate_email_rounded,
      accent: AppColors.accentColor,
      child: BlocConsumer<UpdateProfileCubit, ResultState<UpdateProfileModel>>(
        listener: (context, state) {
          state.whenOrNull(
            success: (response) {
              setState(() => _errorMessage = null);
              widget.onSaved();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message ?? 'تم تحديث الإيميل بنجاح'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            error: (message) {
              setState(() => _errorMessage = message);
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: _sheetInputDecoration(
                    hint: 'الإيميل الجديد',
                    icon: Icons.alternate_email_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'الإيميل مطلوب';
                    if (!RegExp(
                      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(v.trim())) {
                      return 'إيميل غير صالح';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 20),
                _SheetSubmitButton(
                  isLoading: isLoading,
                  label: 'حفظ الإيميل',
                  color: AppColors.accentColor,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _errorMessage = null);
                    context.read<UpdateProfileCubit>().updateProfile(
                      email: _controller.text.trim(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditPasswordSheet extends StatefulWidget {
  const _EditPasswordSheet();

  @override
  State<_EditPasswordSheet> createState() => _EditPasswordSheetState();
}

class _EditPasswordSheetState extends State<_EditPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'تغيير كلمة المرور',
      icon: Icons.lock_reset_rounded,
      accent: AppColors.accentSecondary,
      child:
          BlocConsumer<UpdatePasswordCubit, ResultState<UpdatePasswordModel>>(
            listener: (context, state) {
              state.whenOrNull(
                success: (response) {
                  setState(() => _errorMessage = null);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        response.message ?? 'تم تغيير كلمة المرور بنجاح',
                      ),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                },
                error: (message) {
                  setState(() => _errorMessage = message);
                },
              );
            },
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: _sheetInputDecoration(
                        hint: 'كلمة المرور الحالية',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureOld
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureOld = !_obscureOld),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'أدخل كلمة المرور الحالية'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: _sheetInputDecoration(
                        hint: 'كلمة المرور الجديدة',
                        icon: Icons.lock_reset_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'أدخل كلمة مرور جديدة';
                        if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      _ErrorBanner(message: _errorMessage!),
                    ],
                    const SizedBox(height: 20),
                    _SheetSubmitButton(
                      isLoading: isLoading,
                      label: 'تحديث كلمة المرور',
                      color: AppColors.accentSecondary,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _errorMessage = null);
                        context.read<UpdatePasswordCubit>().updatePassword(
                          oldPassword: _oldPasswordController.text,
                          newPassword: _newPasswordController.text,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

// =========================================================
// كارت الخطأ الموحد للـ BottomSheets
// =========================================================
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.errorColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
