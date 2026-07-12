import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

enum _InterviewLocation { googleMeet, campus }

class SchedulerScreen extends StatefulWidget {
  final Applicant applicant;
  const SchedulerScreen({super.key, required this.applicant});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  static const _slots = [
    '9:00 AM',
    '10:00 AM',
    '11:30 AM',
    '2:00 PM',
    '4:30 PM',
    '5:30 PM',
  ];

  final Set<int> selectedSlots = {};
  _InterviewLocation location = _InterviewLocation.googleMeet;

  void _toggleSlot(int i) {
    setState(() {
      if (selectedSlots.contains(i)) {
        selectedSlots.remove(i);
      } else if (selectedSlots.length < 3) {
        selectedSlots.add(i);
      }
    });
  }

  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    final slots = selectedSlots.map((i) => _slots[i]).toList();
    final locationLabel = location == _InterviewLocation.googleMeet
        ? 'Google Meet'
        : 'On-campus room';
    try {
      if (widget.applicant.isLive) {
        await MarketplaceRepository.instance.proposeInterview(
          widget.applicant,
          slots: slots,
          location: locationLabel,
        );
      }
      if (!mounted) return;
      showAppToast(context, 'Proposed slots sent to ${widget.applicant.name}');
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      showAppToast(
        context,
        "Couldn't send. Please try again.",
        icon: Symbols.error_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = selectedSlots.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleIconButton(
                icon: Symbols.close_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 14),
              const Text(
                'Schedule interview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.applicant.opportunityTitle.isEmpty
                    ? widget.applicant.name
                    : '${widget.applicant.name} · ${widget.applicant.opportunityTitle}',
                style: AppText.body.copyWith(
                  color: AppColors.inkSecondary,
                  fontSize: 13.5,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _calendarCard(),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              'Propose time slots · Thu, Jul 9',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentTint,
                              borderRadius: BorderRadius.circular(
                                AppShape.pill,
                              ),
                            ),
                            child: Text(
                              '$n of 3',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentDeepText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.1,
                        children: List.generate(_slots.length, _slotPill),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _locationOption(
                        selected: location == _InterviewLocation.googleMeet,
                        icon: Symbols.videocam_rounded,
                        title: 'Google Meet',
                        subtitle: 'Link is generated automatically',
                        onTap: () => setState(
                          () => location = _InterviewLocation.googleMeet,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _locationOption(
                        selected: location == _InterviewLocation.campus,
                        icon: Symbols.location_on_rounded,
                        title: 'On-campus room',
                        subtitle: 'e.g. Innovation Hub · Room 2',
                        onTap: () => setState(
                          () => location = _InterviewLocation.campus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BrandButton(
                label: _sending ? 'Sending…' : 'Send $n proposed slots',
                leadingIcon: Symbols.send_rounded,
                onPressed: n == 0 || _sending ? null : _send,
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.applicant.name} picks one in chat — it lands on both calendars.',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Symbols.chevron_left_rounded, color: AppColors.inkFaint),
              Text(
                'July 2026',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              Icon(Symbols.chevron_right_rounded, color: AppColors.inkFaint),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: _weekdayLabels()),
          const SizedBox(height: 10),
          Row(children: List.generate(7, (i) => _dayCell(6 + i))),
          const SizedBox(height: 8),
          Row(children: List.generate(7, (i) => _dayCell(13 + i))),
        ],
      ),
    );
  }

  List<Widget> _weekdayLabels() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return List.generate(7, (i) {
      final weekend = i >= 5;
      return Expanded(
        child: Center(
          child: Text(
            labels[i],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: weekend ? AppColors.inkFaint : AppColors.inkSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _dayCell(int day) {
    final highlighted = day == 8;
    final selected = day == 9;
    return Expanded(
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primary : Colors.transparent,
            border: highlighted
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
            boxShadow: selected ? AppShape.ctaShadow(AppColors.primary) : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _slotPill(int i) {
    final selected = selectedSlots.contains(i);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(AppShape.pill),
        border: selected
            ? null
            : Border.all(color: AppColors.hairline, width: 1.5),
        boxShadow: selected ? AppShape.ctaShadow(AppColors.primary) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppShape.pill),
          onTap: () => _toggleSlot(i),
          child: Center(
            child: Text(
              _slots[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationOption({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentTint : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.hairline,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.inkSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.caption.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Symbols.radio_button_checked_rounded
                    : Symbols.radio_button_unchecked_rounded,
                size: 22,
                color: selected ? AppColors.primary : AppColors.inkFaint,
                fill: selected ? 1 : 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
