import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme.dart';

enum TimelineNodeState { done, current, next }

/// One row of a vertical status timeline: node + connector + title/subtitle + optional trailing content.
class TimelineRow extends StatelessWidget {
  final TimelineNodeState state;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isLast;
  final Color activeColor;

  const TimelineRow({
    super.key,
    required this.state,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isLast = false,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _Node(state: state, activeColor: activeColor),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: state == TimelineNodeState.done
                        ? AppColors.success
                        : AppColors.hairline,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: state == TimelineNodeState.next
                          ? AppColors.inkMuted
                          : (state == TimelineNodeState.current
                                ? activeColor
                                : AppColors.ink),
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: state == TimelineNodeState.next
                              ? const Color(0xFFA9ACBA)
                              : AppColors.inkSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: trailing!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  final TimelineNodeState state;
  final Color activeColor;
  const _Node({required this.state, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TimelineNodeState.done:
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.check_rounded,
            size: 15,
            color: Colors.white,
            weight: 700,
          ),
        );
      case TimelineNodeState.current:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: activeColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: .15),
                blurRadius: 0,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      case TimelineNodeState.next:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD6D8E1), width: 2),
          ),
        );
    }
  }
}
