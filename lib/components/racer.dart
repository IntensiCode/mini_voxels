// ignore_for_file: non_constant_identifier_names

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import '../core/common.dart';
import '../input/mini_shortcuts.dart';
import '../scripting/game_script_functions.dart';
import '../util/auto_dispose.dart';

class Racer extends PositionComponent with AutoDispose, HasAutoDisposeShortcuts, GameScriptFunctions {
  final _racerLayers = <SpriteComponent>[];

  set rotation(double radians) {
    for (final it in _racerLayers) {
      it.angle = radians;
    }
    scale.x = 2;
    scale.y = 1;
  }

  @override
  onLoad() async {
    final racer = await sheetI('racer.png', 1, 16);
    final sprites = List.generate(
      racer.rows,
      (it) => SpriteComponent(
        size: Vector2.all(32),
        sprite: racer.getSprite(racer.rows - it - 1, 0),
        anchor: Anchor.center,
      )
        ..tint(Color.fromARGB(200 - it * 14, 0, 0, 0))
        ..position.y -= it * 1.5,
      growable: false,
    );
    for (final it in sprites) {
      _racerLayers.add(it);
      add(it);
    }
    position.x = xCenter;
    position.y = gameHeight * 2 / 3;
  }
}
