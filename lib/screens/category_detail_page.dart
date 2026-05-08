import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import 'detail_page.dart';
import 'categories_page.dart'; // To reuse the gradient logic

class CategoryDetailPage extends StatefulWidget {
  final String category;
  final List<Achievement> data;
  final Function(int, Achievement) onUpdate;
  final Future<void> Function(int) onDelete;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.data,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    final filtered = widget.data.where((e) => e.category == widget.category).toList();
    final gradient = CategoriesPage.getPastelGradient(widget.category);
    final accent = CategoriesPage.getAccentColor(widget.category);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          //////////////////////////////////////////////////////
          /// PASTEL HEADER
          //////////////////////////////////////////////////////
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: gradient.last,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradient,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.auto_awesome, size: 120, color: accent),
                  ),
                ),
              ),
            ),
          ),

          //////////////////////////////////////////////////////
          /// LIST
          //////////////////////////////////////////////////////
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            sliver: filtered.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "No memories here yet.",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = filtered[i];
                        final realIndex = widget.data.indexOf(item);

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(
                                  item: item,
                                  index: realIndex,
                                  onUpdate: widget.onUpdate,
                                  onDelete: widget.onDelete,
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: accent.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Date Column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.date.split("-")[2], // Day
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      item.date.split("-")[1], // Month
                                      style: TextStyle(
                                        color: accent.withOpacity(0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                // Title
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 14, color: accent.withOpacity(0.3)),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.1, end: 0);
                      },
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}