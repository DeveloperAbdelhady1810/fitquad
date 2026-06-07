import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../data/partner_gym_repository.dart';
import '../models/gym_guest_invitation_model.dart';

class GuestPassesScreen extends StatefulWidget {
  static const routeName = '/guest-passes';

  const GuestPassesScreen({super.key});

  @override
  State<GuestPassesScreen> createState() => _GuestPassesScreenState();
}

class _GuestPassesScreenState extends State<GuestPassesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late Future<({List<GymGuestPassQuotaModel> memberships, List<GymGuestInvitationModel> invitations})>
      _sentFuture;
  late Future<List<GymGuestInvitationModel>> _receivedFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sentFuture = PartnerGymRepository.getGuestInvitations();
    _receivedFuture = PartnerGymRepository.getMyGuestPasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadSent() => setState(() {
        _sentFuture = PartnerGymRepository.getGuestInvitations();
      });

  void _reloadReceived() => setState(() {
        _receivedFuture = PartnerGymRepository.getMyGuestPasses();
      });

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.toString().replaceFirst('Exception: ', '')),
      backgroundColor: AppColors.red,
    ));
  }

  Future<void> _showCreateInviteSheet(List<GymGuestPassQuotaModel> memberships) async {
    final eligible = memberships.where((m) => m.guestPassesRemaining > 0).toList();
    if (eligible.isEmpty) {
      _showError(Exception('No guest passes remaining on any of your memberships.'));
      return;
    }

    GymGuestPassQuotaModel selected = eligible.first;
    DateTime visitDate = DateTime.now();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite a Friend', style: AppTextStyles.font16WhiteBold),
              vGap(6),
              Text('Your friend gets free entry to the gym on the date you pick.',
                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp)),
              vGap(18),
              Text('Gym membership', style: AppTextStyles.font14GreyRegular),
              vGap(6),
              DropdownButtonFormField<GymGuestPassQuotaModel>(
                initialValue: selected,
                dropdownColor: AppColors.primary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primary,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: eligible
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            '${m.gymName} · ${m.guestPassesRemaining}/${m.guestPassesTotal} left',
                            style: AppTextStyles.font14WhiteRegular,
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selected = v);
                },
              ),
              vGap(16),
              Text('Visit date', style: AppTextStyles.font14GreyRegular),
              vGap(6),
              InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: visitDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setSheetState(() => visitDate = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppColors.teal, size: 16.r),
                    hGap(10),
                    Text(DateFormat('EEE, d MMM yyyy').format(visitDate),
                        style: AppTextStyles.font14WhiteRegular),
                  ]),
                ),
              ),
              vGap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          setSheetState(() => saving = true);
                          try {
                            await PartnerGymRepository.createGuestInvitation(
                                selected.gymMembershipId, visitDate);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _reloadSent();
                          } catch (e) {
                            setSheetState(() => saving = false);
                            _showError(e);
                          }
                        },
                  child: saving
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Create Invite', style: AppTextStyles.font14WhiteRegular),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRescheduleSheet(GymGuestInvitationModel invitation) async {
    DateTime visitDate = invitation.visitDate;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reschedule Invite', style: AppTextStyles.font16WhiteBold),
              vGap(16),
              InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: visitDate.isBefore(DateTime.now()) ? DateTime.now() : visitDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setSheetState(() => visitDate = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppColors.teal, size: 16.r),
                    hGap(10),
                    Text(DateFormat('EEE, d MMM yyyy').format(visitDate),
                        style: AppTextStyles.font14WhiteRegular),
                  ]),
                ),
              ),
              vGap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          setSheetState(() => saving = true);
                          try {
                            await PartnerGymRepository.rescheduleGuestInvitation(
                                invitation.id, visitDate);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _reloadSent();
                          } catch (e) {
                            setSheetState(() => saving = false);
                            _showError(e);
                          }
                        },
                  child: saving
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Save New Date', style: AppTextStyles.font14WhiteRegular),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelInvite(GymGuestInvitationModel invitation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Cancel Invite?', style: AppTextStyles.font16WhiteBold),
        content: Text('This will cancel the invite and free up your guest pass quota slot.',
            style: AppTextStyles.font14GreyRegular),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Back', style: TextStyle(color: AppColors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Cancel Invite', style: TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await PartnerGymRepository.cancelGuestInvitation(invitation.id);
      _reloadSent();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _redeemCode() async {
    final ctrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Redeem Invite Code', style: AppTextStyles.font16WhiteBold),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.font14WhiteRegular,
          decoration: InputDecoration(
            hintText: 'Enter the 8-character code',
            hintStyle: AppTextStyles.font14GreyRegular,
            filled: true,
            fillColor: AppColors.primary,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text('Redeem', style: TextStyle(color: AppColors.teal))),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    try {
      await PartnerGymRepository.redeemGuestInvitation(code.toUpperCase());
      _reloadReceived();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invite accepted! Your free pass is ready.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      _showError(e);
    }
  }

  void _showQrSheet(GymGuestInvitationModel invitation) {
    if (invitation.guestQrCode == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            vGap(20),
            Text('Your Guest Pass', style: AppTextStyles.font16WhiteBold),
            vGap(4),
            Text(invitation.gymName ?? 'Gym', style: AppTextStyles.font14GreyRegular),
            vGap(20),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: QrImageView(
                data: invitation.guestQrCode!,
                version: QrVersions.auto,
                size: 200.r,
              ),
            ),
            vGap(16),
            Text(
              invitation.canUseForEntry
                  ? 'Show this at the gym reception for free entry'
                  : 'Valid on ${DateFormat('EEE, d MMM yyyy').format(invitation.visitDate)} (until ${invitation.expiresAt != null ? DateFormat('d MMM').format(invitation.expiresAt!) : '—'})',
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Guest Passes', style: AppTextStyles.font16WhiteBold),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.teal,
          labelColor: AppColors.teal,
          unselectedLabelColor: AppColors.grey,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Invite a Friend'),
            Tab(text: 'My Guest Passes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSentTab(),
          _buildReceivedTab(),
        ],
      ),
    );
  }

  Widget _buildSentTab() {
    return FutureBuilder(
      future: _sentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.teal));
        }
        if (snapshot.hasError) {
          return _ErrorState(error: snapshot.error, onRetry: _reloadSent);
        }

        final data = snapshot.data!;
        final memberships = data.memberships;
        final invitations = data.invitations;

        return RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () async => _reloadSent(),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            children: [
              Text('Free Entries Remaining', style: AppTextStyles.font16WhiteBold),
              vGap(4),
              Text('Each subscription includes a limited number of free guest entries per cycle.',
                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp)),
              vGap(14),
              if (memberships.isEmpty)
                _EmptyCard(emoji: '🏋️', text: 'You have no active gym memberships.')
              else
                ...memberships.map((m) => Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.confirmation_number_outlined,
                              color: AppColors.teal, size: 20.r),
                        ),
                        hGap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.gymName,
                                  style: AppTextStyles.font14WhiteRegular
                                      .copyWith(fontWeight: FontWeight.w600)),
                              Text('${m.guestPassesRemaining} of ${m.guestPassesTotal} left this cycle',
                                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
                            ],
                          ),
                        ),
                        Text('${m.guestPassesRemaining}',
                            style: AppTextStyles.font16WhiteBold
                                .copyWith(color: AppColors.teal, fontSize: 20.sp)),
                      ]),
                    )),
              vGap(8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () => _showCreateInviteSheet(memberships),
                  icon: Icon(Icons.add, size: 18.r),
                  label: Text('New Invite', style: AppTextStyles.font14WhiteRegular),
                ),
              ),
              vGap(24),
              Text('Sent Invites', style: AppTextStyles.font16WhiteBold),
              vGap(12),
              if (invitations.isEmpty)
                _EmptyCard(emoji: '✉️', text: 'No invites sent yet.\nCreate one to bring a friend for free!')
              else
                ...invitations.map((inv) => _SentInviteCard(
                      invitation: inv,
                      onShare: () {
                        Share.share(
                          'Hey! I\'m inviting you to ${inv.gymName ?? 'my gym'} as my guest — completely free 🎉\n'
                          'Open FitQuad, go to "Redeem a Code" under Guest Passes, and enter this code: ${inv.code}\n'
                          'Visit date: ${DateFormat('EEE, d MMM yyyy').format(inv.visitDate)}',
                          subject: 'You\'re invited to FitQuad!',
                        );
                      },
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: inv.code));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Code copied!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ));
                      },
                      onReschedule: inv.canReschedule ? () => _showRescheduleSheet(inv) : null,
                      onCancel: (inv.isPending || inv.isAccepted) ? () => _cancelInvite(inv) : null,
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceivedTab() {
    return FutureBuilder<List<GymGuestInvitationModel>>(
      future: _receivedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.teal));
        }
        if (snapshot.hasError) {
          return _ErrorState(error: snapshot.error, onRetry: _reloadReceived);
        }

        final passes = snapshot.data ?? [];

        return RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () async => _reloadReceived(),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B3A6B), Color(0xFF0D2545)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.qr_code_2_outlined, color: AppColors.blue, size: 22.r),
                    hGap(8),
                    Text('Got an invite code?', style: AppTextStyles.font16WhiteBold),
                  ]),
                  vGap(8),
                  Text('Enter the code your friend shared with you to claim a free gym entry pass.',
                      style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp, height: 1.4)),
                  vGap(14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: _redeemCode,
                      icon: Icon(Icons.confirmation_number_outlined, size: 18.r),
                      label: Text('Redeem a Code', style: AppTextStyles.font14WhiteRegular),
                    ),
                  ),
                ]),
              ),
              vGap(24),
              Text('My Guest Passes', style: AppTextStyles.font16WhiteBold),
              vGap(12),
              if (passes.isEmpty)
                _EmptyCard(emoji: '🎟️', text: 'No guest passes yet.\nRedeem a friend\'s invite code to get one.')
              else
                ...passes.map((p) => _ReceivedPassCard(
                      invitation: p,
                      onShowQr: p.guestQrCode != null ? () => _showQrSheet(p) : null,
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _SentInviteCard extends StatelessWidget {
  final GymGuestInvitationModel invitation;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  const _SentInviteCard({
    required this.invitation,
    required this.onShare,
    required this.onCopy,
    this.onReschedule,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(invitation.gymName ?? 'Gym',
                style: AppTextStyles.font14WhiteRegular.copyWith(fontWeight: FontWeight.w600)),
          ),
          _StatusBadge(status: invitation.status, isExpired: invitation.isExpired),
        ]),
        vGap(4),
        Text('Visit date: ${DateFormat('EEE, d MMM yyyy').format(invitation.visitDate)}',
            style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
        if (invitation.invitedMember != null)
          Text('Friend: ${invitation.invitedMember!['name'] ?? 'Member'}',
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
        vGap(10),
        Row(children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(invitation.code,
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(letterSpacing: 2, color: AppColors.teal),
                  textAlign: TextAlign.center),
            ),
          ),
          hGap(8),
          IconButton(
            onPressed: onCopy,
            icon: Icon(Icons.copy_outlined, color: AppColors.teal, size: 18.r),
          ),
          IconButton(
            onPressed: onShare,
            icon: Icon(Icons.share_outlined, color: AppColors.teal, size: 18.r),
          ),
        ]),
        if (onReschedule != null || onCancel != null) ...[
          vGap(8),
          Row(children: [
            if (onReschedule != null)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.teal.withValues(alpha: 0.4)),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: onReschedule,
                  child: Text('Reschedule',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.teal, fontSize: 12.sp)),
                ),
              ),
            if (onReschedule != null && onCancel != null) hGap(8),
            if (onCancel != null)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.red.withValues(alpha: 0.4)),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: onCancel,
                  child: Text('Cancel',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.red, fontSize: 12.sp)),
                ),
              ),
          ]),
        ],
      ]),
    );
  }
}

