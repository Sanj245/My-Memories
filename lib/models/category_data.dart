import 'category.dart';

class CategoryData {
  static final List<Category> categories = [
    Category(name: 'Travel', emoji: '🌍'), // Changed from ✈️
    Category(name: 'Career', emoji: '🏆'), // Changed from 💼
    Category(name: 'Personal', emoji: '🌱'),
    Category(name: 'Creative', emoji: '🎨'),
    Category(name: 'Fitness', emoji: '🔥'), // Changed from 💪
    Category(name: 'Social', emoji: '🥂'), // Changed from 🥳
    Category(name: 'Learning', emoji: '🧠'), // Changed from 📚
    // Custom categories will be added dynamically with default emoji ✨
  ];

  static void addCategory(String name, {String emoji = '✨'}) {
    // Prevent duplicate names (case‑insensitive)
    if (categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) return;
    categories.add(Category(name: name, emoji: emoji));
  }

  static String getEmoji(String categoryName) {
    return categories.firstWhere(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => Category(name: categoryName, emoji: '✨'),
    ).emoji;
  }
}
