import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  String profileEmoji = "🌱";
  final List<String> emojis = ["🌱", "🌸", "🎨", "🚀", "☁️", "🐚", "🌊", "🌙", "✨", "🦋", "🍄", "🥑", "🍦", "🛸", "👾"];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString("user_name") ?? "Beautiful User";
      profileEmoji = prefs.getString("user_emoji") ?? "🌱";
    });
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_name", nameController.text.trim());
    await prefs.setString("user_emoji", profileEmoji);
  }

  void randomizeEmoji() {
    setState(() {
      profileEmoji = emojis[Random().nextInt(emojis.length)];
    });
    saveProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF6366F1)),
                    ),
                    const Text(
                      "Profile.",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Emoji Profile Picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1), width: 4),
                    ),
                    child: Center(
                      child: Text(profileEmoji, style: const TextStyle(fontSize: 50)),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  GestureDetector(
                    onTap: randomizeEmoji,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                      child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Name Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "Enter your name"),
                  onChanged: (v) => saveProfile(),
                ),
              ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 8),
              Text(
                user?.email ?? "Guest User",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B).withOpacity(0.3)),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 60),
              
              // Auth Actions
              if (user == null)
                _buildAuthOption(Icons.login_rounded, "Login / Sign Up", const Color(0xFF6366F1), () {
                  // Navigation to Auth handled by StreamBuilder in main.dart or manually here
                  Navigator.pop(context); // Close profile to see auth screen if main.dart is updated
                })
              else
                _buildAuthOption(Icons.logout_rounded, "Logout", const Color(0xFFE11D48), () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                }),
                
              const SizedBox(height: 12),
              Text(
                "Version 1.0.0",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B).withOpacity(0.2)),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
