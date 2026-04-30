import 'package:flutter/material.dart';

class PaintingDemo extends StatefulWidget {
  const PaintingDemo({super.key});

  @override
  State<PaintingDemo> createState() => _PaintingDemoState();
}

class _PaintingDemoState extends State<PaintingDemo> {
  double c1x = 0.85;
  double c1y = 0.08;
  double c2x = 0.15;
  double c2y = 0.92;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('S Bezier Curve'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: CustomPaint(
                      painter: SBezierPainter(
                        c1x: c1x,
                        c1y: c1y,
                        c2x: c2x,
                        c2y: c2y,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            _buildSlider(
              label: 'Control Point 1 X',
              value: c1x,
              onChanged: (value) {
                setState(() {
                  c1x = value;
                });
              },
            ),

            _buildSlider(
              label: 'Control Point 1 Y',
              value: c1y,
              onChanged: (value) {
                setState(() {
                  c1y = value;
                });
              },
            ),

            _buildSlider(
              label: 'Control Point 2 X',
              value: c2x,
              onChanged: (value) {
                setState(() {
                  c2x = value;
                });
              },
            ),

            _buildSlider(
              label: 'Control Point 2 Y',
              value: c2y,
              onChanged: (value) {
                setState(() {
                  c2y = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 100,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class SBezierPainter extends CustomPainter {
  const SBezierPainter({
    required this.c1x,
    required this.c1y,
    required this.c2x,
    required this.c2y,
  });

  final double c1x;
  final double c1y;
  final double c2x;
  final double c2y;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 32.0;

    final rect = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );

    Offset point(double x, double y) {
      return Offset(
        rect.left + rect.width * x,
        rect.top + rect.height * y,
      );
    }

    final start = point(0.08, 0.12);
    final end = point(0.92, 0.88);

    final control1 = point(c1x, c1y);
    final control2 = point(c2x, c2y);

    final curvePath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );

    final curvePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final helperPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    canvas.drawLine(start, control1, helperPaint);
    canvas.drawLine(control2, end, helperPaint);

    canvas.drawPath(curvePath, curvePaint);

    pointPaint.color = Colors.black;
    canvas.drawCircle(start, 6, pointPaint);
    canvas.drawCircle(end, 6, pointPaint);

    pointPaint.color = Colors.red;
    canvas.drawCircle(control1, 8, pointPaint);

    pointPaint.color = Colors.blue;
    canvas.drawCircle(control2, 8, pointPaint);
  }

  @override
  bool shouldRepaint(covariant SBezierPainter oldDelegate) {
    return oldDelegate.c1x != c1x ||
        oldDelegate.c1y != c1y ||
        oldDelegate.c2x != c2x ||
        oldDelegate.c2y != c2y;
  }
}