import 'package:get_it/get_it.dart';

import 'injection_container.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await getIt.init();
}
