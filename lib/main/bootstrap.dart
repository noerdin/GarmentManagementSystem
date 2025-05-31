import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../app/app.bottomsheets.dart';
import '../app/app.dialogs.dart';
import '../app/app.locator.dart';
import '../models/enums/flavor.dart';
import '../utils/flavors.dart';

Future<void> bootstrap(
    {required FutureOr<Widget> Function() builder,
      required Flavor flavor,}) async {
  await runZonedGuarded(
        () async {
      Flavors.flavor = flavor;
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);

      await Firebase.initializeApp();
      await setupLocator();
      setupDialogUi();
      setupBottomSheetUi();

      await SentryFlutter.init((options) {
        options.dsn = 'https://e7e6d2fa87ec04f15ef59b7802f41773@o4509348318806016.ingest.us.sentry.io/4509348338860032';
      }, appRunner: () async => runApp(await builder()));
    },
        (exception, stackTrace) async {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    },
  );
}
