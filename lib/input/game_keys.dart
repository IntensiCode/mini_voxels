import 'package:flame/components.dart';
import 'package:flutter/services.dart';

enum GameKey {
  left,
  right,
  up,
  down,
  primaryFire,
  secondaryFire,
  inventory,
  useOrExecute,
}

mixin GameKeys on KeyboardHandler {
  // just guessing for now what i may need... doesn't matter.. just to have something for now..

  late final keyboard = HardwareKeyboard.instance;

  static final leftKeys = ['Arrow Left', 'A'];
  static final rightKeys = ['Arrow Right', 'D'];
  static final downKeys = ['Arrow Down', 'S'];
  static final upKeys = ['Arrow Up', 'W'];
  static final primaryFireKeys = ['Control', 'Space', 'J'];
  static final secondaryFireKeys = ['Shift', 'K'];
  static final inventoryKeys = ['Tab', 'Home', 'I'];
  static final useOrExecuteKeys = ['End', 'U'];

  static final mapping = {
    GameKey.left: leftKeys,
    GameKey.right: rightKeys,
    GameKey.up: upKeys,
    GameKey.down: downKeys,
    GameKey.primaryFire: primaryFireKeys,
    GameKey.secondaryFire: secondaryFireKeys,
    GameKey.inventory: inventoryKeys,
    GameKey.useOrExecute: useOrExecuteKeys,
  };

  // held states

  bool get alt => keyboard.isAltPressed;

  bool get ctrl => keyboard.isControlPressed;

  bool get meta => keyboard.isMetaPressed;

  bool get shift => keyboard.isShiftPressed;

  final held = <GameKey, bool>{}..addEntries(GameKey.values.map((it) => MapEntry(it, false)));

  bool get left => held[GameKey.left] == true;

  bool get right => held[GameKey.right] == true;

  bool get up => held[GameKey.up] == true;

  bool get down => held[GameKey.down] == true;

  bool get primaryFire => held[GameKey.primaryFire] == true;

  bool get secondaryFire => held[GameKey.secondaryFire] == true;

  bool isHeld(GameKey key) => held[key] == true;

  String label(LogicalKeyboardKey key) {
    final s = key.synonyms.singleOrNull;
    if (s != null) return label(s);

    final check = key.keyLabel;
    if (check == ' ') return 'Space';
    return check;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyRepeatEvent) {
      return true; // super.onKeyEvent(event, keysPressed);
    }
    if (event case KeyDownEvent it) {
      final check = label(it.logicalKey);
      for (final entry in mapping.entries) {
        final key = entry.key;
        final keys = entry.value;
        if (keys.contains(check)) {
          held[key] = true;
        }
      }
    }
    if (event case KeyUpEvent it) {
      final check = label(it.logicalKey);
      for (final entry in mapping.entries) {
        final key = entry.key;
        final keys = entry.value;
        if (keys.contains(check)) {
          held[key] = false;
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
