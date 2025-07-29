class Wallpaper {
  final String id;
  final String title;
  final String imageUrl;
  final String? thumbnailUrl;
  final String authorId;
  final String authorName;
  final List<String> categories;
  final List<String> tags;
  final int likes;
  final int downloads;
  final bool isPremium;
  final bool isAnime;
  final String? animeCharacter;
  final DateTime createdAt;
  final bool isApproved;

  Wallpaper({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    this.categories = const [],
    this.tags = const [],
    this.likes = 0,
    this.downloads = 0,
    this.isPremium = false,
    this.isAnime = false,
    this.animeCharacter,
    required this.createdAt,
    this.isApproved = false,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      likes: json['likes'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
      isAnime: json['isAnime'] as bool? ?? false,
      animeCharacter: json['animeCharacter'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'authorId': authorId,
      'authorName': authorName,
      'categories': categories,
      'tags': tags,
      'likes': likes,
      'downloads': downloads,
      'isPremium': isPremium,
      'isAnime': isAnime,
      'animeCharacter': animeCharacter,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
    };
  }

  Wallpaper copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? thumbnailUrl,
    String? authorId,
    String? authorName,
    List<String>? categories,
    List<String>? tags,
    int? likes,
    int? downloads,
    bool? isPremium,
    bool? isAnime,
    String? animeCharacter,
    DateTime? createdAt,
    bool? isApproved,
  }) {
    return Wallpaper(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      downloads: downloads ?? this.downloads,
      isPremium: isPremium ?? this.isPremium,
      isAnime: isAnime ?? this.isAnime,
      animeCharacter: animeCharacter ?? this.animeCharacter,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
