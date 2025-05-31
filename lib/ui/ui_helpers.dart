import 'dart:math';
import 'package:flutter/material.dart';
import 'app_colors.dart';


// Horizontal Spacing
const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceMedium = SizedBox(width: 18.0);
const Widget horizontalSpaceLarge = SizedBox(width: 25.0);
const Widget horizontalSpaceExtraLarge = SizedBox(width: 35.0);

// Vertical Spacing
const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceMedium = SizedBox(height: 18.0);
const Widget verticalSpaceLarge = SizedBox(height: 25.0);
const Widget verticalSpaceExtraLarge = SizedBox(height: 35.0);
const Widget verticalSpaceMassive = SizedBox(height: 50.0);

// Custom Spacer
Widget verticalSpace(double height) => SizedBox(height: height);
Widget horizontalSpace(double width) => SizedBox(width: width);

// Screen Size Helpers
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

// Screen Fractions
double screenHeightFraction(
    BuildContext context, {
      int dividedBy = 1,
      double offsetBy = 0,
      double max = double.infinity,
    }) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(
    BuildContext context, {
      int dividedBy = 1,
      double offsetBy = 0,
      double max = double.infinity,
    }) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

// Common Screen Widths
double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 4);

// Responsive Spacing
double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidth(context) < 500 ? 15 : 25;

double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, 14, 16);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, 16, 18);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, 18, 20);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, 20, 22);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, 24, 28);

double getResponsiveFontSize(
    BuildContext context,
    double fontSize,
    double maxFontSize, {
      double? minFontSize,
    }) {
  double screenWidth = MediaQuery.of(context).size.width;

  // Define breakpoints
  double mobileBreakpoint = 480.0;
  double tabletBreakpoint = 768.0;

  // Set minimum font size if provided
  double minimumFontSize = minFontSize ?? 12.0;

  // Calculate font size based on screen width
  if (screenWidth <= mobileBreakpoint) {
    return max(minimumFontSize, fontSize);
  } else if (screenWidth <= tabletBreakpoint) {
    // Linear interpolation between fontSize and maxFontSize
    double scaleFactor = (screenWidth - mobileBreakpoint) /
        (tabletBreakpoint - mobileBreakpoint);
    return max(
        minimumFontSize, fontSize + (maxFontSize - fontSize) * scaleFactor);
  } else {
    return max(minimumFontSize, maxFontSize);
  }
}

// Dividers
const Widget spacedDivider = Column(
  children: <Widget>[
    verticalSpaceMedium,
    Divider(),
    verticalSpaceMedium,
  ],
);

// Custom Divider
Widget customDivider({
  double height = 1.0,
  Color color = kcLightGrey,
  double indent = 0.0,
  double endIndent = 0.0,
}) =>
    Divider(
      height: height,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );

// Card Box Shadow
List<BoxShadow> defaultBoxShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

// Border Radius
BorderRadius defaultBorderRadius = BorderRadius.circular(12);
BorderRadius smallBorderRadius = BorderRadius.circular(8);
BorderRadius largeBorderRadius = BorderRadius.circular(16);

// Card Decoration
BoxDecoration cardDecoration = BoxDecoration(
  color: kcCardColor,
  borderRadius: defaultBorderRadius,
  boxShadow: defaultBoxShadow,
);

// Status Chips
Widget statusChip(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );
}

// Progress Indicator
Widget customProgressIndicator({double value = 0.0, Color? color}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: value,
      backgroundColor: kcLightGrey,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? kcPrimaryColor),
      minHeight: 8,
    ),
  );
}

// Date Format Helper
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day/$month/$year';
}
