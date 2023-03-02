import 'package:get_it/get_it.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/services/data_repository.dart';
import 'package:memorize_scripture/theme_manager.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<DataRepository>(() => FakeData());
  getIt.registerFactory<PracticePageManager>(() => PracticePageManager());
  getIt.registerLazySingleton<ThemeManager>(() => ThemeManager());
}
