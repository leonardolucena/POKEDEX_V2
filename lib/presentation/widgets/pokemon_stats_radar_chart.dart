import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pokedex/data/models/pokemon_stats.dart';

abstract final class PokemonStatsRadarChartColors {
  static const grid = Color(0x55FFFFFF);
  static const axis = Color(0x38FFFFFF);
  static const outline = Color(0xD9FFFFFF);
  static const fill = Color(0x8C5BA4D9);
  static const fillStroke = Color(0xB376B8E8);
  static const label = Color(0xFFF0C84B);
  static const value = Color(0xFFF7F7F7);
}

class PokemonStatsRadarChart extends StatelessWidget {
  const PokemonStatsRadarChart({
    super.key,
    required this.stats,
    this.size = 255,
    this.maxValue = 255,
  });

  final PokemonStats stats;
  final double size;
  final double maxValue;

  static const _verticalInset = 1.0;

  @override
  Widget build(BuildContext context) {
    final values = stats.chartValues;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : size;
        final chartSize = math.min(size, maxWidth);
        final chartRadius = chartSize * 0.27;
        final labelRadius = chartRadius + chartSize * 0.07;
        final chartCenter = Offset(chartSize / 2, _verticalInset + chartSize / 2);
        final totalHeight = chartSize + _verticalInset * 2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: chartSize,
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: _verticalInset,
                    left: 0,
                    width: chartSize,
                    height: chartSize,
                    child: CustomPaint(
                      size: Size(chartSize, chartSize),
                      painter: _PokemonStatsRadarPainter(
                        values: values,
                        maxValue: maxValue,
                        chartRadius: chartRadius,
                      ),
                    ),
                  ),
                  for (var index = 0;
                      index < PokemonStats.chartLabels.length;
                      index++)
                    _StatLabel(
                      statIndex: index,
                      label: PokemonStats.chartLabels[index],
                      value: values[index],
                      angle: _vertexAngle(index),
                      radius: labelRadius,
                      chartCenter: chartCenter,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total ${stats.total}',
              style: const TextStyle(
                color: PokemonStatsRadarChartColors.label,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }

  static double _vertexAngle(int index) {
    return -math.pi / 2 + (2 * math.pi / 6) * index;
  }
}

class _StatLabelConfig {
  const _StatLabelConfig({
    this.radiusFactor = 1,
    this.width = 56,
    this.height = 34,
    this.labelFontSize = 9,
    this.maxLines = 1,
  });

  final double radiusFactor;
  final double width;
  final double height;
  final double labelFontSize;
  final int maxLines;
}

const _statLabelConfigs = [
  _StatLabelConfig(),
  _StatLabelConfig(width: 60),
  _StatLabelConfig(width: 60),
  _StatLabelConfig(width: 78),
  _StatLabelConfig(radiusFactor: 1.2, width: 74, height: 40, labelFontSize: 8, maxLines: 2),
  _StatLabelConfig(radiusFactor: 1.2, width: 74, height: 40, labelFontSize: 8, maxLines: 2),
];

class _StatLabel extends StatelessWidget {
  const _StatLabel({
    required this.statIndex,
    required this.label,
    required this.value,
    required this.angle,
    required this.radius,
    required this.chartCenter,
  });

  final int statIndex;
  final String label;
  final int value;
  final double angle;
  final double radius;
  final Offset chartCenter;

  @override
  Widget build(BuildContext context) {
    final config = _statLabelConfigs[statIndex];
    final effectiveRadius = radius * config.radiusFactor;
    final position = Offset(
      chartCenter.dx + effectiveRadius * math.cos(angle),
      chartCenter.dy + effectiveRadius * math.sin(angle),
    );

    return Positioned(
      left: position.dx - config.width / 2,
      top: position.dy - config.height / 2,
      width: config.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.maxLines == 1)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PokemonStatsRadarChartColors.label,
                  fontSize: config.labelFontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            )
          else
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: config.maxLines,
              style: TextStyle(
                color: PokemonStatsRadarChartColors.label,
                fontSize: config.labelFontSize,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PokemonStatsRadarChartColors.value,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonStatsRadarPainter extends CustomPainter {
  const _PokemonStatsRadarPainter({
    required this.values,
    required this.maxValue,
    required this.chartRadius,
  });

  final List<int> values;
  final double maxValue;
  final double chartRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final level in [0.33, 0.66, 1.0]) {
      _drawHexagon(
        canvas,
        center,
        chartRadius * level,
        Paint()
          ..color = PokemonStatsRadarChartColors.grid
          ..style = PaintingStyle.stroke
          ..strokeWidth = level == 1.0 ? 1.5 : 1,
      );
    }

    for (var index = 0; index < 6; index++) {
      final end = _vertex(center, chartRadius, index);
      canvas.drawLine(
        center,
        end,
        Paint()
          ..color = PokemonStatsRadarChartColors.axis
          ..strokeWidth = 1,
      );
    }

    final dataPath = Path();
    for (var index = 0; index < values.length; index++) {
      final normalized = (values[index] / maxValue).clamp(0.0, 1.0);
      final point = _vertex(center, chartRadius * normalized, index);
      if (index == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()..color = PokemonStatsRadarChartColors.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = PokemonStatsRadarChartColors.fillStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    for (var index = 0; index < 6; index++) {
      final corner = _vertex(center, chartRadius, index);
      canvas.drawCircle(
        corner,
        2.4,
        Paint()..color = PokemonStatsRadarChartColors.outline,
      );
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var index = 0; index < 6; index++) {
      final point = _vertex(center, radius, index);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  Offset _vertex(Offset center, double radius, int index) {
    final angle = -math.pi / 2 + (2 * math.pi / 6) * index;
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant _PokemonStatsRadarPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.chartRadius != chartRadius;
  }
}
