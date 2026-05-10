import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'view_details_screen.dart';

class ScheduledVisitScreen extends StatefulWidget {
  const ScheduledVisitScreen({super.key});

  @override
  State<ScheduledVisitScreen> createState() => _ScheduledVisitScreenState();
}

class _ScheduledVisitScreenState extends State<ScheduledVisitScreen> {
  String _tab = 'Today'; // Today | Upcoming | Past
  String _filter = 'All';

  // Tab labels — Past shows "Update" as middle option
  List<String> get _tabs => ['Today', 'Upcoming', 'Past'];

  // Filter chips per tab
  List<String> get _filters {
    switch (_tab) {
      case 'Today':
      case 'Upcoming':
        return ['All', 'Pending', 'Confirmed', 'Cancelled', 'Rescheduled'];
      case 'Past':
        return ['All', 'Confirmed', 'Cancelled', 'Rescheduled'];
      default:
        return ['All', 'Pending', 'Confirmed', 'Cancelled', 'Rescheduled'];
    }
  }

  // Color per filter chip
  Color _filterColor(String f) {
    switch (f) {
      case 'Pending': return const Color(0xFFE8913A);
      case 'Confirmed': return AppColors.success;
      case 'Cancelled': return AppColors.error;
      case 'Rescheduled': return const Color(0xFF1565C0);
      default: return AppColors.primary;
    }
  }

  // All visits
  final List<Map<String, dynamic>> _allVisits = [
    // TODAY
    {'name': 'Rahul Sharma', 'date': '12 Feb,11:30 Am', 'property': "Arora's house", 'looking': 'Looking for 2 person room', 'status': 'Pending', 'tab': 'Today'},
    {'name': 'Karuna', 'date': '12 Feb,10:30 Am', 'property': "Arora's house", 'looking': 'Looking for 3 person room', 'status': 'Confirmed', 'tab': 'Today'},
    {'name': 'Deepak Paul', 'date': '12 Feb,1:30 pm', 'property': "Arora's house", 'looking': 'Looking for group room', 'status': 'Rescheduled', 'tab': 'Today'},
    {'name': 'Sarita Gupta', 'date': '12 Feb,11:30 Am', 'property': "Arora's house", 'looking': 'Looking for 2 person room', 'status': 'Cancelled', 'tab': 'Today'},
    // UPCOMING
    {'name': 'Rahul Sharma', 'date': '12 Feb,11:30 Am', 'property': "Arora's house", 'looking': 'Looking for 2 person room', 'status': 'Pending', 'tab': 'Upcoming'},
    {'name': 'Karuna', 'date': '12 Feb,10:30 Am', 'property': "Arora's house", 'looking': 'Looking for 3 person room', 'status': 'Confirmed', 'tab': 'Upcoming'},
    {'name': 'Deepak Paul', 'date': '12 Feb,1:30 pm', 'property': "Arora's house", 'looking': 'Looking for group room', 'status': 'Rescheduled', 'tab': 'Upcoming'},
    {'name': 'Sarita Gupta', 'date': '12 Feb,11:30 Am', 'property': "Arora's house", 'looking': 'Looking for 2 person room', 'status': 'Cancelled', 'tab': 'Upcoming'},
    // PAST
    {'name': 'Rahul Sharma', 'date': '12 Feb,11:30 Am', 'property': "Arora's house", 'looking': 'Looking for 2 person room', 'status': 'Pending', 'tab': 'Past'},
    {'name': 'Karuna', 'date': '12 Feb,10:30 Am', 'property': "Arora's house", 'looking': 'Looking for 3 person room', 'status': 'Confirmed', 'tab': 'Past'},
    {'name': 'Deepak Paul', 'date': '12 Feb,1:30 pm', 'property': "Arora's house", 'looking': 'Looking for group room', 'status': 'Rescheduled', 'tab': 'Past'},
    {'name': 'Sarita Gupta', 'date': '12 Feb,11:30 Am', 'property': "Arora's house", 'looking': 'Looking for 2 person room', 'status': 'Cancelled', 'tab': 'Past'},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _allVisits.where((v) {
      final tabMatch = v['tab'] == _tab;
      final filterMatch = _filter == 'All' || v['status'] == _filter;
      return tabMatch && filterMatch;
    }).toList();
  }

  void _switchTab(String tab) {
    setState(() {
      _tab = tab;
      // Reset filter to All when switching tabs, unless current filter exists in new tab
      if (!_filters.contains(_filter)) _filter = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
                    child: Text('Scheduled Visits',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: _tabs.map((tab) {
                  final active = _tab == tab;
                  // Past tab shows "Update" as the middle display label per Figma
                  final displayLabel = tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _switchTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          displayLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter Chips ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((f) {
                  final active = _filter == f;
                  final color = _filterColor(f);
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? color.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? color : AppColors.border,
                          width: active ? 1.8 : 1.2,
                        ),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: active ? color : AppColors.textMuted)),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // ── Content ──
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _VisitCard(visit: filtered[i]),
                    ),
            ),
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
            width: 160, height: 160,
            decoration: const BoxDecoration(
                color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.luggage_rounded,
                size: 80, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          const Text('Opps!!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          const Text('No Scheduled Visit Yet !',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Wait for the scheduled visits',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────
// Visit Card
// ──────────────────────────────────────
class _VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;
  const _VisitCard({required this.visit});

  String get status => visit['status'] as String;

  Color get statusColor {
    switch (status) {
      case 'Pending': return const Color(0xFFE8913A);
      case 'Confirmed': return AppColors.success;
      case 'Rescheduled': return const Color(0xFF1565C0);
      case 'Cancelled': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  Color get statusBg {
    switch (status) {
      case 'Pending': return const Color(0xFFFFF3E0);
      case 'Confirmed': return AppColors.successBg;
      case 'Rescheduled': return const Color(0xFFE3F2FD);
      case 'Cancelled': return const Color(0xFFFFEBEE);
      default: return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(visit['name'] as String,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              Text(status,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: statusColor)),
            ],
          ),
          const SizedBox(height: 3),

          // Date
          Text(visit['date'] as String,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 5),

          // Property
          Text(visit['property'] as String,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 2),

          // Requirement
          Text(visit['looking'] as String,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 12),

          // Actions row
          Row(
            children: [
              GestureDetector(
                onTap: () => _showDetails(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text('View Details',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ),
              ),
              const Spacer(),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(Icons.phone_outlined,
                    size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewDetailsScreen(
          visit: {
            ...visit,
            'mobile': '7723454321',
            'visitDate': '${visit['date']},2026',
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────
// Detail Bottom Sheet
// ──────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final Map<String, dynamic> visit;
  const _DetailSheet({required this.visit});

  String get status => visit['status'] as String;

  Color get statusColor {
    switch (status) {
      case 'Pending': return const Color(0xFFE8913A);
      case 'Confirmed': return AppColors.success;
      case 'Rescheduled': return const Color(0xFF1565C0);
      case 'Cancelled': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),

          // Header row
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit['name'] as String,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    Text(visit['date'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 14),

          _row(Icons.home_outlined, 'Property', visit['property'] as String),
          const SizedBox(height: 12),
          _row(Icons.search_rounded, 'Requirement', visit['looking'] as String),
          const SizedBox(height: 12),
          _row(Icons.calendar_today_outlined, 'Visit Date', visit['date'] as String),
          const SizedBox(height: 24),

          // Action buttons based on status
          if (status == 'Pending')
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),

          if (status == 'Confirmed')
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Cancel Visit',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Reschedule',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),

          if (status == 'Rescheduled' || status == 'Cancelled')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Close',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ],
        ),
      ],
    );
  }
}
