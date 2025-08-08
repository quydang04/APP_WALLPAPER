import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper.dart';
import '../models/category.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'dart:async';

class WallpaperProvider with ChangeNotifier {
  List<Wallpaper> _wallpapers = [];
  List<Wallpaper> _downloadedWallpapers = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategoryId;

  List<Wallpaper> get wallpapers => _wallpapers;
  List<Wallpaper> get downloadedWallpapers => _downloadedWallpapers;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  // Filtered wallpapers based on search and category
  List<Wallpaper> get filteredWallpapers {
    if (_searchQuery.isEmpty && _selectedCategoryId == null) {
      return _wallpapers;
    }

    return _wallpapers.where((wallpaper) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          wallpaper.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          wallpaper.tags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      bool matchesCategory =
          _selectedCategoryId == null ||
          wallpaper.categories.contains(_selectedCategoryId);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Get wallpapers by category
  List<Wallpaper> getWallpapersByCategory(String categoryId) {
    return _wallpapers
        .where((wallpaper) => wallpaper.categories.contains(categoryId))
        .toList();
  }

  // Get anime wallpapers
  List<Wallpaper> get animeWallpapers {
    return _wallpapers.where((wallpaper) => wallpaper.isAnime).toList();
  }

  // Get premium wallpapers
  List<Wallpaper> get premiumWallpapers {
    return _wallpapers.where((wallpaper) => wallpaper.isPremium).toList();
  }

  // Get popular wallpapers
  List<Wallpaper> get popularWallpapers {
    final sorted = List<Wallpaper>.from(_wallpapers);
    sorted.sort((a, b) => b.likes.compareTo(a.likes));
    return sorted.take(10).toList();
  }

  // Get recent wallpapers
  List<Wallpaper> get recentWallpapers {
    final sorted = List<Wallpaper>.from(_wallpapers);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    print(sorted[0].title);
    return sorted.take(10).toList();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // Fetch wallpapers
  Future<void> fetchWallpapers(bool premi) async {
    _wallpapers = _generateMockWallpapers();
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse(
      'http://10.0.2.2/testwallpapering/get_wallpapers.php',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final List wallpapersData = data['data']; // <-- Access the List

          for (var entry in wallpapersData) {
            Wallpaper g = Wallpaper(
              id: entry['img_id'].toString(),
              title: entry['image_title'] ?? '',
              imageUrl: entry['link'] ?? '',
              thumbnailUrl: null,
              authorId: entry['authorId'].toString(),
              authorName: entry['authorName'] ?? '',
              categories: [entry['cat_id'].toString()],
              tags: (entry['tags'] as String)
                  .split(',')
                  .map((tag) => tag.trim())
                  .toList(),
              likes: int.parse(entry['likes']), // Placeholder if not in DB yet
              downloads: 0, // Placeholder if not in DB yet
              isPremium: entry['premium'] == '1',
              isAnime: entry['isAnime'] == '1',
              animeCharacter: entry['animecharacter'] == '1'
                  ? 'Anime Character Name'
                  : null,
              createdAt: DateTime.parse(entry['createdAt']),
              isApproved: entry['isApproved'] == '1',
            );
            _wallpapers.add(g);
          }
        } else {
          print('API returned failure status');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      print('Error occurred: $e');
      await Future.delayed(const Duration(seconds: 1));

      // Load downloaded wallpapers from SharedPreferences
      await _loadDownloadedWallpapers();
      debugPrint('Error fetching wallpapers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      // For now, we'll simulate fetching data
      await Future.delayed(const Duration(seconds: 1));

      // Mock categories based on AppConstants.defaultCategories
      _categories = AppConstants.defaultCategories.map((categoryData) {
        return Category(
          id: categoryData['name']!.toLowerCase().replaceAll(' ', '_'),
          name: categoryData['name']!,
          description: categoryData['description'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestStoragePermission() async {
    print("dsg");
    var status = await perm.Permission.manageExternalStorage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await perm.openAppSettings(); // Ask user to enable manually
      return false;
    } else {
      // User tapped "Deny"
      return false;
    }
  }

  // Download wallpaper
  Future<bool> downloadWallpaper(Wallpaper wallpaper) async {
    try {
      // Request permission
      bool granted = await requestStoragePermission();
      if (!granted) {
        print('Permission denied');
        return false;
      }

      try {
        // Get device directory (Downloads on Android)
        Directory? dir;
        if (Platform.isAndroid) {
          dir = Directory(
            '/storage/emulated/0/Download',
          ); // Common downloads folder
        } else {
          dir = await getApplicationDocumentsDirectory(); // iOS fallback
        }
        String filename = '${wallpaper.title}.jpg';
        String fullPath = '${dir.path}/$filename';

        // Download image
        Dio dio = Dio();
        await dio.download(wallpaper.imageUrl, fullPath);
        String id = wallpaper.id;
        await http.post(
          Uri.parse('http://10.0.2.2/testwallpapering/postdl.php?img_id=$id'),
        );

        print('Image saved to $fullPath');
        if (!_downloadedWallpapers.any((w) => w.id == wallpaper.id)) {
          _downloadedWallpapers.add(wallpaper);
          await _saveDownloadedWallpapers();
          notifyListeners();
        }
        return true;
      } catch (e) {
        print('Error saving image: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error downloading wallpaper: $e');
      return false;
    }
  }

  // Like wallpaper
  Future<bool> likeWallpaper(String wallpaperId) async {
    try {
      final index = _wallpapers.indexWhere((w) => w.id == wallpaperId);
      if (index != -1) {
        await http.post(
          Uri.parse(
            'http://10.0.2.2/testwallpapering/like.php?img_id=$wallpaperId',
          ),
        );
        _isLoading = false;
      }
      return true;
    } catch (e) {
      debugPrint('Error liking wallpaper: $e');
      return false;
    }
  }

  // Upload wallpaper
  Future<bool> uploadWallpaper(Wallpaper wallpaperee, bool premi) async {
    print(path.basename(wallpaperee.imageUrl));
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> jsonBody = {
      "img_id": wallpaperee.id,
      "image_title": wallpaperee.title,
      "description": "", // Add actual description if needed
      "animecharacter": wallpaperee.animeCharacter,
      "premium": wallpaperee.isPremium,
      "cat_id": 1,
      "authorId": wallpaperee.authorId,
      "authorName": wallpaperee.authorName,
      "link":
          "http://10.0.2.2/testwallpapering/sdf/${path.basename(wallpaperee.imageUrl)}",
      "tags": wallpaperee.tags.join(','), // CSV string if needed
      "isAnime": wallpaperee.isAnime,
      "createdAt": wallpaperee.createdAt.toIso8601String(),
      "isApproved": wallpaperee.isApproved,
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2/testwallpapering/upload.php'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        wallpaperee.imageUrl,
        filename: path.basename(wallpaperee.imageUrl),
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }

    final Uri apiUrl = Uri.parse(
      'http://10.0.2.2/testwallpapering/upload_wallpaper.php',
    );

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody),
      );

      if (response.statusCode == 200) {
        print('Wallpaper uploaded successfully!');
        print('Response: ${response.body}');
      } else {
        print('Failed to upload wallpaper. Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
      await Future.delayed(const Duration(seconds: 1));

      notifyListeners();
      fetchWallpapers(premi);
      return true;
    } catch (e) {
      debugPrint('Error uploading wallpaper: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load downloaded wallpapers from SharedPreferences
  Future<void> _loadDownloadedWallpapers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wallpapersJson = prefs.getString(
        AppConstants.prefKeyDownloadedWallpapers,
      );

      if (wallpapersJson != null) {
        final List<dynamic> decodedList = json.decode(wallpapersJson);
        _downloadedWallpapers = decodedList
            .map((item) => Wallpaper.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading downloaded wallpapers: $e');
    }
  }

  // Save downloaded wallpapers to SharedPreferences
  Future<void> _saveDownloadedWallpapers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wallpapersJson = json.encode(
        _downloadedWallpapers.map((w) => w.toJson()).toList(),
      );
      await prefs.setString(
        AppConstants.prefKeyDownloadedWallpapers,
        wallpapersJson,
      );
    } catch (e) {
      debugPrint('Error saving downloaded wallpapers: $e');
    }
  }

  // Generate mock wallpapers for demo
  List<Wallpaper> _generateMockWallpapers() {
    final List<Wallpaper> mockWallpapers = [];

    // Sample image URLs (in a real app, these would be actual URLs)
    final List<String> sampleImageUrls = [
      'https://example.com/wallpaper1.jpg',
      'https://example.com/wallpaper2.jpg',
      'https://example.com/wallpaper3.jpg',
      'https://example.com/wallpaper4.jpg',
      'https://example.com/wallpaper5.jpg',
    ];

    // Sample categories
    final List<String> categoryIds = AppConstants.defaultCategories
        .map((c) => c['name']!.toLowerCase().replaceAll(' ', '_'))
        .toList();

    // Sample anime characters
    final List<String> animeCharacters = AppConstants.animeCharacters;

    // Generate 20 mock wallpapers
    for (int i = 0; i < 20; i++) {
      final bool isAnime = i % 3 == 0; // Every third wallpaper is anime
      final bool isPremium = i % 5 == 0; // Every fifth wallpaper is premium

      // Randomly select categories (1-3 per wallpaper)
      final List<String> wallpaperCategories = [];
      final int numCategories = 1 + (i % 3); // 1-3 categories
      for (int j = 0; j < numCategories; j++) {
        final String categoryId = categoryIds[(i + j) % categoryIds.length];
        if (!wallpaperCategories.contains(categoryId)) {
          wallpaperCategories.add(categoryId);
        }
      }

      // Add 'anime' category if it's an anime wallpaper
      if (isAnime && !wallpaperCategories.contains('anime')) {
        wallpaperCategories.add('anime');
      }

      // Create tags
      final List<String> tags = [...wallpaperCategories];
      if (isAnime) {
        final String character = animeCharacters[i % animeCharacters.length];
        tags.add(character.toLowerCase());
      }

      // Create the wallpaper
      final wallpaper = Wallpaper(
        id: 'wallpaper_$i',
        title: isAnime
            ? '${animeCharacters[i % animeCharacters.length]} Wallpaper'
            : 'Wallpaper ${i + 1}',
        imageUrl: sampleImageUrls[i % sampleImageUrls.length],
        authorId: 'author_${i % 5}',
        authorName: 'Artist ${i % 5}',
        categories: wallpaperCategories,
        tags: tags,
        likes: i * 10 + (i % 7) * 5,
        downloads: i * 5 + (i % 3) * 2,
        isPremium: isPremium,
        isAnime: isAnime,
        animeCharacter: isAnime
            ? animeCharacters[i % animeCharacters.length]
            : null,
        createdAt: DateTime.now().subtract(Duration(days: i)),
        isApproved: true,
      );

      mockWallpapers.add(wallpaper);
    }

    return mockWallpapers;
  }
}
