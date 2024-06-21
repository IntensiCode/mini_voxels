import 'dart:math';

import 'package:flame/components.dart';

final random = Random();

Vector2 randomNormalizedVector2() => Vector2.random(random) - Vector2.random(random);

Vector3 randomNormalizedVector3() => Vector3.random(random) - Vector3.random(random);
