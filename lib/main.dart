import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Allow Google Fonts to use HTTP to fetch fonts if not bundled
    GoogleFonts.config.allowRuntimeFetching = true;
    
    // Attempt to load .env, trying the web path if the default fails
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      await dotenv.load(fileName: "assets/.env");
    }

    runApp(
      const ProviderScope(
        child: VadamaApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization Error: $e'),
          ),
        ),
      ),
    );
  }
}

class VadamaApp extends ConsumerWidget {
  const VadamaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Vadama',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: authState.when(
        data: (user) => user != null ? const MainScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error: $err'),
          ),
        ),
      ),
    );
  }
}
