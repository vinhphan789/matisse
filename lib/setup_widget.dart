import 'package:flutter/material.dart';

class SetupTextWidget extends StatelessWidget {
  final String titleLabel;
  final Color textColor;
  final TextAlign textAlign;
  final double fontSize;
  final int maxLine;
  final AppFont font;

  const SetupTextWidget({
    super.key,
    required this.titleLabel,
    required this.font,
    this.textColor = Colors.black,
    this.textAlign = TextAlign.left,
    this.fontSize = 14,
    this.maxLine = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      titleLabel,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: font.family,
        fontWeight: font.weight,
        fontStyle: font.style,
        fontSize: fontSize,
        color: textColor,
      ),
    );
  }
}



class AppFont {
  final String family;
  final FontWeight weight;
  final FontStyle style;

  const AppFont({
    required this.family,
    this.weight = FontWeight.w400,
    this.style = FontStyle.normal,
  });
}

class FontApp {
  FontApp._();

  static const String _family = 'RobotoCustom';

  static const AppFont robotoRegular = AppFont(
    family: _family,
    weight: FontWeight.w400,
  );

  static const AppFont robotoBold = AppFont(
    family: _family,
    weight: FontWeight.w700,
  );

  static const AppFont robotoBlack = AppFont(
    family: _family,
    weight: FontWeight.w900,
  );

  static const AppFont robotoBoldItalic = AppFont(
    family: _family,
    weight: FontWeight.w700,
    style: FontStyle.italic,
  );
}



