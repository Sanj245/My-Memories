import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/achievement.dart';
import 'detail_page.dart';
import 'categories_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final List<Achievement> data;
  final Future<void> Function(int) delete;
  final Function(int, Achievement) update;

  const HomePage(
    this.data,
    this.delete,
    this.update, {
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = "";
  final searchController = TextEditingController();

  final Map<String, String> categoryEmojis = {
    "Travel": "✈️",
    "Career": "💼",
    "Personal": "🌱",
    "Creative": "🎨",
    "Fitness": "💪",
    "Social": "🥳",
    "Learning": "📚",
  };

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning, beautiful. ☀️";
    if (hour < 17) return "Good afternoon, beautiful. 🌤️";
    return "Good evening, beautiful. 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final sortedData = List<Achievement>.from(widget.data)
      ..sort((a, b) => b.date.compareTo(a.date));

    final filtered = sortedData.where((e) {
      final query = search.toLowerCase();
      if (query.isEmpty) return true;
      return e.title.toLowerCase().startsWith(query) ||
             e.category.toLowerCase().startsWith(query) ||
             e.tags.any((t) => t.toLowerCase().startsWith(query));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: Stack(
        children: [
          //////////////////////////////////////////////////////
          /// DREAMY BACKGROUND BLOBS
          //////////////////////////////////////////////////////
          Positioned(
            top: -100,
            right: -100,
            child: _buildDreamyBlob(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              size: 500,
              delay: 0.ms,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: _buildDreamyBlob(
              color: const Color(0xFFBAE6FD).withOpacity(0.12),
              size: 450,
              delay: 2000.ms,
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //////////////////////////////////////////////////////
                /// ANIMATED TOP BAR
                //////////////////////////////////////////////////////
                _buildAnimatedTopBar(),

                //////////////////////////////////////////////////////
                /// GLASSMORPHIC SEARCH BAR
                //////////////////////////////////////////////////////
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (v) => setState(() => search = v),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Find a memory...",
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 20),
                            suffixIcon: search.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() => search = "");
                                  },
                                )
                              : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                Expanded(
                  child: filtered.isEmpty
                      ? emptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 150),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final originalIndex = widget.data.indexOf(item);
                            return buildEntry(item, originalIndex, index);
                          },
                        ),
                )
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(duration: 6.seconds, delay: delay, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut)
     .move(duration: 10.seconds, delay: delay, begin: const Offset(-30, -30), end: const Offset(30, 30), curve: Curves.easeInOut);
  }

  Widget _buildAnimatedTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getGreeting(),
                style: const TextStyle(
                  color: Color(0xFF818CF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
              const Text(
                "My Journal.",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideX(begin: -0.1, end: 0)
               .shimmer(delay: 2.seconds, duration: 3.seconds, color: const Color(0xFFBAE6FD).withOpacity(0.4)),
            ],
          ),
          _buildProfileIcon(),
        ],
      ),
    );
  }

  Widget _buildProfileIcon() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15),
          ],
        ),
        child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 24),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(duration: 2.seconds, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), curve: Curves.easeInOut);
  }

  Widget buildEntry(Achievement item, int originalIndex, int index) {
    final accent = CategoriesPage.getAccentColor(item.category);
    final emoji = categoryEmojis[item.category] ?? "✨";
    final gradient = CategoriesPage.getPastelGradient(item.category);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(
            item: item,
            index: originalIndex,
            onUpdate: widget.update,
            onDelete: widget.delete,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradient.first.withOpacity(0.6),
                  gradient.last.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.date.split("-")[0],
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
                            ),
                            child: Row(
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  item.category.toUpperCase(),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: Colors.orangeAccent),
                          const SizedBox(width: 4),
                          Text(
                            "${item.impact}",
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .moveX(begin: 0, end: 4, duration: 1.seconds, curve: Curves.easeInOut),
              ],
            ),
          ),
        ),
      ),
    )
    .animate(key: ValueKey(item.id)) // Added key for smoother re-ordering animations
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book_rounded, size: 60, color: const Color(0xFF6366F1).withOpacity(0.3)),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
           .shimmer(delay: 1.seconds, duration: 1.5.seconds),
          const SizedBox(height: 24),
          const Text(
            "Your story is waiting.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Turn a moment into a memory today.",
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF1E293B).withOpacity(0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 1.seconds),
    );
  }
}