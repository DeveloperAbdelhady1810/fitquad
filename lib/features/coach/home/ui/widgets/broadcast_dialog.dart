import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

Future<void> showBroadcastDialog(BuildContext context) async {
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const _BroadcastSheet(),
    ),
  );
}

class _BroadcastSheet extends StatefulWidget {
  const _BroadcastSheet();

  @override
  State<_BroadcastSheet> createState() => _BroadcastSheetState();
}

class _BroadcastSheetState extends State<_BroadcastSheet> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty) {
      setState(() => _error = 'Please type a message');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final res = await ApiClient.post('/coach/broadcast', {'body': body});
      final count = res['data']?['sent_to'] as int? ?? 0;
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Broadcast sent to $count members ✅'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined,
                  color: AppColors.purple, size: 20.r),
              hGap(10),
              Text('Broadcast Message',
                  style: AppTextStyles.font16WhiteBold),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          vGap(6),
          Text(
            'Send a message to all your members at once.',
            style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
          ),
          vGap(16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.25)),
            ),
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.purple, size: 14.r),
                hGap(8),
                Expanded(
                  child: Text(
                    'This message will be sent to all members who have sessions with you.',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 11.sp, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
          vGap(14),

          TextField(
            controller: _ctrl,
            style: AppTextStyles.font14WhiteRegular,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your announcement or motivation message…',
              hintStyle: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
              filled: true,
              fillColor: AppColors.primary,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none),
            ),
          ),

          if (_error != null) ...[
            vGap(8),
            Text(_error!,
                style: TextStyle(color: AppColors.red, fontSize: 12.sp)),
          ],

          vGap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.send_outlined, size: 18.r),
              label: Text(_sending ? 'Sending…' : 'Send to All Members'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                textStyle: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          vGap(8),
        ],
      ),
    );
  }
}
