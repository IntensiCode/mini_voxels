import 'package:flame/components.dart';

class Delayed extends Component {
  Delayed(this.delaySeconds, this.target);

  double delaySeconds;
  final Component target;

  @override
  void update(double dt) {
    super.update(dt);
    if (delaySeconds > 0) {
      delaySeconds -= dt;
    } else {
      parent?.add(target);
      removeFromParent();
    }
  }
}
