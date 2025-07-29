import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper.dart';
import '../models/category.dart';
import '../constants/app_constants.dart';

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
  Future<void> fetchWallpapers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      // For now, we'll simulate fetching data
      await Future.delayed(const Duration(seconds: 1));

      // Mock wallpapers
      _wallpapers = _generateMockWallpapers();

      // Load downloaded wallpapers from SharedPreferences
      await _loadDownloadedWallpapers();
    } catch (e) {
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

  // Download wallpaper
  Future<bool> downloadWallpaper(Wallpaper wallpaper) async {
    try {
      // Add to downloaded wallpapers if not already there
      if (!_downloadedWallpapers.any((w) => w.id == wallpaper.id)) {
        _downloadedWallpapers.add(wallpaper);
        await _saveDownloadedWallpapers();
        notifyListeners();
      }
      return true;
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
        final updatedWallpaper = _wallpapers[index].copyWith(
          likes: _wallpapers[index].likes + 1,
        );
        _wallpapers[index] = updatedWallpaper;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error liking wallpaper: $e');
      return false;
    }
  }

  // Upload wallpaper
  Future<bool> uploadWallpaper(Wallpaper wallpaper) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      // For now, we'll simulate uploading
      await Future.delayed(const Duration(seconds: 1));

      _wallpapers.add(wallpaper);
      notifyListeners();
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
