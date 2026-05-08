import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../models/achievement.dart';
import 'edit_page.dart';

class DetailPage extends StatelessWidget {
  final Achievement item;
  final int index;
  final Function(int, Achievement) onUpdate;
  final Future<void> Function(int) onDelete;

  const DetailPage({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Gather all images (cover first, then the rest)
    List<String> displayImages = [];
    if (item.coverImage.isNotEmpty) displayImages.add(item.coverImage);
    displayImages.addAll(item.images.where((img) => img != item.coverImage));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPage(
                    item: item,
                    onUpdate: (u) async {
                      onUpdate(index, u);
                    },
                  ),
                ),
              );

              if (updated != null && context.mounted) {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(
                   builder: (_) => DetailPage(
                     item: updated,
                     index: index,
                     onUpdate: onUpdate,
                     onDelete: onDelete,
                   )
                 ));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Entry?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                Navigator.pop(context); // pop detail page
                await onDelete(index);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////////////////////////////////////////////
            /// CAROUSEL
            //////////////////////////////////////////////////////
            if (displayImages.isNotEmpty)
              Hero(
                tag: "card_${item.id}",
                child: displayImages.length == 1
                    ? SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width,
                        child: buildImage(displayImages.first),
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 1.0,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                        ),
                        items: displayImages.map((img) {
                          return Builder(
                            builder: (BuildContext context) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: buildImage(img),
                              );
                            },
                          );
                        }).toList(),
                      ),
              ),

            //////////////////////////////////////////////////////
            /// CONTENT
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //////////////////////////////////////////////////////
                  /// DATE & LOCATION
                  //////////////////////////////////////////////////////
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        item.date,
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                      if (item.location.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                    ],
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),

                  //////////////////////////////////////////////////////
                  /// TITLE
                  //////////////////////////////////////////////////////
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),

                  //////////////////////////////////////////////////////
                  /// TAGS & IMPACT (NOTION STYLE)
                  //////////////////////////////////////////////////////
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Impact
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${item.impact} Impact",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tags
                      ...item.tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  //////////////////////////////////////////////////////
                  /// DESCRIPTION
                  //////////////////////////////////////////////////////
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage(String path) {
    if (path.startsWith("http") || kIsWeb) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }
}