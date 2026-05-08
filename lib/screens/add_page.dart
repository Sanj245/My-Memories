import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../models/achievement.dart';
import 'categories_page.dart';

class AddPage extends StatefulWidget {
  final Future<void> Function(Achievement, List<Uint8List>?) onAdd;

  const AddPage({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final location = TextEditingController();
  final customCategoryController = TextEditingController();

  String category = "Travel";
  int impact = 3;
  bool isCustomCategory = false;

  DateTime selectedDate = DateTime.now();
  final picker = ImagePicker();
  List<String> images = [];
  List<Uint8List> webImages = [];
  bool isLoading = false;

  final categories = ["Travel", "Career", "Personal", "Creative", "Fitness", "Social", "Learning"];

  final Map<String, String> categoryEmojis = {
    "Travel": "✈️",
    "Career": "💼",
    "Personal": "🌱",
    "Creative": "🎨",
    "Fitness": "💪",
    "Social": "🥳",
    "Learning": "📚",
  };

  Future pickImages() async {
    final files = await picker.pickMultiImage(imageQuality: 50);
    if (files.isEmpty) return;
    if (kIsWeb) {
      webImages.clear();
      images.clear();
      for (var file in files) {
        final bytes = await file.readAsBytes();
        webImages.add(bytes);
        images.add(file.name);
      }
    } else {
      images = files.map((e) => e.path).toList();
    }
    setState(() {});
  }

  Future save() async {
    if (title.text.trim().isEmpty) return;
    String finalCategory = isCustomCategory ? customCategoryController.text.trim() : category;
    if (finalCategory.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final achievement = Achievement(
        title: title.text.trim(),
        description: desc.text.trim(),
        category: finalCategory,
        date: selectedDate.toString().split(" ")[0],
        location: location.text.trim(),
        images: List<String>.from(images),
        impact: impact,
        tags: [],
      );
      await widget.onAdd(achievement, kIsWeb ? List<Uint8List>.from(webImages) : null);
      title.clear();
      desc.clear();
      location.clear();
      customCategoryController.clear();
      images.clear();
      webImages.clear();
      setState(() {
        isCustomCategory = false;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: _buildDreamyBlob(color: const Color(0xFFFFF1F2).withOpacity(0.15), size: 400, delay: 0.ms),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: _buildDreamyBlob(color: const Color(0xFFF0FDFA).withOpacity(0.15), size: 300, delay: 1500.ms),
          ),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
              children: [
                const Text(
                  "Capture.",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5),
                ),
                Text(
                  "Document another beautiful moment.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B).withOpacity(0.4)),
                ),
                const SizedBox(height: 24),
                _sectionLabel("THE MEMORY"),
                _inputBox(
                  child: Column(
                    children: [
                      _textField(title, "Title", Icons.bookmark_outline_rounded),
                      const Divider(height: 1),
                      _textField(desc, "Description...", Icons.notes_rounded, maxLines: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel("IMPACT RATING"),
                _inputBox(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (i) {
                      final active = impact > i;
                      return GestureDetector(
                        onTap: () => setState(() => impact = i + 1),
                        child: Icon(
                          active ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: active ? const Color(0xFFFFB800) : const Color(0xFFE2E8F0),
                          size: 28,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel("CHAPTER"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      ...categories.map((c) => _categoryChip(c)),
                      _categoryChip("Custom...", isCustom: true),
                    ],
                  ),
                ),
                if (isCustomCategory) ...[
                  const SizedBox(height: 12),
                  _inputBox(child: _textField(customCategoryController, "Category name", Icons.edit_note_rounded)),
                ],
                const SizedBox(height: 20),
                _sectionLabel("DETAILS"),
                _inputBox(
                  child: Row(
                    children: [
                      Expanded(child: _textField(location, "Location", Icons.location_on_rounded)),
                      IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                          if (picked != null) setState(() => selectedDate = picked);
                        },
                        icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1), size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel("PHOTOS"),
                GestureDetector(
                  onTap: pickImages,
                  child: _inputBox(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, color: const Color(0xFF6366F1).withOpacity(0.4), size: 28),
                          const SizedBox(height: 6),
                          const Text("Add Photos", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6366F1), fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, i) => Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb ? Image.memory(webImages[i], fit: BoxFit.cover) : Image.file(File(images[i]), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 6,
                      shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                    ),
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Capture Memory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ],
            ).animate().fadeIn(),
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
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B).withOpacity(0.3), letterSpacing: 1)));
  }

  Widget _inputBox({required Widget child, EdgeInsets? padding}) {
    return Container(padding: padding ?? const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: child);
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF1E293B).withOpacity(0.2), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1).withOpacity(0.4), size: 18),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _categoryChip(String label, {bool isCustom = false}) {
    final selected = isCustom ? isCustomCategory : (category == label && !isCustomCategory);
    return GestureDetector(
      onTap: () => setState(() {
        if (isCustom) {
          isCustomCategory = true;
        } else {
          isCustomCategory = false;
          category = label;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Text(isCustom ? "✨" : (categoryEmojis[label] ?? "📍"), style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? const Color(0xFF6366F1) : Colors.grey.shade600, fontWeight: FontWeight.w800, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
