import 'package:get_it/get_it.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/services/book_data/bible_data.dart';
import 'package:memorize_scripture/services/local_storage/data_repository.dart';
import 'package:memorize_scripture/services/local_storage/sqflite/database.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<UserSettings>(() => SharedPreferencesStorage());
  getIt.registerLazySingleton<SecureStorage>(() => LocalSecureStorage());
  getIt.registerLazySingleton<LocalStorage>(() => SqfliteStorage());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerFactory<PracticePageManager>(() => PracticePageManager());
  getIt.registerLazySingleton<AppManager>(() => AppManager());
  getIt.registerLazySingleton<HomePageManager>(() => HomePageManager());
  getIt.registerLazySingleton<BibleData>(() => BibleData());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
