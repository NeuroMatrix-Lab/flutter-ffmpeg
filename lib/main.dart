import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/converter_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const FFmpegConverterApp());
}

class FFmpegConverterApp extends StatelessWidget {
  const FFmpegConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFmpeg Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.grey[700]!,
          surface: Colors.grey[50]!,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey[300]!,
          surface: Colors.grey[900]!,
        ),
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
          case '/converter':
            final files = settings.arguments as List;
            return MaterialPageRoute(
              builder: (_) => ConverterPage(
                files: files.cast(),
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
        }
      },
    );
  }
}
