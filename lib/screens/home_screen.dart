import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'notification_screen.dart';
import 'message_screen.dart';

class HomeTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const HomeTab({super.key, required this.onSwitchTab});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? _owner;
  List<dynamic> _properties = [];
  int _unreadNotifs = 0;
  int _unreadMessages = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getMe(),
        ApiService.getMyProperties(),
        ApiService.getNotifications(),
        ApiService.getChats(),
      ]);
      if (mounted) {
        setState(() {
          _owner = results[0]['owner'] as Map<String, dynamic>?;
          _properties = results[1]['properties'] as List? ?? [];
          _unreadNotifs = results[2]['unreadCount'] as int? ?? 0;
          final chats = results[3]['chats'] as List? ?? [];
          _unreadMessages =
              chats.fold(0, (s, c) => s + (c['unreadCount'] as int? ?? 0));
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Hi, ${_owner?['name'] ?? 'Owner'} 👋',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark)),
                                const Text('Manage your properties efficiently',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted)),
                              ])),
                          _HeaderIcon(
                            icon: Icons.chat_bubble_outline_rounded,
                            badge: _unreadMessages > 0
                                ? (_unreadMessages > 9
                                    ? '9+'
                                    : '$_unreadMessages')
                                : null,
                            onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const MessageScreen()))
                                .then((_) => _load()),
                          ),
                          const SizedBox(width: 10),
                          _HeaderIcon(
                            icon: Icons.notifications_none_rounded,
                            badge: _unreadNotifs > 0
                                ? (_unreadNotifs > 9 ? '9+' : '$_unreadNotifs')
                                : null,
                            onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationScreen()))
                                .then((_) => _load()),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        // Upload button → switches to Listing tab
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onSwitchTab(1),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Upload New Property',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),

              if (_loading)
                const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)))
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
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.home_work_rounded,
                              color: AppColors.primary, size: 32),
                          const SizedBox(width: 12),
                          Text(
                              '${_properties.length} ${_properties.length == 1 ? "property" : "properties"} uploaded',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.primary),
                        ]),
                      ),
                    ),
                  ),
                ),

                // ── Recent Properties ──
                if (_properties.isNotEmpty) ...[
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Properties',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        TextButton(
                          onPressed: () => widget.onSwitchTab(1),
                          child: const Text('View all',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _PropertyCard(
                            property: _properties[i] as Map<String, dynamic>),
                      ),
                      childCount:
                          _properties.length > 3 ? 3 : _properties.length,
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

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;
  const _HeaderIcon({required this.icon, this.badge, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 21, color: AppColors.textDark),
          ),
        ),
      ),
      if (badge != null)
        Positioned(
          right: -3,
          top: -3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(badge!,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
    ]);
  }
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  const _PropertyCard({required this.property});
  @override
  Widget build(BuildContext context) {
    final status = property['status'] as String? ?? 'under_review';
    final isVerified = property['isVerified'] as bool? ?? false;
    final type = property['propertyType'] as String? ?? '';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'active':
        statusColor = AppColors.success;
        statusLabel = 'Active';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusLabel = 'Rejected';
        break;
      case 'inactive':
        statusColor = AppColors.textLight;
        statusLabel = 'Inactive';
        break;
      default:
        statusColor = const Color(0xFFE65100);
        statusLabel = 'Under Review';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(
            type == 'pg'
                ? '🛏️'
                : type == 'guest'
                    ? '🏨'
                    : '🌿',
            style: const TextStyle(fontSize: 20),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(property['propertyName'] ?? 'Unnamed',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(property['location'] ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _SmallBadge(label: statusLabel, color: statusColor),
            if (isVerified)
              const _SmallBadge(
                  label: '✓ Legally Verified', color: AppColors.success),
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
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}
