import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/services.dart';
import 'providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = await StorageService.initialize();
  final encryptionService = EncryptionService();

  // Set a default master password for demonstration
  // In a real app, you'd have a proper master password setup flow
  encryptionService.setMasterPassword('demo_master_password_2024');

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<EncryptionService>.value(value: encryptionService),
        ChangeNotifierProvider(
          create: (context) => AppProvider(
            storageService,
            encryptionService,
          ),
        ),
      ],
      child: const PasswordBoardApp(),
    ),
  );
}

class PasswordBoardApp extends StatelessWidget {
  const PasswordBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
