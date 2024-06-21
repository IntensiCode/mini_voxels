// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../core/common.dart';
import '../input/mini_shortcuts.dart';
import '../scripting/game_script.dart';
import '../util/uniforms.dart';

enum _Id {
  screen_x,
  screen_y,
  screen_width,
  screen_height,
  map_size,
  map_scale,
  player_pitch,
  player_tilt,
  player_angle,
  player_height,
  player_x,
  player_y,
}

class VoxelScape extends GameScriptComponent with HasAutoDisposeShortcuts {
  VoxelScape({
    required this.u_color_map,
    required this.u_height_map,
    required this.height_map,
    this.map_size = 1024,
    this.map_scale = 8,
  });

  final int map_size;
  final double map_scale;

  double player_angle = 0;
  double player_x = 256;
  double player_z = 256;
  double player_height = 128;
  double player_pitch = 50;
  double player_tilt = 0;

  late final FragmentProgram _program;
  FragmentShader? _shader;
  late Uniforms<_Id> _uniforms;

  final Image u_color_map;
  final Image u_height_map;
  Uint8List? height_map;

  final rect = const Rect.fromLTWH(0, 0, gameWidth, gameHeight);
  final offset = const Offset(0, 0);

  @override
  onLoad() async {
    priority = -10000;

    _program = await FragmentProgram.fromAsset('assets/shaders/voxel_scape.frag');
  }

  bool _shaderInitialized = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (kIsWeb || !_shaderInitialized) {
      _shader?.dispose();
      _createNewShader();
      _shaderInitialized = true;
    }

    _uniforms[_Id.player_pitch] = player_pitch;
    _uniforms[_Id.player_tilt] = player_tilt;
    _uniforms[_Id.player_angle] = player_angle;
    _uniforms[_Id.player_height] = player_height;
    _uniforms[_Id.player_x] = player_x;
    _uniforms[_Id.player_y] = player_z;
  }

  void _createNewShader() {
    final it = _shader = _program.fragmentShader();

    _uniforms = Uniforms(it, _Id.values);

    it.setImageSampler(0, u_color_map);
    it.setImageSampler(1, u_height_map);

    _uniforms[_Id.screen_x] = rect.left;
    _uniforms[_Id.screen_y] = rect.top;
    _uniforms[_Id.screen_width] = rect.width;
    _uniforms[_Id.screen_height] = rect.height;
    _uniforms[_Id.map_size] = map_size.toDouble();
    _uniforms[_Id.map_scale] = map_scale;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final recorder = PictureRecorder();
    Canvas(recorder).drawRect(rect, Paint()..shader = _shader);

    final picture = recorder.endRecording();
    final image = picture.toImageSync(rect.width.toInt(), rect.height.toInt());
    canvas.drawImage(image, offset, paint);
    image.dispose();
    picture.dispose();
  }

  final paint = pixelPaint();
}
