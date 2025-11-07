import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/herd_management/data/repositories/animal_repository.dart';
import 'features/herd_management/data/repositories/analysis_repository.dart';
import 'features/herd_management/presentation/controllers/herd_notifier.dart';
import 'features/herd_management/presentation/pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final animalRepository = AnimalRepository();
  final analysisRepository = AnalysisRepository();
  final herdNotifier = HerdNotifier(
    animalRepository: animalRepository,
    analysisRepository: analysisRepository,
  );

  await herdNotifier.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<AnimalRepository>.value(value: animalRepository),
        Provider<AnalysisRepository>.value(value: analysisRepository),
        ChangeNotifierProvider<HerdNotifier>.value(value: herdNotifier),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Saúde do Rebanho',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}
 