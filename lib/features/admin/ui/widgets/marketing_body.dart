import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_dropdown_menu.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';

class MarketingBody extends StatefulWidget {
  const MarketingBody({super.key});

  @override
  State<MarketingBody> createState() => _MarketingBodyState();
}

class _MarketingBodyState extends State<MarketingBody> {
  String? selectedFilter;
  List<dynamic> _promoCodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getPromoCodes();
      if (mounted) setState(() { _promoCodes = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: AppDecorations.containerDecoration,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promo Codes', style: AppTextStyles.font16WhiteBold),
                vGap(5),
                Text('Manage discounts and offers', style: AppTextStyles.font14GreyRegular),
                vGap(10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextFormField(
                        textInputType: TextInputType.text,
                        hintText: 'Enter Code',
                      ),
                    ),
                    hGap(5),
                    Expanded(flex: 1, child: CustomButton(text: 'Create', onPressed: () {})),
                  ],
                ),
                vGap(10),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_promoCodes.isEmpty)
                  const Center(child: Text('No promo codes', style: TextStyle(color: Colors.white54)))
                else
                  ..._promoCodes.map((e) {
                    final p = e as Map<String, dynamic>;
                    final code = p['code'] as String? ?? '-';
                    final type = p['discount_type'] as String? ?? 'percent';
                    final value = p['discount_value'];
                    final label = type == 'percent' ? '$value% off' : '\$$value off';
                    final isActive = (p['expires_at'] == null ||
                        DateTime.tryParse(p['expires_at'] as String? ?? '')
                            ?.isAfter(DateTime.now()) ==
                            true);
                    return ListTile(
                      title: Text(code, style: AppTextStyles.font16WhiteBold),
                      subtitle: Text(label, style: AppTextStyles.font14GreyRegular),
                      trailing: Switch(
                        value: isActive,
                        onChanged: (_) {},
                        activeThumbColor: AppColors.grey,
                      ),
                    );
                  }),
              ],
            ),
          ),
          vGap(10),
          Container(
            decoration: AppDecorations.containerDecoration,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Notifications', style: AppTextStyles.font16WhiteBold),
                vGap(5),
                Text('Send announcements to members', style: AppTextStyles.font14GreyRegular),
                vGap(10),
                Text('Audience', style: AppTextStyles.font14WhiteRegular),
                vGap(5),
                CustomDropdown<String>(
                  items: const ['All Members', 'Low Activity', 'Expiring Soon'],
                  labelBuilder: (e) => e,
                  hint: 'Select Filter',
                  onChanged: (value) => setState(() => selectedFilter = value),
                ),
                vGap(10),
                Text('Message', style: AppTextStyles.font14WhiteRegular),
                vGap(5),
                CustomTextFormField(
                  textInputType: TextInputType.text,
                  maxLines: 3,
                  hintText: 'Type your Announcement',
                ),
                vGap(5),
                CustomButton(text: 'Send', onPressed: () {}, color: Colors.blueAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
