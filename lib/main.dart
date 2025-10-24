import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/providers/auth_provider.dart';
import 'package:quicserve_flutter/providers/staff_provider.dart';
import 'package:quicserve_flutter/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
      ],
      child: const QuicServeApp(),
    ),
  );
}

class QuicServeApp extends StatelessWidget {
  const QuicServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuicServe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightgrey1,
        fontFamily: 'Calibri',
        textTheme: const TextTheme(
          bodyMedium: CustomFont.calibri20,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkgrey3),
      ),
      home: const SplashScreen(), // Splash first
    );
  }
}
