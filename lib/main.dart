import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const KaesetApp(),
    ),
  );
}

class KaesetApp extends StatelessWidget {
  const KaesetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          builder: (context, appChild) {
            // Apply global font scaling (1.0x - 2.0x) to all text components
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontProvider.fontScale),
              ),
              child: appChild!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
