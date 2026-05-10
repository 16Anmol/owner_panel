import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'message_screen.dart';
import 'notification_screen.dart';
import 'edit_pg_room_screen.dart';
import 'scheduled_visit_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Dashboard',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Row 1
                    Row(
                      children: [
                        Expanded(
                          child: _DashTile(
                            icon: Icons.calendar_month_rounded,
                            title: 'Scheduled\nVisit',
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScheduledVisitScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DashTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Message',
                            badge: '3 new messages',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MessageScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2
                    Row(
                      children: [
                        Expanded(
                          child: _DashTile(
                            icon: Icons.bed_outlined,
                            title: 'Edit Rooms',
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditPgRoomScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DashTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const NotificationScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            _BottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const _DashTile({
    required this.icon,
    required this.title,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 4),
                  Text(badge!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.list_alt_rounded, 'label': 'Listing'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Dashboard'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i]['icon'] as IconData,
                    size: 24,
                    color: active ? AppColors.primary : AppColors.textLight),
                const SizedBox(height: 2),
                Text(items[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.primary : AppColors.textLight)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
