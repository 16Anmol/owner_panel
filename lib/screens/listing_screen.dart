import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'property_type_screen.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final List<Map<String, dynamic>> _listings = [
    {
      'name': 'Sunshine PG',
      'type': 'PG Room',
      'location': 'Sector 17, Chandigarh',
      'price': '₹6,500 / month',
      'rooms': 12,
      'status': 'Active',
      'icon': Icons.bed_rounded,
    },
    {
      'name': 'Green Valley Guest House',
      'type': 'Guest Room',
      'location': 'Model Town, Ludhiana',
      'price': '₹1,999 / night',
      'rooms': 10,
      'status': 'Under Review',
      'icon': Icons.hotel_rounded,
    },
    {
      'name': 'Plot No. 10 — Sector 5',
      'type': 'Plot',
      'location': 'Sector 5, Mohali',
      'price': '₹75,000 total',
      'rooms': 0,
      'status': 'Active',
      'icon': Icons.landscape_rounded,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Listings',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      SizedBox(height: 2),
                      Text('Manage your properties',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PropertyTypeScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('Add New',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter Tabs ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: ['All', 'Active', 'Under Review', 'Inactive'].map((tab) {
                  final isFirst = tab == 'All';
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isFirst ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isFirst ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(tab,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isFirst ? Colors.white : AppColors.textMuted)),
                  );
                }).toList(),
              ),
            ),

            // ── Listings ──
            Expanded(
              child: _listings.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: _listings.length,
                      itemBuilder: (context, i) => _ListingCard(listing: _listings[i],
                          onDelete: () => setState(() => _listings.removeAt(i))),
                    ),
            ),

            _BottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.home_work_outlined, size: 48, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          const Text('No listings yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Tap "Add New" to upload your first property',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onDelete;

  const _ListingCard({required this.listing, required this.onDelete});

  Color get _statusColor {
    switch (listing['status']) {
      case 'Active': return AppColors.success;
      case 'Under Review': return Colors.orange;
      default: return AppColors.textLight;
    }
  }

  Color get _statusBg {
    switch (listing['status']) {
      case 'Active': return AppColors.successBg;
      case 'Under Review': return const Color(0xFFFFF3E0);
      default: return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(listing['icon'] as IconData,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing['name'] as String,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(listing['type'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(listing['status'] as String,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Location
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 15, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(listing['location'] as String,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),

          Row(children: [
            const Icon(Icons.currency_rupee_rounded,
                size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(listing['price'] as String,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const Spacer(),
            if ((listing['rooms'] as int) > 0)
              Text('${listing['rooms']} Rooms',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 12),

          // Action buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]),
        ],
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
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i]['icon'] as IconData, size: 24,
                    color: active ? AppColors.primary : AppColors.textLight),
                const SizedBox(height: 2),
                Text(items[i]['label'] as String,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: active ? AppColors.primary : AppColors.textLight)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
