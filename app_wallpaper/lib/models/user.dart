class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final bool isPremium;
  final List<String> favoriteTopics;
  final List<String> uploadedPhotos;
  final int balance;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.isPremium = false,
    this.favoriteTopics = const [],
    this.uploadedPhotos = const [],
    this.balance = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      favoriteTopics:
          (json['favoriteTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      uploadedPhotos:
          (json['uploadedPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      balance: json['balance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isPremium': isPremium,
      'favoriteTopics': favoriteTopics,
      'uploadedPhotos': uploadedPhotos,
      'balance': balance,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImageUrl,
    bool? isPremium,
    List<String>? favoriteTopics,
    List<String>? uploadedPhotos,
    int? balance,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPremium: isPremium ?? this.isPremium,
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      uploadedPhotos: uploadedPhotos ?? this.uploadedPhotos,
      balance: balance ?? this.balance,
    );
  }
}
