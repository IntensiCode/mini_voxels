import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class BlinkEffect extends Effect {
  BlinkEffect({this.duration = 1, this.on = 0.35, this.off = 0.15}) : super(LinearEffectController(duration));

  final double duration;
  final double on;
  final double off;

  @override
  void apply(double progress) {
    final visible = progress * duration % (on + off);
    (parent as HasVisibility).isVisible = visible <= on;
  }
}
