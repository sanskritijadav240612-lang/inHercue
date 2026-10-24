import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A custom painter that draws a smooth, elegant bezier curve and gradient fill
/// matching the SVG mini-chart from the React reference (.mini-chart in src/index.css).
class MiniChartWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const MiniChartWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = AppColors.plum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          SizedBox(
            height: 100.0,
            child: CustomPaint(
              painter: _CurveChartPainter(),
              size: const Size(double.infinity, 100.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurveChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final fillPath = Path();
    fillPath.moveTo(0, height * 0.75);
    fillPath.cubicTo(
      width * 0.15,
      height * 0.65,
      width * 0.20,
      height * 0.25,
      width * 0.35,
      height * 0.45,
    );
    fillPath.cubicTo(
      width * 0.45,
      height * 0.75,
      width * 0.55,
      height * 0.45,
      width * 0.68,
      height * 0.20,
    );
    fillPath.cubicTo(
      width * 0.80,
      height * 0.42,
      width * 0.90,
      height * 0.55,
      width,
      height * 0.25,
    );
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = const Color(0xFFDCAEB1).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final strokePath = Path();
    strokePath.moveTo(0, height * 0.75);
    strokePath.cubicTo(
      width * 0.15,
      height * 0.65,
      width * 0.20,
      height * 0.25,
      width * 0.35,
      height * 0.45,
    );
    strokePath.cubicTo(
      width * 0.45,
      height * 0.75,
      width * 0.55,
      height * 0.45,
      width * 0.68,
      height * 0.20,
    );
    strokePath.cubicTo(
      width * 0.80,
      height * 0.42,
      width * 0.90,
      height * 0.55,
      width,
      height * 0.25,
    );

    final strokePaint = Paint()
      ..color = const Color(0xFFDCAEB1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
