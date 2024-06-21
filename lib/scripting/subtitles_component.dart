import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:list_operators/list_operators.dart';

import '../core/common.dart';
import '../scripting/game_script_functions.dart';
import '../util/auto_dispose.dart';
import '../util/bitmap_font.dart';
import '../util/bitmap_text.dart';
import '../util/extensions.dart';
import '../util/fonts.dart';

class SubtitlesComponent extends PositionComponent with HasPaint, AutoDispose, GameScriptFunctions {
  static const _fontScale = 0.5;

  final String _text;
  double? autoClearSeconds;
  String? portrait;

  SubtitlesComponent(this._text, this.autoClearSeconds, this.portrait);

  SpriteComponent? _portrait;

  @override
  void onLoad() async {
    if (autoClearSeconds != null) {
      add(TimerComponent(period: autoClearSeconds!, onTick: _fadeOut));
      add(RemoveEffect(delay: autoClearSeconds! + 1));
    }

    position.x = 0;
    position.y = gameHeight - 8;
    anchor = Anchor.bottomLeft;

    final lineHeight = textFont.lineHeight(_fontScale) * 4 / 3;
    final lines = textFont.reflow(_text, 176, scale: _fontScale);
    final w = lines.map((it) => textFont.lineWidth(it)).max();
    final h = lines.length * lineHeight;
    size.x = gameWidth;
    size.y = h + 16 - (lineHeight - textFont.lineHeight(_fontScale) + 1);

    if (portrait != null) {
      _portrait = await loadSprite(portrait!);
      _portrait?.anchor = Anchor.bottomLeft;
      _portrait?.position.x = 0;
      _portrait?.position.y = size.y + 8;
      add(_portrait!);
    }

    final pos = Vector2.zero();
    for (final line in lines) {
      pos.x = (size.x - textFont.lineWidth(line)) / 2;
      pos.y += lineHeight;
      final text = BitmapText(
        text: line,
        position: pos,
        font: textFont,
        scale: _fontScale,
      );
      text.fadeInDeep();
      _lines.add(text);
      add(text);
    }

    final bgWidth = w + 16.0;
    _bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((gameWidth - bgWidth) / 2, 0.0, bgWidth, height),
      const Radius.circular(8),
    );

    paint.color = const Color(0x80000000);
  }

  void _fadeOut() {
    // _portrait?.fadeOutDeep();
    // _lines.forEach((it) => it.fadeOutDeep());
    fadeOutDeep();
  }

  final _lines = <BitmapText>[];

  late final RRect _bgRect;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_bgRect, paint);
  }
}
