import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Conic "match %" ring — animates its sweep in on first appearance.
class MatchRing extends StatefulWidget {
  final int percent;
  final double size;
  final Color progressColor;
  final Color trackColor;
  final Color textColor;
  final double strokeWidth;
  final double fontSize;

  const MatchRing({
    super.key,
    required this.percent,
    this.size = 46,
    this.progressColor = AppColors.accent,
    this.trackColor = AppColors.accentTint,
    this.textColor = AppColors.primary,
    this.strokeWidth = 5,
    this.fontSize = 11,
  });

  /// White-on-gradient variant used on hero cards.
  const MatchRing.onGradient({
    super.key,
    required this.percent,
    this.size = 46,
    this.strokeWidth = 5,
    this.fontSize = 11,
  }) : progressColor = Colors.white,
       trackColor = const Color(0x47FFFFFF),
       textColor = Colors.white;

  @override
  State<MatchRing> createState() => _MatchRingState();
}

class _MatchRingState extends State<MatchRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _RingPainter(
              value: (widget.percent / 100) * _animation.value,
              progressColor: widget.progressColor,
              trackColor: widget.trackColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: Text(
                '${widget.percent}%',
                style: AppText.badgeLabel.copyWith(
                  color: widget.textColor,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.value,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.progressColor != progressColor;
}
