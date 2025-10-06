import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/scan_report_page.dart';
import 'screens/history_page.dart';
import 'screens/profile_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// 🔹 Global Theme Notifier (shared across app)
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

/// 🔹 Light Theme
final ThemeData lightThemeData = ThemeData(
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: const Color(0xFFF7F8FA),
  useMaterial3: true,
);

/// 🔹 Dark Theme
final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: const Color(0xFF121212),
  useMaterial3: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HealthMateXApp());
}

class HealthMateXApp extends StatefulWidget {
  const HealthMateXApp({super.key});

  @override
  State<HealthMateXApp> createState() => _HealthMateXAppState();
}

class _HealthMateXAppState extends State<HealthMateXApp> {
  bool _showOnboarding = true;
  String _initialRoute = '/onboarding';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _initialRoute = '/home';
      _showOnboarding = false;
    } else {
      _initialRoute = _showOnboarding ? '/onboarding' : '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        // 🔹 Update status bar appearance dynamically
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'HealthMateX',
          debugShowCheckedModeBanner: false,
          theme: lightThemeData,
          darkTheme: darkThemeData,
          themeMode: mode,
          initialRoute: _initialRoute,
          routes: {
            '/onboarding': (context) => OnboardingPage(
                  onFinish: () {
                    setState(() {
                      _showOnboarding = false;
                      _initialRoute = '/login';
                    });
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
            '/login': (context) => LoginPage(
                  onLogin: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                ),
            '/register': (context) => RegisterPage(
                  onRegister: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                ),
            '/home': (context) =>
                BottomNavController(themeNotifier: themeNotifier),
          },
        );
      },
    );
  }
}

class BottomNavController extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const BottomNavController({super.key, required this.themeNotifier});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ScanReportPage(),
      const HistoryPage(),
      ProfilePage(themeNotifier: widget.themeNotifier),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = const Color(0xFF2684FF);
    final gray = Colors.grey.shade500;

    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => setState(() => selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
            selectedItemColor: blue,
            unselectedItemColor: gray,
            selectedFontSize: 14,
            unselectedFontSize: 14,
            iconSize: 26,
            elevation: 2,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                activeIcon: Icon(Icons.camera_alt),
                label: 'Scan Report',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
