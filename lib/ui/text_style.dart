import 'package:csj/ui/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

// Headings
TextStyle heading1Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 32, 40),
  fontWeight: FontWeight.w700,
  color: kcPrimaryTextColor,
  height: 1.2,
);

TextStyle heading2Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 26, 34),
  fontWeight: FontWeight.w600,
  color: kcPrimaryTextColor,
  height: 1.3,
);

TextStyle heading3Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 22, 28),
  fontWeight: FontWeight.w600,
  color: kcPrimaryTextColor,
  height: 1.3,
);

TextStyle heading4Style(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 18, 24),
  fontWeight: FontWeight.w600,
  color: kcPrimaryTextColor,
  height: 1.4,
);

// Body Text
TextStyle bodyStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 16, 18),
  fontWeight: FontWeight.normal,
  color: kcPrimaryTextColor,
  height: 1.5,
);

TextStyle bodyBoldStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 16, 18),
  fontWeight: FontWeight.w600,
  color: kcPrimaryTextColor,
  height: 1.5,
);

TextStyle bodySmallStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 14, 16),
  fontWeight: FontWeight.normal,
  color: kcPrimaryTextColor,
  height: 1.4,
);

// Captions and Labels
TextStyle captionStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 12, 14),
  fontWeight: FontWeight.normal,
  color: kcSecondaryTextColor,
  height: 1.3,
);

TextStyle subtitleStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 14, 16),
  fontWeight: FontWeight.w500,
  color: kcSecondaryTextColor,
  height: 1.4,
);

// Button Text
TextStyle buttonTextStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 16, 18),
  fontWeight: FontWeight.w600,
  color: Colors.white,
  height: 1.3,
);

// Status Text
TextStyle statusTextStyle(BuildContext context, {required Color color}) =>
    TextStyle(
      fontSize: getResponsiveFontSize(context, 14, 16),
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );

// Cards
TextStyle cardTitleStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 18, 22),
  fontWeight: FontWeight.w600,
  color: kcPrimaryTextColor,
  height: 1.3,
);

TextStyle cardSubtitleStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 14, 16),
  fontWeight: FontWeight.w500,
  color: kcSecondaryTextColor,
  height: 1.3,
);

// Dashboard Stats
TextStyle statNumberStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 26, 36),
  fontWeight: FontWeight.w700,
  color: kcPrimaryColor,
  height: 1.1,
);

TextStyle statLabelStyle(BuildContext context) => TextStyle(
  fontSize: getResponsiveFontSize(context, 12, 14),
  fontWeight: FontWeight.w500,
  color: kcSecondaryTextColor,
  height: 1.3,
);
