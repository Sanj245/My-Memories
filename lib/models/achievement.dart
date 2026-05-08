class Achievement {
  String id;
  String title;
  String description;
  String category;
  String date;
  String location;
  int impact; // 1 to 5
  List<String> tags;

  // all gallery images
  List<String> images;

  // selected custom cover image
  String coverImage;

  Achievement({
    this.id = "",
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.location,
    required this.images,
    this.coverImage = "",
    this.impact = 3,
    this.tags = const [],
  });

  //////////////////////////////////////////////////////
  /// TO MAP
  //////////////////////////////////////////////////////

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "category": category,
      "date": date,
      "location": location,
      "images": images,
      "coverImage": coverImage,
      "impact": impact,
      "tags": tags,
    };
  }

  //////////////////////////////////////////////////////
  /// FROM MAP
  //////////////////////////////////////////////////////

  factory Achievement.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return Achievement(
      id: docId,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      category: map["category"] ?? "Other",
      date: map["date"] ?? "",
      location: map["location"] ?? "",
      images: List<String>.from(
        map["images"] ?? [],
      ),

      // NEW
      coverImage: map["coverImage"] ?? "",
      impact: map["impact"] ?? 3,
      tags: List<String>.from(map["tags"] ?? []),
    );
  }
}