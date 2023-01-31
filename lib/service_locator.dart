import 'package:get_it/get_it.dart';
import 'package:memorize_scripture/services/data_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<DataRepository>(()=> FakeData());
}