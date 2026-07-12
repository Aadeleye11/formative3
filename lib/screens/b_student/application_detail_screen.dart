import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'chat_thread_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  void _withdraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          'You can reapply later, but your place in the pipeline will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(
                () => widget.application.status = ApplicationStatus.declined,
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();
              if (widget.application.isLive) {
                await MarketplaceRepository.instance.updateStatus(
                  widget.application.id,
                  ApplicationStatus.declined,
                );
              }
            },
            child: const Text(
              'Withdraw',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _join() async {
    final info = widget.application.interviewInfo;
    await Clipboard.setData(
      ClipboardData(
        text: info == null || info.isEmpty
            ? 'https://meet.google.com/new'
            : '$info · https://meet.google.com/new',
      ),
    );
    if (!mounted) return;
    showAppToast(context, 'Meeting link copied');
  }

  void _reschedule() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ask to reschedule?'),
        content: const Text(
          "We'll let the founder know you'd like a different time.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (widget.application.isLive) {
                await MarketplaceRepository.instance.requestReschedule(
                  widget.application,
                );
              }
              if (!mounted) return;
              showAppToast(context, 'Reschedule request sent');
            },
            child: const Text('Ask to reschedule'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.application;
    final isInterview = a.status == ApplicationStatus.interview;
    final isAccepted = a.status == ApplicationStatus.accepted;
    final isDeclined = a.status == ApplicationStatus.declined;
    final isResolved = isAccepted || isDeclined;
    final hadInterview = (a.interviewInfo ?? '').isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShape.cardShadow,
                ),
                child: Row(
                  children: [
                    LogoTile(startup: a.opportunity.startup),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.opportunity.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                a.opportunity.startup.name,
                                style: AppText.caption.copyWith(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              const VerifiedBadge(pillStyle: false),
                              const SizedBox(width: 4),
                              Text(
                                '· ${a.appliedLabel}',
                                style: AppText.caption.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: a.status),
                  ],
                ),
              ),
              if (isAccepted) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.celebration_rounded,
                        size: 18,
                        color: AppColors.successDeep,
                        fill: 1,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You got the offer! ${a.opportunity.startup.name} will follow up about next steps.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isDeclined) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.info_rounded,
                        size: 18,
                        color: AppColors.inkSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "This one didn't work out — keep exploring, new roles are posted often.",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShape.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const TimelineRow(
                          state: TimelineNodeState.done,
                          title: 'Applied',
                          subtitle: 'profile + passport shared',
                        ),
                        const TimelineRow(
                          state: TimelineNodeState.done,
                          title: 'Reviewed',
                          subtitle: 'moved forward by the founder',
                        ),
                        TimelineRow(
                          state: isInterview
                              ? TimelineNodeState.current
                              : hadInterview
                              ? TimelineNodeState.done
                              : TimelineNodeState.next,
                          activeColor: AppColors.accent,
                          title: 'Interview scheduled',
                          subtitle: a.interviewInfo ?? 'Scheduling in progress',
                          trailing: isInterview
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: PrimaryButton(
                                          label: 'Join',
                                          leadingIcon: Symbols.videocam_rounded,
                                          height: 40,
                                          onPressed: _join,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlineAppButton(
                                        label: 'Reschedule',
                                        height: 40,
                                        onPressed: _reschedule,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        TimelineRow(
                          state: isResolved
                              ? TimelineNodeState.done
                              : TimelineNodeState.next,
                          title: 'Decision',
                          subtitle: isAccepted
                              ? '🎉 You got the offer!'
                              : isDeclined
                              ? 'Not selected this time'
                              : 'Usually within 2 days of the interview',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Message ${a.opportunity.startup.name}',
                leadingIcon: Symbols.chat_bubble_rounded,
                height: 50,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatThreadScreen(
                      startupUid: a.opportunity.ownerUid ?? '',
                      startupName: a.opportunity.startup.name,
                      startupGradientSeed: MarketplaceRepository.instance
                          .gradientSeedFor(a.opportunity.startup.gradient),
                    ),
                  ),
                ),
              ),
              if (!isResolved) ...[
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: _withdraw,
                    child: const Text(
                      'Withdraw application',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
