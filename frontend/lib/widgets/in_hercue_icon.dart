import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum InHercueIconType {
  home,
  records,
  plus,
  learn,
  user,
  heart,
  moon,
  calendar,
  chart,
  sparkle,
  shield,
  bell,
  chevron,
  back,
  alert,
  search,
}

/// Custom vector icon widget implementing the exact 16 SVG icons from inHercue Figma design.
/// Rendered natively on a 24x24 coordinate canvas with 1.8px stroke width and round caps.
class InHercueIcon extends StatelessWidget {
  final InHercueIconType icon;
  final double size;
  final Color? color;

  const InHercueIcon({
    super.key,
    required this.icon,
    this.size = 22.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? AppColors.plum;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _InHercueIconPainter(icon: icon, color: iconColor),
      ),
    );
  }
}

class _InHercueIconPainter extends CustomPainter {
  final InHercueIconType icon;
  final Color color;

  _InHercueIconPainter({required this.icon, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * (size.width / 24.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final path = Path();

    switch (icon) {
      case InHercueIconType.home:
        path.moveTo(3, 11.5);
        path.lineTo(12, 4);
        path.lineTo(21, 11.5);
        canvas.drawPath(path, paint);

        final body = Path();
        body.moveTo(5.5, 10);
        body.lineTo(5.5, 20);
        body.lineTo(18.5, 20);
        body.lineTo(18.5, 10);
        body.moveTo(9, 20);
        body.lineTo(9, 14);
        body.lineTo(15, 14);
        body.lineTo(15, 20);
        canvas.drawPath(body, paint);
        break;

      case InHercueIconType.records:
        path.moveTo(5, 3);
        path.lineTo(16, 3);
        path.lineTo(19, 6);
        path.lineTo(19, 21);
        path.lineTo(5, 21);
        path.close();
        path.moveTo(8, 9);
        path.lineTo(16, 9);
        path.moveTo(8, 13);
        path.lineTo(16, 13);
        path.moveTo(8, 17);
        path.lineTo(13, 17);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.plus:
        path.moveTo(12, 5);
        path.lineTo(12, 19);
        path.moveTo(5, 12);
        path.lineTo(19, 12);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.learn:
        // Left page
        path.moveTo(4, 5.5);
        path.cubicTo(4, 4.5, 5.5, 4, 8, 4);
        path.lineTo(12, 4);
        path.lineTo(12, 20);
        path.lineTo(8, 20);
        path.cubicTo(5.5, 20, 4, 20.5, 4, 21);
        path.close();
        // Right page
        path.moveTo(20, 5.5);
        path.cubicTo(20, 4.5, 18.5, 4, 16, 4);
        path.lineTo(12, 4);
        path.lineTo(12, 20);
        path.lineTo(16, 20);
        path.cubicTo(18.5, 20, 20, 20.5, 20, 21);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.user:
        canvas.drawCircle(const Offset(12, 8), 4, paint);
        path.moveTo(4, 21);
        path.cubicTo(4, 16.5, 7.5, 13, 12, 13);
        path.cubicTo(16.5, 13, 20, 16.5, 20, 21);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.heart:
        path.moveTo(12, 6.9);
        path.cubicTo(10, 4.5, 6, 4.5, 4.2, 6.5);
        path.cubicTo(2.4, 8.5, 2.4, 12, 5, 14.8);
        path.lineTo(12, 21.5);
        path.lineTo(19, 14.8);
        path.cubicTo(21.6, 12, 21.6, 8.5, 19.8, 6.5);
        path.cubicTo(18, 4.5, 14, 4.5, 12, 6.9);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.moon:
        path.moveTo(20.5, 15.5);
        path.cubicTo(14, 15.5, 8.5, 10, 8.5, 3.5);
        path.cubicTo(4, 6.5, 2, 12, 4.5, 16.5);
        path.cubicTo(7, 21, 13, 22.5, 17.5, 20);
        path.cubicTo(18.8, 19.2, 19.8, 17.5, 20.5, 15.5);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.calendar:
        final rrect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 5, 18, 16),
          const Radius.circular(3),
        );
        canvas.drawRRect(rrect, paint);
        path.moveTo(8, 3);
        path.lineTo(8, 7);
        path.moveTo(16, 3);
        path.lineTo(16, 7);
        path.moveTo(3, 10);
        path.lineTo(21, 10);
        // Dots
        path.moveTo(8, 14);
        path.lineTo(8.01, 14);
        path.moveTo(12, 14);
        path.lineTo(12.01, 14);
        path.moveTo(16, 14);
        path.lineTo(16.01, 14);
        path.moveTo(8, 18);
        path.lineTo(8.01, 18);
        path.moveTo(12, 18);
        path.lineTo(12.01, 18);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.chart:
        path.moveTo(4, 20);
        path.lineTo(4, 10);
        path.moveTo(10, 20);
        path.lineTo(10, 4);
        path.moveTo(16, 20);
        path.lineTo(16, 13);
        path.moveTo(22, 20);
        path.lineTo(2, 20);
        path.moveTo(4, 9);
        path.lineTo(10, 4);
        path.lineTo(16, 12);
        path.lineTo(21, 8);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.sparkle:
        // Main star
        path.moveTo(12, 3);
        path.lineTo(13.4, 7.1);
        path.lineTo(17.5, 9);
        path.lineTo(13.4, 10.7);
        path.lineTo(12, 15);
        path.lineTo(10.6, 10.7);
        path.lineTo(6.5, 9);
        path.lineTo(10.6, 7.1);
        path.close();
        // Secondary small sparkle
        path.moveTo(19, 15);
        path.lineTo(19.7, 17.3);
        path.lineTo(22, 18);
        path.lineTo(19.7, 18.7);
        path.lineTo(19, 21);
        path.lineTo(18.3, 18.7);
        path.lineTo(16, 18);
        path.lineTo(18.3, 17.3);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.shield:
        path.moveTo(12, 2);
        path.lineTo(20, 5);
        path.lineTo(20, 11);
        path.cubicTo(20, 16.5, 16, 20.5, 12, 22);
        path.cubicTo(8, 20.5, 4, 16.5, 4, 11);
        path.lineTo(4, 5);
        path.close();
        // Checkmark inside shield
        path.moveTo(9, 12);
        path.lineTo(11, 14);
        path.lineTo(15, 9);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.bell:
        path.moveTo(18, 8);
        path.cubicTo(18, 4.7, 15.3, 2, 12, 2);
        path.cubicTo(8.7, 2, 6, 4.7, 6, 8);
        path.cubicTo(6, 13, 3, 15, 3, 17);
        path.lineTo(21, 17);
        path.cubicTo(21, 15, 18, 13, 18, 8);
        path.moveTo(10, 19);
        path.cubicTo(10, 20.5, 10.9, 21.5, 12, 21.5);
        path.cubicTo(13.1, 21.5, 14, 20.5, 14, 19);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.chevron:
        path.moveTo(9, 18);
        path.lineTo(15, 12);
        path.lineTo(9, 6);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.back:
        path.moveTo(15, 18);
        path.lineTo(9, 12);
        path.lineTo(15, 6);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.alert:
        path.moveTo(10.3, 3.7);
        path.lineTo(2.2, 18);
        path.cubicTo(1.4, 19.5, 2.5, 21, 4, 21);
        path.lineTo(20, 21);
        path.cubicTo(21.5, 21, 22.6, 19.5, 21.8, 18);
        path.lineTo(13.7, 3.7);
        path.cubicTo(12.9, 2.3, 11.1, 2.3, 10.3, 3.7);
        path.close();
        path.moveTo(12, 9);
        path.lineTo(12, 13);
        path.moveTo(12, 17);
        path.lineTo(12.01, 17);
        canvas.drawPath(path, paint);
        break;

      case InHercueIconType.search:
        canvas.drawCircle(const Offset(11, 11), 7, paint);
        path.moveTo(20, 20);
        path.lineTo(16, 16);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _InHercueIconPainter oldDelegate) {
    return oldDelegate.icon != icon || oldDelegate.color != color;
  }
}
