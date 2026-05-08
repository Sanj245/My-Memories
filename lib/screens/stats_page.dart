import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';

class StatsPage extends StatelessWidget {
  final List<Achievement> data;

  const StatsPage(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final total = data.length;
    final totalImpact = data.fold<int>(0, (sum, item) => sum + item.impact);
    final avgImpact = total == 0 ? 0.0 : totalImpact / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: Stack(
        children: [
          //////////////////////////////////////////////////////
          /// DREAMY BLOBS
          //////////////////////////////////////////////////////
          Positioned(
            top: 200,
            left: -150,
            child: _buildDreamyBlob(color: const Color(0xFFFEFCE8).withOpacity(0.15), size: 400, delay: 500.ms),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildDreamyBlob(color: const Color(0xFFF0FDF4).withOpacity(0.15), size: 350, delay: 2500.ms),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Impact.",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -1),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  Text(
                    "Your journey in numbers.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B).withOpacity(0.4)),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    children: [
                      Expanded(child: _statCard("MEMORIES", "$total", Icons.auto_stories_rounded, const Color(0xFF6366F1))),
                      const SizedBox(width: 16),
                      Expanded(child: _statCard("AVG IMPACT", avgImpact.toStringAsFixed(1), Icons.bolt_rounded, Colors.orangeAccent)),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  _sectionLabel("TOP CHAPTERS"),
                  ..._buildTopCategories().animate(interval: 100.ms).fadeIn().slideX(begin: 0.1, end: 0),
                ],
              ),
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

  Widget _sectionLabel(String text) {
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 16), child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B).withOpacity(0.3), letterSpacing: 1)));
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B).withOpacity(0.3))),
        ],
      ),
    );
  }

  List<Widget> _buildTopCategories() {
    final counts = <String, int>{};
    for (var item in data) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((e) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.star_rounded, color: Color(0xFF6366F1), size: 16),
          ),
          const SizedBox(width: 16),
          Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const Spacer(),
          Text("${e.value} memories", style: TextStyle(fontWeight: FontWeight.w600, color: const Color(0xFF1E293B).withOpacity(0.4), fontSize: 12)),
        ],
      ),
    )).toList();
  }
}