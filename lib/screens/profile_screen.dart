import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'payment_screen.dart';
import 'edit_profile_screen.dart';
import 'contact_us_screen.dart';
import 'info_pages.dart';

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

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted)
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Future<void> _openPayment() async {
    final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => const PaymentScreen(fromProfile: true)));
    if (paid == true) _load();
  }

  Future<void> _openEdit() async {
    if (_owner == null) return;
    final changed = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditProfileScreen(owner: _owner!)));
    if (changed == true) _load();
  }

  // ── helpers ──────────────────────────────────────────────
  String _cap(String s) =>
      s.isEmpty ? '—' : s[0].toUpperCase() + s.substring(1);

  String _val(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? '—' : s;
  }

  String _memberSince() {
    final c = _owner?['createdAt'];
    if (c == null) return '—';
    final d = DateTime.tryParse(c.toString());
    if (d == null) return '—';
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${m[d.month - 1]} ${d.year}';
  }

  bool get _incomplete =>
      ((_owner?['businessName'] ?? '') as String).isEmpty ||
      ((_owner?['address'] ?? '') as String).isEmpty ||
      ((_owner?['city'] ?? '') as String).isEmpty ||
      ((_owner?['state'] ?? '') as String).isEmpty;

  @override
  Widget build(BuildContext context) {
    final name = (_owner?['name'] ?? 'Owner').toString();
    final photo = (_owner?['profilePhoto'] ?? '').toString();
    final phone = (_owner?['phone'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  // ── Header card ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF8A4429)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        clipBehavior: Clip.antiAlias,
                        child: photo.isNotEmpty
                            ? Image.network(photo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _initial(name))
                            : _initial(name),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text(_owner?['email'] ?? '',
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.85))),
                            if (phone.isNotEmpty)
                              Text(phone,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white
                                          .withValues(alpha: 0.75))),
                          ])),
                      IconButton(
                        onPressed: _openEdit,
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.white),
                        tooltip: 'Edit profile',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // ── Registration payment reminder (unpaid owners) ──
                  if (!(_owner?['isPaid'] as bool? ?? false)) ...[
                    GestureDetector(
                      onTap: _openPayment,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Color(0xFFE65100), size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Pending',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFE65100))),
                                SizedBox(height: 2),
                                Text(
                                    'Please pay the ₹100 registration fee first to activate your account.',
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFFE65100),
                                        height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE65100),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Pay Now',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Incomplete profile prompt ──
                  if (_incomplete) ...[
                    GestureDetector(
                      onTap: _openEdit,
                      child: Container(
                        width: double.infinity,
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
                            'Complete your profile so buyers can trust your listings.',
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

                  // ── Contact ──
                  _SectionLabel('Contact'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _val(_owner?['email'])),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _val(_owner?['phone'])),
                    _InfoRow(
                        icon: Icons.chat_outlined,
                        label: 'Alt / WhatsApp',
                        value: _val(_owner?['altPhone'])),
                  ]),
                  const SizedBox(height: 16),

                  // ── Business ──
                  _SectionLabel('Business'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.store_outlined,
                        label: 'Business Name',
                        value: _val(_owner?['businessName'])),
                    _InfoRow(
                        icon: Icons.work_outline,
                        label: 'Occupation',
                        value: _cap((_owner?['occupation'] ?? '') as String)),
                    _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'GST Number',
                        value: _val(_owner?['gstNumber'])),
                  ]),
                  const SizedBox(height: 16),

                  // ── Address ──
                  _SectionLabel('Address'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        value: _val(_owner?['address'])),
                    _InfoRow(
                        icon: Icons.location_city_rounded,
                        label: 'City',
                        value: _cap((_owner?['city'] ?? '') as String)),
                    _InfoRow(
                        icon: Icons.map_outlined,
                        label: 'State',
                        value: _cap((_owner?['state'] ?? '') as String)),
                    _InfoRow(
                        icon: Icons.markunread_mailbox_outlined,
                        label: 'Pincode',
                        value: _val(_owner?['pincode'])),
                  ]),
                  const SizedBox(height: 16),

                  // ── Personal ──
                  _SectionLabel('Personal'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Gender',
                        value: _cap((_owner?['gender'] ?? '') as String)),
                    _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'ID Number',
                        value: _val(_owner?['idNumber'])),
                  ]),
                  const SizedBox(height: 16),

                  // ── Account ──
                  _SectionLabel('Account'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Account',
                        value:
                            _cap((_owner?['accountStatus'] ?? '') as String)),
                    _InfoRow(
                        icon: Icons.event_outlined,
                        label: 'Member Since',
                        value: _memberSince()),
                    _InfoRow(
                      icon: Icons.mark_email_read_outlined,
                      label: 'Email Verified',
                      value: (_owner?['isEmailVerified'] as bool? ?? false)
                          ? '✅ Verified'
                          : '❌ Not Verified',
                    ),
                    _InfoRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Aadhaar Verified',
                      value: (_owner?['isAadhaarVerified'] as bool? ?? false)
                          ? '✅ Verified'
                          : '❌ Not Verified',
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── More ──
                  _SectionLabel('More'),
                  _AppMenu(owner: _owner ?? const {}),
                  const SizedBox(height: 16),
                  const _RateExperience(),
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

  Widget _initial(String name) => Center(
        child: Text(
          (name.isEmpty ? 'O' : name[0]).toUpperCase(),
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted)),
        ),
      );
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
        ]),
      );
}

// ── App menu (Contact / About / Terms / Privacy) ─────────────
class _AppMenu extends StatelessWidget {
  final Map<String, dynamic> owner;
  const _AppMenu({required this.owner});

  Widget _tile(BuildContext context, IconData icon, String title,
          VoidCallback onTap, bool divider) =>
      Column(children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 20),
          title: Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight),
          onTap: onTap,
        ),
        if (divider) const Divider(height: 1, color: AppColors.border),
      ]);

  @override
  Widget build(BuildContext context) {
    void go(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        _tile(context, Icons.support_agent_rounded, 'Contact Us',
            () => go(ContactUsScreen(owner: owner)), true),
        _tile(context, Icons.info_outline_rounded, 'About Us',
            () => go(const AboutUsScreen()), true),
        _tile(context, Icons.description_outlined, 'Terms & Conditions',
            () => go(const TermsScreen()), true),
        _tile(context, Icons.privacy_tip_outlined, 'Privacy Policy',
            () => go(const PrivacyScreen()), false),
      ]),
    );
  }
}

// ── Rate your experience (app feedback -> support inbox) ─────
class _RateExperience extends StatefulWidget {
  const _RateExperience();
  @override
  State<_RateExperience> createState() => _RateExperienceState();
}

class _RateExperienceState extends State<_RateExperience> {
  int _rating = 0;
  bool _sending = false;
  bool _done = false;

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _sending = true);
    try {
      await ApiService.submitProblem(
          'App rating: $_rating/5 stars (Rate your experience)');
      if (mounted) setState(() => _done = true);
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Rate Your Experience',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('How is your experience with the app so far?',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        if (_done)
          Row(children: const [
            Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            SizedBox(width: 8),
            Text('Thanks for your feedback!',
                style: TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w700)),
          ])
        else ...[
          Row(
              children: List.generate(5, (i) {
            final filled = i < _rating;
            return GestureDetector(
              onTap: _sending ? null : () => setState(() => _rating = i + 1),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFA726),
                    size: 34),
              ),
            );
          })),
          if (_rating > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_sending ? 'Sending…' : 'Send feedback'),
              ),
            ),
          ],
        ],
      ]),
    );
  }
}
