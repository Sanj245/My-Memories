import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/achievement.dart';
import 'categories_page.dart';

class EditPage extends StatefulWidget {
  final Achievement item;
  final Future<void> Function(Achievement) onUpdate;

  const EditPage({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController title;
  late TextEditingController desc;
  late TextEditingController location;
  final customCategoryController = TextEditingController();

  late String category;
  late int impact;
  late List<String> tags;
  late String selectedDate;
  bool isCustomCategory = false;
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

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.item.title);
    desc = TextEditingController(text: widget.item.description);
    location = TextEditingController(text: widget.item.location);
    category = widget.item.category;
    impact = widget.item.impact;
    tags = List.from(widget.item.tags);
    selectedDate = widget.item.date;

    if (!categories.contains(category)) {
      isCustomCategory = true;
      customCategoryController.text = category;
    }
  }

  Future save() async {
    if (title.text.trim().isEmpty) return;
    String finalCategory = isCustomCategory ? customCategoryController.text.trim() : category;
    if (finalCategory.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final updated = Achievement(
        id: widget.item.id,
        title: title.text.trim(),
        description: desc.text.trim(),
        category: finalCategory,
        date: selectedDate,
        location: location.text.trim(),
        images: widget.item.images,
        coverImage: widget.item.coverImage,
        impact: impact,
        tags: tags,
      );
      await widget.onUpdate(updated);
      if (mounted) Navigator.pop(context, updated);
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF6366F1)),
                ),
                const Text(
                  "Refine.",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 32),

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

            const SizedBox(height: 24),

            _sectionLabel("IMPACT RATING"),
            _inputBox(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  final active = impact > i;
                  return GestureDetector(
                    onTap: () => setState(() => impact = i + 1),
                    child: Icon(
                      active ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: active ? const Color(0xFFFFB800) : const Color(0xFFE2E8F0),
                      size: 32,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 24),

            _sectionLabel("DETAILS"),
            _inputBox(
              child: Row(
                children: [
                  Expanded(child: _textField(location, "Location", Icons.location_on_rounded)),
                  IconButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked.toString().split(" ")[0]);
                    },
                    icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Memory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B).withOpacity(0.3), letterSpacing: 1)),
    );
  }

  Widget _inputBox({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF1E293B).withOpacity(0.2)),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1).withOpacity(0.4), size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Text(
              isCustom ? "✨" : (categoryEmojis[label] ?? "📍"),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF6366F1) : Colors.grey.shade600,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
