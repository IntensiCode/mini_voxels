// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart' hide Image;

class MiniMap extends ClipComponent {
  MiniMap({
    required this.image,
    required this.clip_size,
    super.position,
    super.anchor,
  }) : super.rectangle(size: Vector2.all(clip_size)) {
    final parallax = Parallax(
      [ParallaxLayer(ParallaxImage(image, repeat: ImageRepeat.repeat))],
      size: Vector2.all(clip_size * 2),
    );

    _parallax = ParallaxComponent(
      parallax: parallax,
      position: Vector2(clip_size / 2, clip_size / 2),
      size: Vector2.all(clip_size * 2),
      scale: Vector2.all(-1),
      anchor: Anchor.center,
    );

    add(_parallax);
  }

  final Image image;
  final double clip_size;
  late final ParallaxComponent _parallax;

  reposition(double x, double y, double direction) {
    _parallax.angle = pi / 2 - direction;
    _parallax.parallax?.layers[0].currentOffset().x = x / 1024 + 0.5;
    _parallax.parallax?.layers[0].currentOffset().y = y / 1024 + 0.5;
  }
}
