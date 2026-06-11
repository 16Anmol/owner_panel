import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getMe();
      if (mounted)
        setState(() {
          _owner = res['owner'] as Map<String, dynamic>?;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _incompleteProfile {
    final o = _owner;
    if (o == null) return false;
    String s(String k) => (o[k] ?? '').toString();
    return s('gender').isEmpty ||
        s('occupation').isEmpty ||
        s('businessName').isEmpty ||
        s('address').isEmpty ||
        s('city').isEmpty ||
        s('state').isEmpty ||
        s('pincode').isEmpty;
  }

  Future<void> _openEdit() async {
    if (_owner == null) return;
    final changed = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditProfileScreen(owner: _owner!)));
    if (changed == true) _load();
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted)
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const SizedBox(height: 10),
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(_owner?['name'] ?? 'Owner',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  Text(_owner?['email'] ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 16),

                  // Edit profile button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Incomplete profile prompt
                  if (_incompleteProfile) ...[
                    GestureDetector(
                      onTap: _openEdit,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFE65100), size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                              child: Text(
                            'Complete your profile details (business, address & KYC) so customers can trust your listings.',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFFE65100),
                                fontWeight: FontWeight.w600),
                          )),
                          const Text('Update',
                              style: TextStyle(
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Info cards
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _owner?['email'] ?? '—'),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _owner?['phone']?.toString().isNotEmpty == true
                            ? _owner!['phone']
                            : '—'),
                    _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Account',
                        value: _owner?['accountStatus'] ?? '—'),
                  ]),
                  const SizedBox(height: 16),

                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Business / Name',
                        value: _owner?['businessName']?.toString().isNotEmpty ==
                                true
                            ? _owner!['businessName']
                            : '—'),
                    _InfoRow(
                        icon: Icons.work_outline,
                        label: 'Occupation',
                        value:
                            _owner?['occupation']?.toString().isNotEmpty == true
                                ? _owner!['occupation']
                                : '—'),
                    _InfoRow(
                        icon: Icons.location_city_rounded,
                        label: 'City',
                        value: _owner?['city']?.toString().isNotEmpty == true
                            ? _owner!['city']
                            : '—'),
                    _InfoRow(
                        icon: Icons.map_outlined,
                        label: 'State',
                        value: _owner?['state']?.toString().isNotEmpty == true
                            ? _owner!['state']
                            : '—'),
                  ]),
                  const SizedBox(height: 16),

                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.mark_email_read_outlined,
                      label: 'Email Verified',
                      value: (_owner?['isEmailVerified'] as bool? ?? false)
                          ? '✅ Verified'
                          : '❌ Not Verified',
                    ),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Aadhaar Verified',
                      value: (_owner?['isAadhaarVerified'] as bool? ?? false)
                          ? '✅ Verified'
                          : '❌ Not Verified',
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const _SupportSection(),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      label: const Text('Sign Out',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
            children: List.generate(
                items.length,
                (i) => Column(children: [
                      items[i],
                      if (i < items.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ]))),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ]),
      );
}

// ── Ask a Problem / Contact Us ───────────────────────────────
class _SupportSection extends StatefulWidget {
  const _SupportSection();
  @override
  State<_SupportSection> createState() => _SupportSectionState();
}

class _SupportSectionState extends State<_SupportSection> {
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ApiService.submitProblem(msg);
      _ctrl.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Sent! Our team will reply to your email.'),
            backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.support_agent_rounded, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Ask a Problem',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
        ]),
        const SizedBox(height: 6),
        const Text(
            'Describe your issue and our team will get back to you on your email.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Type your problem here…',
            hintStyle:
                const TextStyle(color: AppColors.textLight, fontSize: 14),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(_sending ? 'Sending…' : 'Send'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}