class _ReceivedPassCard extends StatelessWidget {
  final GymGuestInvitationModel invitation;
  final VoidCallback? onShowQr;

  const _ReceivedPassCard({required this.invitation, this.onShowQr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.qr_code_2_outlined, color: AppColors.blue, size: 20.r),
        ),
        hGap(14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(invitation.gymName ?? 'Gym',
                style: AppTextStyles.font14WhiteRegular.copyWith(fontWeight: FontWeight.w600)),
            if (invitation.invitingMember != null)
              Text('From ${invitation.invitingMember!['name'] ?? 'a friend'}',
                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
            Text('Visit ${DateFormat('EEE, d MMM yyyy').format(invitation.visitDate)}',
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _StatusBadge(status: invitation.status, isExpired: invitation.isExpired),
          if (onShowQr != null) ...[
            vGap(6),
            GestureDetector(
              onTap: onShowQr,
              child: Icon(Icons.qr_code, color: AppColors.blue, size: 22.r),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isExpired;
  const _StatusBadge({required this.status, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    final effective = isExpired && (status == 'pending' || status == 'accepted') ? 'expired' : status;
    final colors = {
      'pending': AppColors.grey,
      'accepted': AppColors.blue,
      'used': AppColors.teal,
      'expired': AppColors.red,
      'cancelled': AppColors.red,
    };
    final labels = {
      'pending': 'Pending',
      'accepted': 'Accepted',
      'used': 'Used',
      'expired': 'Expired',
      'cancelled': 'Cancelled',
    };
    final color = colors[effective] ?? AppColors.grey;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(labels[effective] ?? effective,
          style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String emoji;
  final String text;
  const _EmptyCard({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(children: [
          Text(emoji, style: TextStyle(fontSize: 40.sp)),
          vGap(8),
          Text(text, style: AppTextStyles.font14GreyRegular, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.grey, size: 48.r),
          vGap(12),
          Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: AppTextStyles.font14GreyRegular,
            textAlign: TextAlign.center,
          ),
          vGap(16),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: TextStyle(color: AppColors.teal)),
          ),
        ],
      ),
    );
  }
}
