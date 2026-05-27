import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/repositories/member_repository.dart';

class ProgressPhotosTab extends StatefulWidget {
  const ProgressPhotosTab({super.key});

  @override
  State<ProgressPhotosTab> createState() => _ProgressPhotosTabState();
}

class _ProgressPhotosTabState extends State<ProgressPhotosTab> {
  List<dynamic> _photos = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final photos = await MemberRepository.getProgressPhotos();
      if (mounted) setState(() { _photos = photos; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;

    String? notes;
    double? weight;
    await _showUploadDialog(onConfirm: (n, w) {
      notes = n;
      weight = w;
    });

    setState(() => _uploading = true);
    try {
      await MemberRepository.uploadProgressPhoto(
        photo: File(picked.path),
        notes: notes,
        weight: weight,
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _showUploadDialog({
    required void Function(String? notes, double? weight) onConfirm,
  }) async {
    final notesCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.w, right: 20.w, top: 24.h,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Progress Photo', style: AppTextStyles.font16WhiteBold),
            vGap(16),
            TextField(
              controller: weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.font14WhiteRegular,
              decoration: _inputDeco('Current weight (kg) — optional'),
            ),
            vGap(12),
            TextField(
              controller: notesCtrl,
              style: AppTextStyles.font14WhiteRegular,
              decoration: _inputDeco('Notes — optional'),
              maxLines: 2,
            ),
            vGap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () {
                  final w = double.tryParse(weightCtrl.text.trim());
                  final n = notesCtrl.text.trim().isEmpty
                      ? null
                      : notesCtrl.text.trim();
                  onConfirm(n, w);
                  Navigator.pop(ctx);
                },
                child: Text('Upload Photo',
                    style: AppTextStyles.font16WhiteBold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.font14GreyRegular,
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.teal),
        ),
      );

  Future<void> _deletePhoto(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Delete Photo', style: AppTextStyles.font16WhiteBold),
        content: Text('Remove this progress photo?',
            style: AppTextStyles.font14GreyRegular),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.font14GreyRegular),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await MemberRepository.deleteProgressPhoto(id);
      setState(() => _photos.removeWhere((p) => p['id'] == id));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.teal));
    }

    return Stack(
      children: [
        if (_photos.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera_outlined,
                    size: 72.r, color: AppColors.grey),
                vGap(16),
                Text('No progress photos yet.',
                    style: AppTextStyles.font16WhiteBold,
                    textAlign: TextAlign.center),
                vGap(8),
                Text('Take one now to start your transformation timeline.',
                    style: AppTextStyles.font14GreyRegular,
                    textAlign: TextAlign.center),
                vGap(24),
                ElevatedButton.icon(
                  onPressed: _pickAndUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined,
                      color: Colors.white),
                  label: Text('Add Photo',
                      style: AppTextStyles.font14WhiteRegular),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
            itemCount: _photos.length,
            separatorBuilder: (_, __) => vGap(16),
            itemBuilder: (context, i) {
              final photo = _photos[i] as Map<String, dynamic>;
              final id = photo['id'] as int? ?? 0;
              final url = photo['photo_url'] as String? ?? '';
              final weight = (photo['weight_at_time'] as num?)?.toDouble();
              final notes = photo['notes'] as String?;
              final takenAt = photo['taken_at'] as String?;
              final dateStr = takenAt != null
                  ? DateFormat('MMM d, yyyy')
                      .format(DateTime.tryParse(takenAt) ?? DateTime.now())
                  : '';

              return _PhotoCard(
                url: url,
                dateStr: dateStr,
                weight: weight,
                notes: notes,
                onDelete: () => _deletePhoto(id),
              );
            },
          ),

        // Upload FAB
        if (_photos.isNotEmpty)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton(
              backgroundColor: AppColors.teal,
              onPressed: _uploading ? null : _pickAndUpload,
              child: _uploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.add_a_photo_outlined, color: Colors.white),
            ),
          ),

        if (_uploading && _photos.isEmpty)
          const Center(
              child: CircularProgressIndicator(color: AppColors.teal)),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String url;
  final String dateStr;
  final double? weight;
  final String? notes;
  final VoidCallback onDelete;

  const _PhotoCard({
    required this.url,
    required this.dateStr,
    required this.weight,
    required this.notes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          AspectRatio(
            aspectRatio: 4 / 5,
            child: url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primary,
                      child: Icon(Icons.broken_image_outlined,
                          color: AppColors.grey, size: 48.r),
                    ),
                  )
                : Container(
                    color: AppColors.primary,
                    child: Icon(Icons.image_outlined,
                        color: AppColors.grey, size: 48.r),
                  ),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: AppTextStyles.font14GreyRegular),
                    if (weight != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: AppColors.teal.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${weight!.toStringAsFixed(1)} kg',
                          style: AppTextStyles.font14GreyRegular.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                if (notes != null && notes!.isNotEmpty) ...[
                  vGap(6),
                  Text(notes!,
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 12.sp)),
                ],
                vGap(10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.red,
                        padding: EdgeInsets.zero),
                    icon: Icon(Icons.delete_outline, size: 16.r),
                    label: Text('Delete',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: AppColors.red, fontSize: 12.sp)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
