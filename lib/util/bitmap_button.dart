import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/services.dart';

import 'bitmap_font.dart';
import 'fonts.dart';
import 'nine_patch_image.dart';

class BitmapButton extends PositionComponent with HasPaint, TapCallbacks, KeyboardHandler {
  //
  final NinePatchImage? background;
  final String text;
  final BitmapFont font;
  final double fontScale;
  final int cornerSize;
  final Function(BitmapButton) onTap;
  final List<String> shortcuts;

  BitmapButton({
    Image? bgNinePatch,
    required this.text,
    this.cornerSize = 8,
    Vector2? position,
    Vector2? size,
    BitmapFont? font,
    Anchor? anchor,
    this.shortcuts = const [],
    this.fontScale = 1,
    Color? tint,
    required this.onTap,
  })  : font = font ?? fancyFont,
        background = bgNinePatch != null ? NinePatchImage(bgNinePatch, cornerSize: cornerSize) : null {
    if (position != null) this.position.setFrom(position);
    if (tint != null) {
      this.tint(tint);
    }
    if (size == null) {
      this.font.scale = fontScale;
      this.size = this.font.textSize(text);
      this.size.x = (this.size.x ~/ cornerSize * cornerSize).toDouble() + cornerSize * 2;
      this.size.y = (this.size.y ~/ cornerSize * cornerSize).toDouble() + cornerSize * 2;
    } else {
      this.size = size;
    }
    final a = anchor ?? Anchor.center;
    final x = a.x * this.size.x;
    final y = a.y * this.size.y;
    this.position.x -= x;
    this.position.y -= y;
  }

  @override
  render(Canvas canvas) {
    background?.draw(canvas, 0, 0, size.x, size.y, paint);

    font.scale = fontScale;
    font.paint.color = paint.color;
    font.paint.colorFilter = paint.colorFilter;
    font.paint.filterQuality = FilterQuality.none;
    font.paint.isAntiAlias = false;
    font.paint.blendMode = paint.blendMode;
    font.scale = fontScale;

    final xOff = (size.x - font.lineWidth(text)) / 2;
    final yOff = (size.y - font.lineHeight(fontScale)) / 2;
    font.drawString(canvas, xOff, yOff, text);
  }

  @override
  void onTapUp(TapUpEvent event) => onTap(this);

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyRepeatEvent) return true;
    if (event is! KeyDownEvent) return true;
    if (event case KeyDownEvent it) {
      if (shortcuts.contains(it.logicalKey.keyLabel)) {
        onTap(this);
        return true;
      }
    }
    return false;
  }
}
