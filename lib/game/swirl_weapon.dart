// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
//
// import '../core/messaging.dart';
// import '../core/mini_3d.dart';
// import '../core/soundboard.dart';
// import '../scripting/game_script_functions.dart';
// import '../util/auto_dispose.dart';
// import 'damage_target.dart';
// import 'stage1/rocks.dart';
//
// class SwirlWeapon extends Component with AutoDispose, GameScriptFunctions {
//   SwirlWeapon(this.captain, this.shouldFire, this.world, this.world3d);
//
//   final Component3D captain;
//   final bool Function() shouldFire;
//   final Component world;
//   final World3D world3d;
//
//   late final SpriteAnimation anim;
//
//   double firePower = 1;
//
//   static const maxFirePower = 5.0;
//
//   void increaseFirePower() => firePower = (firePower + 0.5).clamp(1.0, maxFirePower);
//
//   @override
//   void onMount() {
//     super.onMount();
//     onMessage<IncreasedFirePower>((_) => increaseFirePower());
//   }
//
//   @override
//   onLoad() async {
//     anim = await loadAnimWH('swirl.png', 18, 18);
//   }
//
//   @override
//   update(double dt) {
//     super.update(dt);
//
//     if (_coolDown > 0) _coolDown -= dt;
//     if (_coolDown <= 0 && shouldFire()) {
//       final it = _pool.isEmpty ? SwirlProjectile(_recycle, captain, world: world3d) : _pool.removeLast();
//       it.visual.animation = anim;
//       it.reset(captain.worldPosition, firePower);
//       world.add(it);
//       soundboard.play(Sound.shot);
//       _coolDown = 0.4 - (firePower / maxFirePower) * 0.3;
//     }
//   }
//
//   void _recycle(SwirlProjectile it) {
//     it.removeFromParent();
//     _pool.add(it);
//   }
//
//   final _pool = <SwirlProjectile>[];
//
//   double _coolDown = 0;
// }
//
// class SwirlProjectile extends Component3D {
//   SwirlProjectile(this._recycle, this.origin, {required super.world}) {
//     add(RectangleHitbox(position: Vector2.zero(), size: Vector2.all(10), anchor: Anchor.center));
//     add(visual = SpriteAnimationComponent(anchor: Anchor.center)..scale.setAll(10));
//   }
//
//   final Component3D origin;
//
//   final void Function(SwirlProjectile) _recycle;
//
//   late final SpriteAnimationComponent visual;
//
//   void reset(Vector3 position, double firePower) {
//     _firePower = firePower;
//     worldPosition.setFrom(position);
//     worldPosition.x -= 5;
//     worldPosition.y += 55;
//     worldPosition.z -= 10;
//     _lifetime = 0;
//     visual.scale.setAll(10 + firePower);
//   }
//
//   late double _firePower;
//
//   double _lifetime = 0;
//
//   double speed = 500;
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     worldPosition.z -= speed * dt;
//     if (speed < 1000) speed += 1000 * dt;
//     _lifetime += dt;
//     if (_lifetime > 3) _recycle(this);
//
//     final check = parent?.children.whereType<DamageTarget>();
//     if (check == null) return;
//
//     for (final it in check) {
//       if (it == origin) continue;
//       if (it is Rock) {
//         if ((it.worldPosition.x - worldPosition.x).abs() > 200) continue;
//         if ((it.worldPosition.z - worldPosition.z).abs() > 55) continue;
//         // if ((it.worldPosition.y + 75 - worldPosition.y).abs() > 50) continue;
//       } else {
//         if ((it.worldPosition.x - worldPosition.x).abs() > 55) continue;
//         if ((it.worldPosition.z - worldPosition.z).abs() > 15) continue;
//         if ((it.worldPosition.y + 75 - worldPosition.y).abs() > 50) continue;
//       }
//       it.applyDamage(plasma: _firePower);
//       _recycle(this);
//       break;
//     }
//   }
// }
