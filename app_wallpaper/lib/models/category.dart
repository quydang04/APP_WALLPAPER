class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final int wallpaperCount;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.wallpaperCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      wallpaperCount: json['wallpaperCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'wallpaperCount': wallpaperCount,
    };
  }
}
