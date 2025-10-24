import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  AppIcons._();

  static const String _fontFamily = 'icomoon';

  static const IconData orders = IconData(0xe900, fontFamily: _fontFamily);
  static const IconData settings = IconData(0xe901, fontFamily: _fontFamily);
  static const IconData refresh = IconData(0xe902, fontFamily: _fontFamily);
  static const IconData sales = IconData(0xe903, fontFamily: _fontFamily);
  static const IconData user = IconData(0xe904, fontFamily: _fontFamily);
  static const IconData close = IconData(0xe905, fontFamily: _fontFamily);
  static const IconData back = IconData(0xe906, fontFamily: _fontFamily);
  static const IconData menu = IconData(0xe907, fontFamily: _fontFamily);
  static const IconData logOut = IconData(0xe908, fontFamily: _fontFamily);

  static Widget get item => SvgPicture.asset('assets/icons/shopping_basket.svg');
}
