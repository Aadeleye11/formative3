import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/a_auth/splash_screen.dart';
import 'screens/dev/screen_gallery.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AluLinkApp());
}

class AluLinkApp extends StatelessWidget {
  const AluLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALULink',
      debugShowCheckedModeBanner: false,
      theme: buildAluLinkTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/gallery': (context) => const ScreenGalleryScreen(),
      },
    );
  }
}
