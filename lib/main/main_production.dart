import '../features/app/app_view.dart';
import '../models/enums/flavor.dart';
import 'bootstrap.dart';

void main() async {
  bootstrap(
    builder: () => const AppView(),
    flavor: Flavor.production,
  );
}
