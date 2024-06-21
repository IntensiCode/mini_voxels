import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:mini_voxels/game_screen.dart';

import 'core/common.dart';
import 'core/messaging.dart';
import 'core/soundboard.dart';
import 'game_world.dart';
import 'input/mini_shortcuts.dart';
import 'util/extensions.dart';
import 'util/fonts.dart';
import 'util/performance.dart';

class MiniVoxels extends FlameGame<GameWorld>
    with HasKeyboardHandlerComponents, Messaging, MiniShortcuts, HasPerformanceTracker {
  //
  final _ticker = Ticker(ticks: tps);

  void _showInitialScreen() {
    // if (kIsWeb) {
    //   world.add(WebPlayScreen(Screen.title));
    // } else {
    world.add(GameScreen());
    // }
  }

  MiniVoxels() : super(world: GameWorld()) {
    game = this;
    images = this.images;

    if (kIsWeb) logAnsi = false;
  }

  @override
  onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera = CameraComponent.withFixedResolution(
      width: gameWidth,
      height: gameHeight,
      hudComponents: [_ticks(), _frames()],
    );
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  _ticks() => RenderTps(
        scale: Vector2(0.25, 0.25),
        position: Vector2(0, 0),
        anchor: Anchor.topLeft,
      );

  _frames() => RenderFps(
        scale: Vector2(0.25, 0.25),
        position: Vector2(0, 8),
        anchor: Anchor.topLeft,
      );

  @override
  onLoad() async {
    super.onLoad();

    await soundboard.preload();
    await loadFonts(assets);

    _showInitialScreen();

    onKey('m', () => soundboard.toggleMute());
    onKey('t', () => showScreen(Screen.title));

    if (dev) {
      onKey('<C-d>', () => _toggleDebug());
      onKey('<C-m>', () => soundboard.toggleMute());
      onKey('<C-0>', () => showScreen(Screen.title));
      onKey('<C-->', () => _slowDown());
      onKey('<C-=>', () => _speedUp());
      onKey('<C-S-+>', () => _speedUp());
    }
  }

  _toggleDebug() {
    debug.value = !debug.value;
    return KeyEventResult.handled;
  }

  _slowDown() {
    if (_timeScale > 0.125) _timeScale /= 2;
  }

  _speedUp() {
    if (_timeScale < 4.0) _timeScale *= 2;
  }

  @override
  update(double dt) => _ticker.generateTicksFor(dt * _timeScale, (it) => super.update(it));

  double _timeScale = 1;
}
