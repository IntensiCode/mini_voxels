// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/cupertino.dart';

import 'components/mini_map.dart';
import 'components/voxel_scape.dart';
import 'core/common.dart';
import 'input/game_keys.dart';
import 'input/mini_shortcuts.dart';
import 'scripting/game_script.dart';

class GameScreen extends GameScriptComponent with HasAutoDisposeShortcuts, KeyboardHandler, GameKeys {
  // late final Clouds _clouds;
  late final VoxelScape _voxelScape;

  // late final Racer _racer;

  late final Uint8List _height_map;
  late final MiniMap _mini_map;

  @override
  onLoad() async {
    final u_color_map = await image('C28W.png');
    final u_height_map = await image('D28.png');
    _height_map = await u_height_map.pixelsInUint8();

    add(RectangleComponent(
      size: Vector2(gameWidth, gameHeight),
      paint: Paint()..color = const Color(0xFFb8b8c0),
      priority: -30000,
    ));

    // add(_clouds = Clouds());

    add(_voxelScape = VoxelScape(
      u_color_map: u_color_map,
      u_height_map: u_height_map,
      height_map: _height_map,
    ));

    add(_mini_map = MiniMap(
      image: u_color_map,
      clip_size: 48,
      position: Vector2(gameWidth, 0),
      anchor: Anchor.topRight,
    ));
    // add(_racer = Racer());
  }

  double height_at(double x, double y) {
    final sx = (x.round()) % _voxelScape.map_size;
    final sy = (y.round()) % _voxelScape.map_size;
    return _height_map[sx * 4 + sy * _voxelScape.map_size * 4].toDouble();
  }

  double speed = 0.0;
  double acceleration = 0.0;
  double steering = 0.0;
  double direction = 0.0;
  double pitch = 50.0;

  final position = Vector3(512, 25, 512);

  final acceleration_factor = 2.0;
  final max_acceleration = 4.0;
  final steer_factor = 6.0;
  final max_steering = 4.0;
  final max_speed = 1.0;
  final air_friction = 5.0;

  final full_circle = pi * 2;

  double target_pitch = 50;
  double target_height = 10;

  @override
  void update(double dt) {
    super.update(dt);

    _steering(dt);
    _voxelScape.player_angle = direction;
    _voxelScape.player_tilt = steering;

    _accelerating(dt);
    position.x = (position.x + cos(direction) * speed) % _voxelScape.map_size;
    position.z = (position.z + sin(direction) * speed) % _voxelScape.map_size;
    _voxelScape.player_x = position.x;
    _voxelScape.player_z = position.z;

    _hovering(dt);
    _voxelScape.player_pitch = pitch;
    _voxelScape.player_height = position.y;

    _mini_map.reposition(position.x, position.z, direction);
  }

  void _steering(double dt) {
    if (left) {
      if (steering > 0) steering -= steer_factor * steering * dt;
      steering -= steer_factor * dt;
    } else if (right) {
      if (steering < 0) steering -= steer_factor * steering * dt;
      steering += steer_factor * dt;
    } else {
      steering -= steer_factor * steering * dt;
    }
    if (steering.abs() > max_steering) {
      steering = max_steering * steering.sign;
    }

    direction = (direction + steering * dt) % full_circle;
  }

  void _accelerating(double dt) {
    bool applyFriction = true;
    if (down) {
      if (speed <= 0) applyFriction = false;
      if (acceleration > 0) acceleration -= acceleration_factor * acceleration * dt;
      acceleration -= acceleration_factor * dt;
    } else if (up) {
      applyFriction = false;
      if (speed < 0) speed = 0;
      if (acceleration < 0) acceleration = 0;
      acceleration += acceleration_factor * dt;
    } else {
      acceleration -= acceleration_factor * acceleration * dt;
    }
    if (acceleration.abs() > max_acceleration) {
      acceleration = max_acceleration * acceleration.sign;
    }

    if (applyFriction) speed -= speed * air_friction * dt;

    speed += acceleration * dt;

    if (speed > max_speed) {
      speed = max_speed;
    } else if (speed < -max_speed / 10) {
      speed = -max_speed / 10;
    }
  }

  void _hovering(double dt) {
    const o1 = 50;
    const o2 = 25;
    const o3 = 5;
    const oo = 10;
    final x1 = (position.x + cos(direction) * o1);
    final z1 = (position.z + sin(direction) * o1);
    final x2 = (position.x + cos(direction) * o2);
    final z2 = (position.z + sin(direction) * o2);
    final x3 = (position.x + cos(direction) * o3);
    final z3 = (position.z + sin(direction) * o3);
    final h1 = height_at(x1, z1);
    final h2 = height_at(x2, z2);
    final h3 = height_at(x3, z3);

    final hx = max(h1, max(h2, h3));
    target_height = hx + oo;

    target_pitch = (100 - acceleration * 25).clamp(50, 110);
    if (h1 > h2) target_pitch += 25;
    if (target_height < position.y ) target_pitch -= 25;
    pitch += (target_pitch - pitch) * 8 * dt;

    final adapt_factor = target_height > position.y ? 8 : 4;
    position.y += (target_height - position.y) * adapt_factor * dt;
    if (position.y < h2) {
      speed -= speed * 2 * dt;
      acceleration = 0;
    }
    if (position.y < h3) {
      speed = 0;
      acceleration = 0;
      steering = 0;
    }
  }
}
