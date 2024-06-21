import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';

import 'core/common.dart';
import 'core/messaging.dart';
import 'game_screen.dart';
import 'title_screen.dart';

class GameWorld extends World {
  int level = 1;

  @override
  void onLoad() {
    messaging.listen<ShowScreen>((it) => _showScreen(it.screen));
  }

  void _showScreen(Screen it) {
    logInfo(it);
    removeAll(children);
    switch (it) {
      case Screen.game:
        add(GameScreen());
      case Screen.title:
        level = 1;
        add(TitleScreen());
    }
  }
}
