import 'package:csj/features/startup/startup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  Widget builder(
      BuildContext context,
      StartupViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_rounded,
              size: 100,
              color: kcPrimaryColor,
            ),
            verticalSpaceMedium,
            Text(
              'Garment Production',
              style: heading1Style(context),
              textAlign: TextAlign.center,
            ),
            verticalSpaceSmall,
            Text(
              'Management System',
              style: heading3Style(context),
              textAlign: TextAlign.center,
            ),
            verticalSpaceLarge,
            const CircularProgressIndicator(
              color: kcPrimaryColor,
            ),
            verticalSpaceMedium,
            Text(
              'Initializing...',
              style: subtitleStyle(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}
