import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generate app icon from logo svg',
    () async {
      const size = 1024;
      const logoFraction = 0.7;
      final logoSize = size * logoFraction;
      final offset = (size - logoSize) / 2;

      final svgString = await File('assets/images/logo.svg').readAsString();
      final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      final scale = logoSize / pictureInfo.size.width;
      canvas.save();
      canvas.translate(offset, offset);
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();

      final picture = recorder.endRecording();
      final image = await picture.toImage(size, size);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      await File('assets/images/app_icon.png').writeAsBytes(
        byteData!.buffer.asUint8List(),
      );
    },
    skip: Platform.environment['GENERATE_APP_ICON'] != 'true'
        ? 'Set GENERATE_APP_ICON=true to generate assets/images/app_icon.png'
        : false,
  );
}
