import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'group_room_screen.dart';
import 'shared_room_screen.dart';

class EditPgRoomScreen extends StatefulWidget {
  const EditPgRoomScreen({super.key});

  @override
  State<EditPgRoomScreen> createState() => _EditPgRoomScreenState();
}

class _EditPgRoomScreenState extends State<EditPgRoomScreen> {
  final _totalRoomsCtrl = TextEditingController(text: '12');
  String? _selectedType; // 'sharing' | 'group'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Edit PG Room',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Total Rooms card ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Total Rooms',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted)),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              controller: _totalRoomsCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Occupancy Type Header ──
                    const Text('Select Room Occupancy Type',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 14),

                    // ── Sharing PG Room tile ──
                    _OccupancyTile(
                      selected: _selectedType == 'sharing',
                      icon: Icons.people_outline_rounded,
                      title: 'Sharing Pg Room',
                      subtitle:
                          'Room will be shared with other persons. Pricing is per person.',
                      onTap: () =>
                          setState(() => _selectedType = 'sharing'),
                    ),
                    const SizedBox(height: 12),

                    // ── Group / Private Room tile ──
                    _OccupancyTile(
                      selected: _selectedType == 'group',
                      icon: Icons.groups_outlined,
                      title: 'Group/ Private Room',
                      subtitle:
                          'Entire room will be alloted to one group (persons/friends).',
                      onTap: () =>
                          setState(() => _selectedType = 'group'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Done Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: 'Done',
                onPressed: _selectedType == null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a room occupancy type'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : () {
                        if (_selectedType == 'group') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GroupRoomScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SharedRoomScreen()),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccupancyTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OccupancyTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: selected
                    ? AppColors.primary.withOpacity(0.08)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
