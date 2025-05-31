import 'package:csj/shared/app_colors.dart';
import 'package:csj/shared/ui_helpers.dart';
import 'package:flutter/material.dart';

// Heading Text Styles
TextStyle heading1Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveMassiveFontSize(context),
  fontWeight: FontWeight.w700,
  color: kcPrimaryTextColor,
);

TextStyle heading2Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveExtraLargeFontSize(context),
  fontWeight: FontWeight.w700,
  color: kcPrimaryTextColor,
);

TextStyle heading3Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveLargeFontSize(context),
  fontWeight: FontWeight.w700,
  color: kcPrimaryTextColor,
);

// Body Text Styles
TextStyle bodyStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveMediumFontSize(context),
  fontWeight: FontWeight.w400,
  color: kcSecondaryTextColor,
);

TextStyle subtitleStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveSmallFontSize(context),
  fontWeight: FontWeight.w400,
  color: kcTertiaryTextColor,
);

// Button Text Styles
TextStyle buttonTextStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveMediumFontSize(context),
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

// Caption Text Styles
TextStyle captionStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveSmallFontSize(context),
  fontWeight: FontWeight.w400,
  color: kcSecondaryTextColor,
);
