import 'package:flame/components.dart';

import '../core/common.dart';
import '../core/mini_3d.dart';
import '../util/extensions.dart';
import '../util/random.dart';
import 'effects.dart';

class Fragment extends Component3D {
  Fragment(Vector3 origin, Vector3 velocity, Sprite sprite, double dx, double dy, {required super.world}) {
    add(_sprite = SpriteComponent(sprite: sprite)..scale.setAll(2));
    worldPosition.setFrom(origin);
    worldPosition.x += dx * 2;
    worldPosition.y += dy * 2 + 45;
    this.velocity.setFrom(velocity);
    this.velocity.x += random.nextDoublePM(100);
    this.velocity.y += random.nextDoubleLimit(100);
    this.velocity.z -= random.nextDoubleLimit(100) - 30;
  }

  late final SpriteComponent _sprite;

  final velocity = Vector3(0, 0, -500);
  final target = Vector3(0, -1000, 0);

  double smoke = 0.1;

  static const maxLifetime = 3.0;
  double lifetime = maxLifetime;

  @override
  void update(double dt) {
    super.update(dt);

    bool remove = false;
    if (position.x < -20 || position.x > gameWidth + 20) remove = true;
    if (position.y < -20 || position.y > gameHeight + 20) remove = true;
    if (worldPosition.z > world.camera.z - 20) remove = true;
    if (remove) {
      removeFromParent();
      return;
    }

    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
      return;
    } else {
      _sprite.opacity = lifetime.clamp(0, maxLifetime) / maxLifetime;
    }

    if (worldPosition.y <= 0) return;

    angle += random.nextDoubleLimit(0.05);
    worldPosition.add(velocity * dt);
    velocity.lerp(target, 0.001);

    if (smoke <= 0) {
      smoke = 0.1;
      final c3d = Component3D(world: world);
      c3d.worldPosition.setFrom(worldPosition);
      c3d.worldPosition.y -= 45;
      spawnEffect(EffectKind.smoke, c3d, velocity: Vector3(0, 30, 0));
    } else {
      smoke -= dt;
    }

    if (worldPosition.y > 0) return;
    worldPosition.y = 0;
    velocity.setZero();
    target.setZero();
  }
}
