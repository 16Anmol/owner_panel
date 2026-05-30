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

                  // ── Contact & Support ────────────────────────────
                  _OwnerSupportCard(ownerEmail: _owner?['email'] as String? ?? ''),
                  const SizedBox(height: 20),

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


// ── Owner Contact & Support Card ─────────────────────────────
class _OwnerSupportCard extends StatefulWidget {
  final String ownerEmail;
  const _OwnerSupportCard({required this.ownerEmail});
  @override
  State<_OwnerSupportCard> createState() => _OwnerSupportCardState();
}

class _OwnerSupportCardState extends State<_OwnerSupportCard> {
  bool _expanded   = false;
  bool _submitting = false;
  final _subject   = TextEditingController();
  final _message   = TextEditingController();

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in subject and message')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.submitSupportTicket(
        subject: _subject.text.trim(),
        message: _message.text.trim(),
      );
      _subject.clear(); _message.clear();
      setState(() => _expanded = false);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(28),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 18),
            const Text('Issue Recorded!',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Your support request has been submitted. Check your registered email (${widget.ownerEmail}) for our reply.',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error));
    } finally { if (mounted) setState(() => _submitting = false); }
  }

  @override
  void dispose() { _subject.dispose(); _message.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: [
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Contact & Support', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text('Report an issue or ask for help', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ])),
            Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted),
          ]),
        ),
      ),
      if (_expanded) ...[
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Subject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 6),
            TextField(
              controller: _subject,
              decoration: InputDecoration(
                hintText: 'e.g. Upload issue, payment problem…',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Describe your issue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 6),
            TextField(
              controller: _message,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what happened in detail…',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Issue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            )),
          ]),
        ),
      ],
    ]),
  );
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
