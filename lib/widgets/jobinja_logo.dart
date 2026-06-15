import 'package:flutter/material.dart';
import '../utils/constants.dart';

class JobinjaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? iconColor;

  const JobinjaLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _JobinjaLogoPainter(color: iconColor ?? AppColors.primary),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.3),
          Text(
            'جابینجا',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: size * 0.45,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
        ],
      ],
    );
  }
}

class _JobinjaLogoPainter extends CustomPainter {
  final Color color;

  _JobinjaLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    final w = size.width;
    final h = size.height;
    final pad = w * 0.08;

    final clipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, h * 0.06, w * 0.7, h * 0.88),
      Radius.circular(w * 0.08),
    );

    canvas.drawRRect(clipRect, paint..color = Colors.white);

    canvas.drawRRect(clipRect, strokePaint..color = color.withValues(alpha: 0.3));

    final linePaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;

    final lineH = h * 0.06;
    final lineX = pad + w * 0.07;
    final lineW = w * 0.56;

    for (int i = 0; i < 3; i++) {
      final y = h * 0.18 + i * (lineH + h * 0.035);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lineX, y, lineW, lineH),
          Radius.circular(lineH * 0.3),
        ),
        linePaint,
      );
    }

    final shortW = w * 0.35;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineX, h * 0.18 + 3 * (lineH + h * 0.035), shortW, lineH),
        Radius.circular(lineH * 0.3),
      ),
      linePaint,
    );

    final bottomH = h * 0.1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineX, h * 0.18 + 4 * (lineH + h * 0.035) + h * 0.03, lineW, bottomH),
        Radius.circular(bottomH * 0.3),
      ),
      linePaint,
    );

    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final checkPath = Path();
    final cx = w * 0.78;
    final cy = h * 0.42;
    final s = w * 0.16;

    checkPath.moveTo(cx - s * 0.5, cy);
    checkPath.lineTo(cx - s * 0.15, cy + s * 0.4);
    checkPath.lineTo(cx + s * 0.6, cy - s * 0.35);
    checkPath.lineTo(cx - s * 0.15, cy + s * 0.6);
    checkPath.close();

    canvas.drawPath(checkPath, checkPaint);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRRect(
      clipRect.shift(const Offset(0, 2)),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _JobinjaLogoPainter oldDelegate) => oldDelegate.color != color;
}

class JobinjaIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const JobinjaIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _JobinjaLogoPainter(color: color ?? AppColors.primary),
      ),
    );
  }
}
