import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'property_type_screen.dart';
import 'listing_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Greeting ──
                    const Text('Welcome Owner',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Manage your properties efficiently',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    const SizedBox(height: 20),

                    // ── Status Banner ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        border: Border.all(
                            color: AppColors.primary, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Change Status of Your Property',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Upload Button ──
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PropertyTypeScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add_rounded,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text('Upload New Property',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Important Updates ──
                    const Text('Important Updates',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    NotificationCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Congratulations!',
                      subtitle:
                          'Your listing is now active. Visit here to see your listing.',
                      iconColor: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    const NotificationCard(
                      icon: Icons.warning_amber_rounded,
                      title: "Don't forget",
                      subtitle:
                          "Welcome, don't forget to complete your personal info.",
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(height: 32),

                    // ── Empty State ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.home_work_outlined,
                                size: 50, color: AppColors.textLight),
                          ),
                          const SizedBox(height: 14),
                          const Text('No Property Uploaded yet !',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Bottom Nav ──
            _BottomNav(currentIndex: 0),
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

    final routes = [
      null, // Home — already here
      const ListingScreen(),
      const DashboardScreen(),
      const ProfileScreen(),
    ];

    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i != currentIndex && routes[i] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => routes[i]!),
                  );
                }
              },
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
                          color:
                              active ? AppColors.primary : AppColors.textLight)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
