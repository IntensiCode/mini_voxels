import 'dart:ui';

import 'package:flame/cache.dart';

import '../core/common.dart';
import 'bitmap_font.dart';

const textColor = Color(0xFFffcc80);
const successColor = Color(0xFF20ff10);
const errorColor = Color(0xFFff2010);

late BitmapFont fancyFont;
late BitmapFont menuFont;
late BitmapFont textFont;

loadFonts(AssetsCache assets) async {
  fancyFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/fancyfont.png',
    charWidth: 12,
    charHeight: 10,
  );
  menuFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/menufont.png',
    charWidth: 24,
    charHeight: 24,
  );
  textFont = await BitmapFont.loadDst(
    images,
    assets,
    'fonts/textfont.png',
    charWidth: 12,
    charHeight: 12,
  );
}
