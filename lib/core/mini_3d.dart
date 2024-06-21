import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'common.dart';

final world = World3D();

class World3D {
  final camera = Vector3(0, 50, 50);

  double d = 25;

  double project(Vector3 worldPosition, Vector2 screenPosition) {
    final x = worldPosition.x - camera.x;
    final y = camera.y - worldPosition.y;
    final z = camera.z - worldPosition.z;
    if (z < 0) return 0;

    screenPosition.x = gameWidth / 2 + x * d / z;
    screenPosition.y = gameHeight / 2 + y * d / z;
    return z;
  }
}

class Component3D extends PositionComponent with HasVisibility {
  Component3D({
    required this.world,
    Vector3? worldPosition,
    Anchor anchor = Anchor.center,
  }) : worldPosition = worldPosition ?? Vector3.zero() {
    this.anchor = anchor;
    // add(CircleComponent(radius: 10, paint: Paint()..color = const Color(0x80FF0000), anchor: Anchor.center));
    size.setAll(20);
  }

  double distance3D(Component3D other) => worldPosition.distanceTo(other.worldPosition);

  double distanceSquared3D(Component3D other) => worldPosition.distanceToSquared(other.worldPosition);

  final World3D world;
  final Vector3 worldPosition;

  @override
  void update(double dt) {
    super.update(dt);
    final depth = world.project(worldPosition, position);
    isVisible = depth > 0;
    scale.setAll(5 / depth);
    priority = -depth.toInt();
    if (this case OpacityProvider it) {
      isVisible = worldPosition.z - world.camera.z < -10;
      if (worldPosition.z - world.camera.z > -20) {
        it.opacity = 0.1;
      } else {
        it.opacity = 1;
      }
    }
  }
}
