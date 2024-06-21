import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_core/signals_core.dart';

final debug = signal(kDebugMode);
bool dev = kDebugMode;

const tps = 240;

const double gameWidth = 320;
const double gameHeight = 240;
final Vector2 gameSize = Vector2(gameWidth, gameHeight);

int gameWidth_ = gameWidth.toInt();
int gameHeight_ = gameHeight.toInt();

const baseSpeed = -500.0;
const minHeight = 0.0;
const maxHeight = 500.0;
const midHeight = (minHeight + maxHeight) / 2 + 100;
const maxStrafe = 1400.0;
const maxLeft = -maxStrafe;
const maxRight = maxStrafe;

const fontScale = gameHeight / 500;
const xCenter = gameWidth / 2;
const yCenter = gameHeight / 2;
const lineHeight = 24 * fontScale;
const debugHeight = 12 * fontScale;

double difficulty = 1;

late Game game;
late Images images;
late CollisionDetection collisions;

// to avoid importing materials elsewhere (which causes clashes sometimes), some color values right here:
const transparent = Colors.transparent;
const black = Colors.black;
const white = Colors.white;
const red = Colors.red;
const orange = Colors.orange;
const yellow = Colors.yellow;
const blue = Colors.blue;

Future<SpriteAnimation> energyBalls16() => game.loadSpriteAnimation(
      'energy_balls_alt.png',
      SpriteAnimationData.sequenced(
        amount: 16,
        amountPerRow: 8,
        stepTime: 0.03,
        textureSize: Vector2(16, 16),
      ),
    );

Paint pixelPaint() => Paint()
  ..isAntiAlias = false
  ..filterQuality = FilterQuality.none;

enum Screen {
  game,
  title,
}

enum EffectKind {
  explosion,
  smoke,
  sparkle,
}

enum ExtraKind {
  energy(1),
  firePower(1),
  missile(0.2),
  ;

  final double probability;

  const ExtraKind(this.probability);
}

mixin Collector {
  void collect(ExtraKind kind);
}

mixin Defender {
  bool onHit([int hits = 1]);
}
