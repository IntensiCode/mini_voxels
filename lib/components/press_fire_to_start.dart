import 'package:flame/components.dart';

import '../core/common.dart';
import '../util/bitmap_text.dart';
import '../util/fonts.dart';

class PressFireToStart extends BitmapText {
  PressFireToStart()
      : super(
          text: 'Press Fire To Start',
          position: Vector2(xCenter, gameHeight - lineHeight),
          anchor: Anchor.center,
          font: fancyFont,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _blinkTm += dt;
    if (_blinkTm > 2) _blinkTm -= 2;
    isVisible = _blinkTm < 1;
  }

  double _blinkTm = 0;
}
