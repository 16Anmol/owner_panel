import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';


class ProfileTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const ProfileTab({super.key, required this.onSwitchTab});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? _owner;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getMe();
      if (mounted) setState(() { _owner = res['owner'] as Map<String, dynamic>?; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const SizedBox(height: 10),
                  // Avatar
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(_owner?['name'] ?? 'Owner',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text(_owner?['email'] ?? '',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 24),

                  // Info cards
                  _InfoCard(items: [
                    _InfoRow(icon: Icons.email_outlined,   label: 'Email',  value: _owner?['email'] ?? '—'),
                    _InfoRow(icon: Icons.phone_outlined,   label: 'Phone',  value: _owner?['phone']?.toString().isNotEmpty == true ? _owner!['phone'] : '—'),
                    _InfoRow(icon: Icons.verified_user_outlined, label: 'Account', value: _owner?['accountStatus'] ?? '—'),
                  ]),
                  const SizedBox(height: 16),

                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.mark_email_read_outlined,
                      label: 'Email Verified',
                      value: (_owner?['isEmailVerified'] as bool? ?? false) ? '✅ Verified' : '❌ Not Verified',
                    ),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Aadhaar Verified',
                      value: (_owner?['isAadhaarVerified'] as bool? ?? false) ? '✅ Verified' : '❌ Not Verified',
                    ),
                  ]),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ]),
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> items;
  const _InfoCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: List.generate(items.length, (i) => Column(children: [
      items[i],
      if (i < items.length - 1) const Divider(height: 1, color: AppColors.border),
    ]))),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    ]),
  );
}
