import 'package:flutter/material.dart';

class CategoryRepository {
  CategoryRepository._privateConstructor();
  static final CategoryRepository _instance = CategoryRepository._privateConstructor();
  static CategoryRepository get instance => _instance;

  final List<String> _categories = [
    "Travel",
    "Career",
    "Personal",
    "Creative",
    "Fitness",
    "Social",
    "Learning",
  ];

  List<String> get categories => List.unmodifiable(_categories);

  void addCategory(String category) {
    if (category.isEmpty) return;
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
  }
}
