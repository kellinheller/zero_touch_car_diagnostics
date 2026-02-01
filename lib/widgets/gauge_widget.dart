import 'package:flutter/material.dart';
import 'dart:math';

/// Animated circular gauge widget for displaying values
class GaugeWidget extends StatefulWidget {
  final String label;
  final double value;
  final double maxValue;
  final String unit;
  final Color color;
  final Color backgroundColor;

  const GaugeWidget({
    required this.label,
    required this.value,
    required this.maxValue,
    this.unit = '',
    this.color = Colors.blue,
    this.backgroundColor = const Color(0xFF1a1a1a),
  });

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _updateAnimation();
  }

  void _updateAnimation() {
    _animation = Tween<double>(
      begin: 0,
      end: (widget.value / widget.maxValue).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(GaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getValueColor() {
    final percentage = (widget.value / widget.maxValue);
    if (percentage >= 0.9) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gauge Display
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.backgroundColor,
                  border: Border.all(
                    color: Colors.grey[700]!,
                    width: 2,
                  ),
                ),
              ),

              // Gauge arc
              CustomPaint(
                size: const Size(150, 150),
                painter: GaugePainter(
                  percentage: _animation.value,
                  color: _getValueColor(),
                  backgroundColor: Colors.grey[700]!,
                ),
              ),

              // Center value display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.value.toStringAsFixed(1),
                    style: TextStyle(
                      color: _getValueColor(),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.unit.isNotEmpty)
                    Text(
                      widget.unit,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Label
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Value range
        Text(
          '0 - ${widget.maxValue.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for gauge arc
class GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  GaugePainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Draw background arc (full circle)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Arc from -90 degrees (top) going clockwise
    const startAngle = -pi / 2;
    final sweepAngle = (2 * pi) * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.grey[600]!,
    );
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
