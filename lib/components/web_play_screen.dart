import 'package:flame/components.dart';

import '../../util/auto_dispose.dart';
import '../core/common.dart';
import '../input/mini_shortcuts.dart';
import '../util/bitmap_button.dart';
import '../util/extensions.dart';
import '../util/fonts.dart';

class WebPlayScreen extends AutoDisposeComponent with HasAutoDisposeShortcuts {
  WebPlayScreen(this.nextScreen);

  final Screen nextScreen;

  @override
  void onMount() => onKey('<Space>', () => showScreen(nextScreen));

  @override
  onLoad() async {
    final button = await images.load('button_plain.png');
    const scale = 0.5;
    add(BitmapButton(
      bgNinePatch: button,
      text: 'Start',
      font: menuFont,
      fontScale: scale,
      position: Vector2(gameWidth / 2, gameHeight / 2),
      anchor: Anchor.center,
      onTap: (_) => showScreen(nextScreen),
    ));
  }
}
