import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

// Global instance of HiveService
late final HiveService hiveService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    hiveService = HiveService();
    await hiveService.init();

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    // If initialization fails, show error screen
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Vehicle Service Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
