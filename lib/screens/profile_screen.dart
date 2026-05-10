import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Profile',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 2)),
                          child: const Icon(Icons.person_rounded,
                              size: 48, color: AppColors.primary),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.edit_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Owner Name',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    const Text('owner@email.com',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textMuted)),
                    const SizedBox(height: 32),

                    // Profile items
                    ...[
                      {'icon': Icons.person_outline_rounded, 'label': 'Edit Profile'},
                      {'icon': Icons.home_work_outlined, 'label': 'My Properties'},
                      {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
                      {'icon': Icons.help_outline_rounded, 'label': 'Help & Support'},
                      {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy'},
                      {'icon': Icons.logout_rounded, 'label': 'Logout'},
                    ].map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        leading: Icon(item['icon'] as IconData,
                            color: item['label'] == 'Logout'
                                ? AppColors.error
                                : AppColors.primary,
                            size: 22),
                        title: Text(item['label'] as String,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: item['label'] == 'Logout'
                                    ? AppColors.error
                                    : AppColors.textDark)),
                        trailing: item['label'] != 'Logout'
                            ? const Icon(Icons.arrow_forward_ios_rounded,
                                size: 15, color: AppColors.textLight)
                            : null,
                        onTap: () {},
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
