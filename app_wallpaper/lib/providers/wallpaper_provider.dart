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

  List<Wallpaper> get filteredWallpapers {
    if (_searchQuery.isEmpty && _selectedCategoryId == null) {
      return _wallpapers;
    }

    return _wallpapers.where((wallpaper) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
              wallpaper.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              wallpaper.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      bool matchesCategory =
          _selectedCategoryId == null ||
              wallpaper.categories.contains(_selectedCategoryId);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Wallpaper> getWallpapersByCategory(String categoryId) {
    return _wallpapers.where((wallpaper) => wallpaper.categories.contains(categoryId)).toList();
  }

  List<Wallpaper> get animeWallpapers => _wallpapers.where((wallpaper) => wallpaper.isAnime).toList();
  List<Wallpaper> get premiumWallpapers => _wallpapers.where((wallpaper) => wallpaper.isPremium).toList();

  List<Wallpaper> get popularWallpapers {
    final sorted = List<Wallpaper>.from(_wallpapers);
    sorted.sort((a, b) => b.likes.compareTo(a.likes));
    return sorted.take(10).toList();
  }

  List<Wallpaper> get recentWallpapers {
    final sorted = List<Wallpaper>.from(_wallpapers);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> fetchWallpapers(bool premi) async {
    _wallpapers = _generateMockWallpapers();
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('http://10.0.2.2/testwallpapering/get_wallpapers.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List wallpapersData = data['data'];
          for (var entry in wallpapersData) {
            Wallpaper g = Wallpaper(
              id: entry['img_id'].toString(),
              title: entry['image_title'] ?? '',
              imageUrl: entry['link'] ?? '',
              thumbnailUrl: null,
              authorId: entry['authorId'].toString(),
              authorName: entry['authorName'] ?? '',
              categories: [entry['cat_id'].toString()],
              tags: (entry['tags'] as String).split(',').map((tag) => tag.trim()).toList(),
              likes: int.parse(entry['likes']),
              downloads: 0,
              isPremium: entry['premium'] == '1',
              isAnime: entry['isAnime'] == '1',
              animeCharacter: entry['animecharacter'] == '1' ? 'Anime Character Name' : null,
              createdAt: DateTime.parse(entry['createdAt']),
              isApproved: entry['isApproved'] == '1',
            );
            _wallpapers.add(g);
          }
        }
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      await _loadDownloadedWallpapers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _categories = AppConstants.defaultCategories.map((categoryData) {
        return Category(
          id: categoryData['name']!.toLowerCase().replaceAll(' ', '_'),
          name: categoryData['name']!,
          description: categoryData['description'],
        );
      }).toList();
    } catch (e) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestStoragePermission() async {
    var status = await perm.Permission.manageExternalStorage.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await perm.openAppSettings();
      return false;
    } else {
      return false;
    }
  }

  Future<bool> downloadWallpaper(Wallpaper wallpaper) async {
    try {
      bool granted = await requestStoragePermission();
      if (!granted) return false;

      try {
        Directory? dir;
        if (Platform.isAndroid) {
          dir = Directory('/storage/emulated/0/Download');
        } else {
          dir = await getApplicationDocumentsDirectory();
        }

        String filename = '${wallpaper.title}.jpg';
        String fullPath = '${dir.path}/$filename';
        Dio dio = Dio();
        await dio.download(wallpaper.imageUrl, fullPath);

        String id = wallpaper.id;
        await http.post(Uri.parse('http://10.0.2.2/testwallpapering/postdl.php?img_id=$id'));

        if (!_downloadedWallpapers.any((w) => w.id == wallpaper.id)) {
          _downloadedWallpapers.add(wallpaper);
          await _saveDownloadedWallpapers();
          notifyListeners();
        }

        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> likeWallpaper(String wallpaperId) async {
    try {
      final index = _wallpapers.indexWhere((w) => w.id == wallpaperId);
      if (index != -1) {
        await http.post(Uri.parse('http://10.0.2.2/testwallpapering/like.php?img_id=$wallpaperId'));
        _isLoading = false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadWallpaper(Wallpaper wallpaperee, bool premi) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> jsonBody = {
      "img_id": wallpaperee.id,
      "image_title": wallpaperee.title,
      "description": "",
      "animecharacter": wallpaperee.animeCharacter,
      "premium": wallpaperee.isPremium,
      "cat_id": 1,
      "authorId": wallpaperee.authorId,
      "authorName": wallpaperee.authorName,
      "link": "http://10.0.2.2/testwallpapering/sdf/${path.basename(wallpaperee.imageUrl)}",
      "tags": wallpaperee.tags.join(','),
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

    final Uri apiUrl = Uri.parse('http://10.0.2.2/testwallpapering/upload_wallpaper.php');

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody),
      );

      await Future.delayed(const Duration(seconds: 1));
      notifyListeners();
      fetchWallpapers(premi);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDownloadedWallpapers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wallpapersJson = prefs.getString(AppConstants.prefKeyDownloadedWallpapers);

      if (wallpapersJson != null) {
        final List<dynamic> decodedList = json.decode(wallpapersJson);
        _downloadedWallpapers = decodedList.map((item) => Wallpaper.fromJson(item)).toList();
      }
    } catch (e) {}
  }

  Future<void> _saveDownloadedWallpapers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wallpapersJson = json.encode(
        _downloadedWallpapers.map((w) => w.toJson()).toList(),
      );
      await prefs.setString(AppConstants.prefKeyDownloadedWallpapers, wallpapersJson);
    } catch (e) {}
  }

  List<Wallpaper> _generateMockWallpapers() {
    final List<Wallpaper> mockWallpapers = [];
    final List<String> sampleImageUrls = [
      'https://example.com/wallpaper1.jpg',
      'https://example.com/wallpaper2.jpg',
      'https://example.com/wallpaper3.jpg',
      'https://example.com/wallpaper4.jpg',
      'https://example.com/wallpaper5.jpg',
    ];

    final List<String> categoryIds = AppConstants.defaultCategories
        .map((c) => c['name']!.toLowerCase().replaceAll(' ', '_'))
        .toList();

    final List<String> animeCharacters = AppConstants.animeCharacters;

    for (int i = 0; i < 20; i++) {
      final bool isAnime = i % 3 == 0;
      final bool isPremium = i % 5 == 0;
      final List<String> wallpaperCategories = [];
      final int numCategories = 1 + (i % 3);
      for (int j = 0; j < numCategories; j++) {
        final String categoryId = categoryIds[(i + j) % categoryIds.length];
        if (!wallpaperCategories.contains(categoryId)) {
          wallpaperCategories.add(categoryId);
        }
      }

      if (isAnime && !wallpaperCategories.contains('anime')) {
        wallpaperCategories.add('anime');
      }

      final List<String> tags = [...wallpaperCategories];
      if (isAnime) {
        final String character = animeCharacters[i % animeCharacters.length];
        tags.add(character.toLowerCase());
      }

      final wallpaper = Wallpaper(
        id: 'wallpaper_$i',
        title: isAnime ? '${animeCharacters[i % animeCharacters.length]} Wallpaper' : 'Wallpaper ${i + 1}',
        imageUrl: sampleImageUrls[i % sampleImageUrls.length],
        authorId: 'author_${i % 5}',
        authorName: 'Artist ${i % 5}',
        categories: wallpaperCategories,
        tags: tags,
        likes: i * 10 + (i % 7) * 5,
        downloads: i * 5 + (i % 3) * 2,
        isPremium: isPremium,
        isAnime: isAnime,
        animeCharacter: isAnime ? animeCharacters[i % animeCharacters.length] : null,
        createdAt: DateTime.now().subtract(Duration(days: i)),
        isApproved: true,
      );

      mockWallpapers.add(wallpaper);
    }

    return mockWallpapers;
  }
}
