// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'components/clouds.dart';
import 'components/racer.dart';
import 'components/voxel_scape.dart';
import 'core/common.dart';
import 'input/game_keys.dart';
import 'input/mini_shortcuts.dart';
import 'scripting/game_script.dart';

class TitleScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, GameKeys {
  late final Clouds _clouds;
  late final VoxelScape _voxelScape;
  late final Racer _racer;

  @override
  onLoad() async {
    add(RectangleComponent(
      size: Vector2(gameWidth, gameHeight),
      paint: Paint()..color = const Color(0xFFb8b8c0),
      priority: -30000,
    ));
    add(_clouds = Clouds());
    // add(_voxelScape = VoxelScape());
    add(_racer = Racer());
  }

  double time = 0;

  @override
  void update(double dt) {
    super.update(dt);

    time += dt;

    // _clouds.x_off = -sin(time) * 200;
    _clouds.y_off = 20 + sin(pi / 2 + time) * 20;
    // _clouds.y_rot = -sin(time) / 4;
    _clouds.x_rot = 0.01;
    _clouds.z_rot = sin(pi / 2 + time * 2) / 6;
    _voxelScape.player_angle = sin(time) / 2;
    _voxelScape.player_x = sin(time) * 256 + 512;
    _voxelScape.player_z = sin(time * 1.37) * 256 + 512;
    _voxelScape.player_tilt = sin(pi / 2 + time * 2) / 2;
    // _voxelScape.player_pitch = -sin(pi / 2 + time) / 2 * 10;
    _voxelScape.player_height = 200 + sin(pi / 2 + time) * 100;
    _racer.rotation = -_voxelScape.player_angle - pi;

    if (left) _voxelScape.player_x -= 100 * dt;
    if (right) _voxelScape.player_x += 100 * dt;
    if (up && alt) _voxelScape.player_height -= 100 * dt;
    if (down && alt) _voxelScape.player_height += 100 * dt;
    if (up) _voxelScape.player_z -= 100 * dt;
    if (down) _voxelScape.player_z += 100 * dt;
  }
}
