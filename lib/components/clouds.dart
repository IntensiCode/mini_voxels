import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../core/common.dart';
import '../scripting/game_script_functions.dart';
import '../util/auto_dispose.dart';

class Clouds extends PositionComponent with HasPaint, AutoDispose, GameScriptFunctions {
  FragmentShader? shader;

  set x_off(double it) => shader?.setFloat(2, it);

  set y_off(double it) => shader?.setFloat(3, it);

  set z_off(double it) => shader?.setFloat(4, it);

  set x_rot(double it) => shader?.setFloat(5, it);

  set y_rot(double it) => shader?.setFloat(6, it);

  set z_rot(double it) => shader?.setFloat(7, it);

  @override
  void onLoad() async {
    priority = -20000;

    final program = await FragmentProgram.fromAsset('assets/shaders/clouds.frag');
    shader = program.fragmentShader();
    paint.shader = shader;

    shader?.setFloat(0, rect.width);
    shader?.setFloat(1, rect.height);
    x_off = 0;
    y_off = 0;
    z_off = 0;
    x_rot = 0;
    x_rot = 0;
    y_rot = 0;
    z_rot = 0;
  }

  @override
  render(Canvas canvas) {
    super.render(canvas);
    if (kIsWeb) {
      final paint = Paint();
      paint.shader = shader;
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  var rect = const Rect.fromLTWH(0, -gameHeight / 3, gameWidth, gameHeight);
}
