import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import 'category_detail_page.dart';

class CategoriesPage extends StatelessWidget {
  final List<Achievement> data;
  final Function(int, Achievement) onUpdate;
  final Future<void> Function(int) onDelete;

  const CategoriesPage(this.data, this.onUpdate, this.onDelete, {super.key});

  static List<Color> getPastelGradient(String category) {
    switch (category) {
      case "Travel": return [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)];
      case "Career": return [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)];
      case "Personal": return [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)];
      case "Creative": return [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)];
      case "Fitness": return [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)];
      case "Social": return [const Color(0xFFFEFCE8), const Color(0xFFFEF9C3)];
      case "Learning": return [const Color(0xFFF0FDFA), const Color(0xFFCCFBF1)];
      default: return [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)];
    }
  }

  static Color getAccentColor(String category) {
    switch (category) {
      case "Travel": return const Color(0xFF0284C7);
      case "Career": return const Color(0xFF9333EA);
      case "Personal": return const Color(0xFF16A34A);
      case "Creative": return const Color(0xFFE11D48);
      case "Fitness": return const Color(0xFFEA580C);
      case "Social": return const Color(0xFFCA8A04);
      case "Learning": return const Color(0xFF0D9488);
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardIcons = {
      "Travel": Icons.flight_takeoff_rounded,
      "Career": Icons.work_rounded,
      "Personal": Icons.self_improvement_rounded,
      "Creative": Icons.palette_rounded,
      "Fitness": Icons.fitness_center_rounded,
      "Social": Icons.people_alt_rounded,
      "Learning": Icons.school_rounded,
    };

    final usedCategories = data.map((e) => e.category).toSet().toList();
    final displayCategories = ["Travel", "Career", "Personal", "Creative", "Fitness", "Social", "Learning"];
    for (var cat in usedCategories) {
      if (!displayCategories.contains(cat)) displayCategories.add(cat);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          //////////////////////////////////////////////////////
          /// DREAMY BLOBS
          //////////////////////////////////////////////////////
          Positioned(
            top: 100,
            left: -100,
            child: _buildDreamyBlob(color: const Color(0xFFF3E8FF).withOpacity(0.15), size: 300, delay: 0.ms),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildDreamyBlob(color: const Color(0xFFE0F2FE).withOpacity(0.15), size: 400, delay: 1000.ms),
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text("Explore.", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w800, fontSize: 32, letterSpacing: -1)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    itemCount: displayCategories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final name = displayCategories[index];
                      final icon = standardIcons[name] ?? Icons.category_rounded;
                      final count = data.where((e) => e.category == name).length;
                      final gradient = getPastelGradient(name);
                      final accent = getAccentColor(name);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailPage(
                                category: name,
                                data: data,
                                onUpdate: onUpdate,
                                onDelete: onDelete,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: accent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                                child: Icon(icon, size: 28, color: accent),
                              ),
                              const SizedBox(height: 12),
                              Text(name, style: TextStyle(color: accent.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Text("$count memories", style: TextStyle(color: accent.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamyBlob({required Color color, required double size, required Duration delay}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(duration: 5.seconds, delay: delay, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut)
     .move(duration: 8.seconds, delay: delay, begin: const Offset(-20, -20), end: const Offset(20, 20), curve: Curves.easeInOut);
  }
}