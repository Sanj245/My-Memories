import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/achievement.dart';

import 'screens/home_page.dart';
import 'screens/categories_page.dart';
import 'screens/add_page.dart';
import 'screens/stats_page.dart';
import 'screens/auth_page.dart';

import 'services/firebase_service.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FBFF),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          displayMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const AuthPage();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  List<Achievement> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    FirebaseService.load().then((value) {
      setState(() {
        data = value;
      });
    });
  }

  Future<void> add(Achievement a, List<Uint8List>? webImages) async {
    final saved = await FirebaseService.add(a, webImages: webImages);
    setState(() {
      data.insert(0, saved);
      index = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(20),
          content: const Text("Memory saved.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      );
    });
  }

  void update(int i, Achievement updated) {
    setState(() {
      data[i] = updated;
    });
  }

  Future<void> delete(int i) async {
    final id = data[i].id;
    setState(() {
      data.removeAt(i);
    });
    await FirebaseService.delete(id);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(data, delete, update),
      CategoriesPage(data, update, delete),
      AddPage(onAdd: add),
      StatsPage(data),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBFF),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30),
            ],
          ),
          child: Stack(
            children: [
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: screens[index],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(0, Icons.home_rounded, "Home"),
              _navItem(1, Icons.grid_view_rounded, "Explore"),
              _addButton(),
              _navItem(3, Icons.insights_rounded, "Stats"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    final isSelected = index == 2;
    return GestureDetector(
      onTap: () => setState(() => index = 2),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final isSelected = index == i;
    return GestureDetector(
      onTap: () => setState(() => index = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}