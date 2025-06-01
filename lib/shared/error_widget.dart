import 'package:flutter/material.dart';
import '../ui/app_colors.dart';
import '../ui/text_style.dart';
import '../ui/ui_helpers.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: kcErrorColor.withOpacity(0.7),
            ),
            verticalSpaceMedium,
            Text(
              'Oops! Something went wrong',
              style: heading3Style(context),
              textAlign: TextAlign.center,
            ),
            verticalSpaceSmall,
            Text(
              error,
              style: bodyStyle(context),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              verticalSpaceLarge,
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: buttonTextStyle(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}