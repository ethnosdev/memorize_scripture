import 'package:get_it/get_it.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/data_repository/sqflite/database.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<UserSettings>(
      () => SharedPreferencesLocalStorage());
  getIt.registerLazySingleton<DataRepository>(() => LocalStorage());
  getIt.registerFactory<PracticePageManager>(() => PracticePageManager());
  getIt.registerLazySingleton<AppManager>(() => AppManager());
}
