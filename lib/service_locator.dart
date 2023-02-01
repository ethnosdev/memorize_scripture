import 'package:get_it/get_it.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/services/data_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<DataRepository>(() => FakeData());
  getIt.registerFactory<PracticePageManager>(() => PracticePageManager());
}
