import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Toggle to test empty state
  bool _hasNotifications = true;

  final List<Map<String, dynamic>> _todayNotifs = [
    {
      'icon': Icons.check_circle_outline_rounded,
      'color': AppColors.success,
      'bg': AppColors.successBg,
      'title': 'Congratulations, your listing is now active.',
      'link': 'click here to see your listing',
      'read': false,
    },
    {
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
      'bg': Color(0xFFFFF3E0),
      'title': "Welcome, Don't forget to complete your personal info.",
      'link': null,
      'read': false,
    },
  ];

  final List<Map<String, dynamic>> _yesterdayNotifs = [
    {
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
      'bg': Color(0xFFFFF3E0),
      'title': "Welcome, Don't forget to complete your personal info.",
      'link': null,
      'read': true,
    },
    {
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
      'bg': Color(0xFFFFF3E0),
      'title': "Welcome, Don't forget to complete your personal info.",
      'link': null,
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Notification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                  ),
                  // Clear all
                  TextButton(
                    onPressed: () => setState(() => _hasNotifications = false),
                    child: const Text('Clear all',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _hasNotifications ? _buildList() : _buildEmpty(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 4),
        _groupHeader('Today'),
        ..._todayNotifs.map((n) => _NotifTile(notif: n)),
        const SizedBox(height: 8),
        _groupHeader('Yesterday'),
        ..._yesterdayNotifs.map((n) => _NotifTile(notif: n)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _groupHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.3)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
                color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined,
                size: 72, color: AppColors.textLight),
          ),
          const SizedBox(height: 28),
          const Text('No notification yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'All notification we send will appear here,\nso you can view them easily anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif['read'] as bool
            ? AppColors.surface
            : (notif['bg'] as Color).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif['read'] as bool
              ? AppColors.border
              : (notif['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: notif['bg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(notif['icon'] as IconData,
                color: notif['color'] as Color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.5),
                    children: [
                      TextSpan(text: notif['title'] as String),
                      if (notif['link'] != null) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: notif['link'] as String,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!(notif['read'] as bool))
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4, left: 8),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
