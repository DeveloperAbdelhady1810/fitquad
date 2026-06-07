import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../data/partner_gym_repository.dart';
import '../models/gym_class_model.dart';

class GymClassesScreen extends StatefulWidget {
  static const routeName = '/gym-classes';

  const GymClassesScreen({super.key});

  @override
  State<GymClassesScreen> createState() => _GymClassesScreenState();
}

class _GymClassesScreenState extends State<GymClassesScreen> {
  late Future<List<GymClassModel>> _future;
  String _selectedCategory = 'all';

  static const _categories = [
    'all', 'yoga', 'spinning', 'hiit', 'pilates',
    'crossfit', 'zumba', 'boxing', 'strength', 'cardio', 'other',
  ];

  static const _categoryEmoji = {
    'yoga': '🧘', 'spinning': '🚴', 'hiit': '⚡', 'pilates': '🤸',
    'crossfit': '🏋️', 'zumba': '💃', 'boxing': '🥊', 'strength': '💪',
    'cardio': '🏃', 'other': '🎯', 'all': '📅',
  };

  @override
  void initState() {
    super.initState();
    _future = PartnerGymRepository.getGymClasses();
  }

  void _reload() => setState(() {
        _future = PartnerGymRepository.getGymClasses();
      });

  List<GymClassModel> _filtered(List<GymClassModel> all) {
    if (_selectedCategory == 'all') return all;
    return all.where((c) => c.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Gym Classes', style: AppTextStyles.font16WhiteBold),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _CategoryChips(
            selected: _selectedCategory,
            categories: _categories,
            emojis: _categoryEmoji,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
          ),
          Expanded(
            child: FutureBuilder<List<GymClassModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.teal));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.grey, size: 48.r),
                        vGap(12),
                        Text(
                          snapshot.error.toString().replaceFirst('Exception: ', ''),
                          style: AppTextStyles.font14GreyRegular,
                          textAlign: TextAlign.center,
                        ),
                        vGap(16),
                        TextButton(
                          onPressed: _reload,
                          child: Text('Retry',
                              style: TextStyle(color: AppColors.teal)),
                        ),
                      ],
                    ),
                  );
                }
                final all = snapshot.data ?? [];
                final classes = _filtered(all);

                if (classes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏋️', style: TextStyle(fontSize: 48.sp)),
                        vGap(12),
                        Text(
                          all.isEmpty
                              ? 'No classes available at your gym yet.'
                              : 'No $_selectedCategory classes right now.',
                          style: AppTextStyles.font14GreyRegular,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => vGap(12),
                  itemBuilder: (_, i) => _ClassCard(
                    gymClass: classes[i],
                    onBook: () => _book(classes[i]),
                    onCancel: () => _cancel(classes[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _book(GymClassModel gymClass) async {
    try {
      await PartnerGymRepository.bookClass(gymClass.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(gymClass.isPaid
              ? 'Class booked! Payment may be required.'
              : '✅ Class booked!'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ));
      }
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _cancel(GymClassModel gymClass) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text('Cancel booking?',
            style: TextStyle(color: Colors.white)),
        content: Text('Cancel your spot in "${gymClass.title}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Yes, cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await PartnerGymRepository.cancelClassBooking(gymClass.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking cancelled.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

// ─── Category Chips ────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final String selected;
  final List<String> categories;
  final Map<String, String> emojis;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.selected,
    required this.categories,
    required this.emojis,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: categories.map((cat) {
            final isSelected = selected == cat;
            return GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: 8.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.teal
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.teal
                        : AppColors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${emojis[cat] ?? ''} ${cat == 'all' ? 'All' : cat[0].toUpperCase() + cat.substring(1)}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.grey,
                    fontSize: 12.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Class Card ────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final GymClassModel gymClass;
  final VoidCallback onBook;
  final VoidCallback onCancel;

  const _ClassCard({
    required this.gymClass,
    required this.onBook,
    required this.onCancel,
  });

  static const _catColor = {
    'yoga': Color(0xFF7C3AED),
    'spinning': Color(0xFF2563EB),
    'hiit': Color(0xFFDC2626),
    'pilates': Color(0xFF059669),
    'crossfit': Color(0xFFD97706),
    'zumba': Color(0xFFDB2777),
    'boxing': Color(0xFF9333EA),
    'strength': Color(0xFF00a689),
    'cardio': Color(0xFF0891B2),
    'other': Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM · HH:mm');
    final endFmt = DateFormat('HH:mm');
    final color = _catColor[gymClass.category] ?? const Color(0xFF6B7280);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: category badge + gym name
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  gymClass.category[0].toUpperCase() +
                      gymClass.category.substring(1),
                  style: TextStyle(
                      color: color,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (gymClass.isPaid) ...[
                hGap(8),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${gymClass.price.toStringAsFixed(0)} EGP',
                    style: TextStyle(
                        color: const Color(0xFFFBBF24),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                hGap(8),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('FREE',
                      style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ],
              const Spacer(),
              if (gymClass.gymName != null)
                Text(gymClass.gymName!,
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 11.sp)),
            ],
          ),
          vGap(10),
          // Title
          Text(gymClass.title, style: AppTextStyles.font16WhiteBold),
          vGap(6),
          // Time
          Row(children: [
            Icon(Icons.schedule, color: AppColors.grey, size: 14.r),
            hGap(4),
            Text(
              '${fmt.format(gymClass.startTime)} — ${endFmt.format(gymClass.endTime)}',
              style: AppTextStyles.font14GreyRegular
                  .copyWith(fontSize: 12.sp),
            ),
          ]),
          if (gymClass.location != null) ...[
            vGap(4),
            Row(children: [
              Icon(Icons.location_on_outlined,
                  color: AppColors.grey, size: 14.r),
              hGap(4),
              Text(gymClass.location!,
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 12.sp)),
            ]),
          ],
          if (gymClass.instructorName != null) ...[
            vGap(4),
            Row(children: [
              Icon(Icons.person_outline,
                  color: AppColors.grey, size: 14.r),
              hGap(4),
              Text(gymClass.instructorName!,
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 12.sp)),
            ]),
          ],
          vGap(10),
          // Spots + Book button
          Row(
            children: [
              // Spots remaining
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: gymClass.isFull
                      ? AppColors.red.withValues(alpha: 0.1)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: gymClass.isFull
                        ? AppColors.red.withValues(alpha: 0.4)
                        : AppColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  gymClass.isFull
                      ? '🔴 Full'
                      : '🟢 ${gymClass.spotsRemaining} spots left',
                  style: TextStyle(
                      color: gymClass.isFull
                          ? AppColors.red
                          : Colors.white,
                      fontSize: 12.sp),
                ),
              ),
              const Spacer(),
              if (gymClass.isPast)
                Text('Ended',
                    style: TextStyle(
                        color: AppColors.grey, fontSize: 12.sp))
              else if (gymClass.alreadyBooked)
                _ActionButton(
                  label: 'Cancel',
                  color: AppColors.red,
                  icon: Icons.cancel_outlined,
                  onTap: onCancel,
                )
              else if (gymClass.isFull)
                Text('Full',
                    style: TextStyle(
                        color: AppColors.grey, fontSize: 12.sp))
              else
                _ActionButton(
                  label: gymClass.isPaid ? 'Book · Pay' : 'Book',
                  color: AppColors.teal,
                  icon: Icons.event_available_outlined,
                  onTap: onBook,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14.r),
            hGap(6),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
