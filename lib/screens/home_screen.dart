import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'notification_screen.dart';

class HomeTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const HomeTab({super.key, required this.onSwitchTab});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? _owner;
  List<dynamic> _properties    = [];
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getMe(),
        ApiService.getMyProperties(),
        ApiService.getNotifications(),
      ]);
      if (mounted) setState(() {
        _owner         = results[0]['owner'] as Map<String, dynamic>?;
        _properties    = results[1]['properties'] as List? ?? [];
        // Show only the 2 most recent notifications on home screen
        final allNotifs = results[2]['notifications'] as List? ?? [];
        _notifications = allNotifs.take(2).toList();
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Hi, ${_owner?['name'] ?? 'Owner'} 👋',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const Text('Manage your properties efficiently',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      ])),
                      IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
                    ]),
                    const SizedBox(height: 14),
                    // Upload button → switches to Listing tab
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onSwitchTab(1),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Upload New Property',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              if (_loading)
                const SliverFillRemaining(child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)))
              else ...[
                // ── Property count card ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: GestureDetector(
                      onTap: () => widget.onSwitchTab(1),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.home_work_rounded, color: AppColors.primary, size: 32),
                          const SizedBox(width: 12),
                          Text('${_properties.length} ${_properties.length == 1 ? "property" : "properties"} uploaded',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                        ]),
                      ),
                    ),
                  ),
                ),

                // ── Notifications ──
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Important Updates',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      TextButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen())),
                        child: const Text('See all', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                    ],
                  ),
                )),

                if (_notifications.isEmpty)
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(children: [
                        Icon(Icons.notifications_none_rounded, color: AppColors.textLight),
                        SizedBox(width: 10),
                        Text('No new notifications', style: TextStyle(color: AppColors.textMuted)),
                      ]),
                    ),
                  ))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: _NotifCard(notif: _notifications[i] as Map<String, dynamic>),
                      ),
                      childCount: _notifications.length,
                    ),
                  ),

                // ── Recent Properties ──
                if (_properties.isNotEmpty) ...[
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Properties',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        TextButton(
                          onPressed: () => widget.onSwitchTab(1),
                          child: const Text('View all', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _PropertyCard(property: _properties[i] as Map<String, dynamic>),
                      ),
                      childCount: _properties.length > 3 ? 3 : _properties.length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  const _NotifCard({required this.notif});
  @override
  Widget build(BuildContext context) {
    final type = notif['type'] as String? ?? 'system';
    final isListing = type == 'listing';
    final color = isListing ? AppColors.success : AppColors.primary;
    final icon  = isListing ? Icons.check_circle_outline : Icons.info_outline;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notif['title'] ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(notif['message'] ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  const _PropertyCard({required this.property});
  @override
  Widget build(BuildContext context) {
    final status     = property['status']     as String? ?? 'under_review';
    final isVerified = property['isVerified'] as bool?   ?? false;
    final type       = property['propertyType'] as String? ?? '';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'active':   statusColor = AppColors.success;       statusLabel = 'Active';       break;
      case 'rejected': statusColor = AppColors.error;         statusLabel = 'Rejected';     break;
      case 'inactive': statusColor = AppColors.textLight;     statusLabel = 'Inactive';     break;
      default:         statusColor = const Color(0xFFE65100); statusLabel = 'Under Review';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(
            type == 'pg' ? '🛏️' : type == 'guest' ? '🏨' : '🌿',
            style: const TextStyle(fontSize: 20),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(property['propertyName'] ?? 'Unnamed',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(property['location'] ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _SmallBadge(label: statusLabel, color: statusColor),
            if (isVerified)
              _SmallBadge(label: '✓ Legally Verified', color: AppColors.success),
          ]),
        ])),
      ]),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _SmallBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );
}
