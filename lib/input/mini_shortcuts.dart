import 'package:dart_minilog/dart_minilog.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../util/auto_dispose.dart';

mixin HasAutoDisposeShortcuts on Component, AutoDispose {
  void onKey(String pattern, void Function() callback) =>
      autoDispose('key-$pattern', shortcuts.onKey(pattern, callback));
}

extension ComponentExtension on Component {
  MiniShortcuts get shortcuts {
    Component? probed = this;
    while (probed is! MiniShortcuts) {
      probed = probed?.parent;
      if (probed == null) throw StateError('no shortcuts mixin found');
    }
    return probed;
  }
}

mixin MiniShortcuts<T extends World> on HasKeyboardHandlerComponents<T> {
  late final keyboard = HardwareKeyboard.instance;

  final handlers = <(String, void Function())>[];

  Disposable onKey(String pattern, void Function() callback) {
    logVerbose('onKey $pattern');
    final handler = (pattern, callback);
    handlers.add(handler);
    return Disposable.wrap(() => handlers.remove(handler));
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyRepeatEvent) {
      return KeyEventResult.skipRemainingHandlers;
    }
    if (event is KeyDownEvent && event.character?.isEmpty == false) {
      final modifiers = StringBuffer();
      if (keyboard.isAltPressed) modifiers.write('A-');
      if (keyboard.isControlPressed) modifiers.write('C-');
      if (keyboard.isMetaPressed) modifiers.write('M-');
      if (keyboard.isShiftPressed) modifiers.write('S-');

      final label = event.logicalKey.keyLabel;

      var pattern = event.character ?? label;
      if (pattern == ' ') pattern = 'Space';

      if (label.length > 1) pattern = label;

      final forceMod = keyboard.isAltPressed || keyboard.isControlPressed || keyboard.isMetaPressed;
      if (modifiers.isNotEmpty && label.length > 1 || forceMod) {
        pattern = "<$modifiers$pattern>";
      } else if (pattern.length > 1) {
        pattern = "<$pattern>";
      }

      bool handled = false;
      final cloned = [...handlers];
      for (final it in cloned) {
        if (it.$1 == pattern) {
          it.$2();
          handled = true;
        }
      }
      if (handled) return KeyEventResult.skipRemainingHandlers;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
