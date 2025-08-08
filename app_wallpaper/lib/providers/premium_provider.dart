import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class PremiumProvider with ChangeNotifier {
  int _watchedVideos = 0;
  final int _requiredVideosToUnlock = 5;
  final Map<String, bool> _unlockedWallpapers = {};

  int get watchedVideos => _watchedVideos;
  int get requiredVideosToUnlock => _requiredVideosToUnlock;
  Map<String, bool> get unlockedWallpapers => _unlockedWallpapers;

  bool isWallpaperUnlocked(String wallpaperId) {
    return _unlockedWallpapers[wallpaperId] ?? false;
  }

  void watchVideo() {
    if (_watchedVideos < _requiredVideosToUnlock) {
      _watchedVideos++;
      notifyListeners();
    }
  }

  void resetWatchedVideos() {
    _watchedVideos = 0;
    notifyListeners();
  }

  bool unlockWallpaper(String wallpaperId) {
    if (_watchedVideos >= _requiredVideosToUnlock) {
      _unlockedWallpapers[wallpaperId] = true;
      resetWatchedVideos();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool canAccessPremiumWallpaper(String wallpaperId, User? user) {
    if (user != null && user.isPremium) return true;
    if (isWallpaperUnlocked(wallpaperId)) return true;
    return false;
  }

  Future<bool> purchasePremium(User user, Function(User) updateUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'isPremium': true});

      final updatedUser = user.copyWith(isPremium: true);
      updateUser(updatedUser);

      return true;
    } catch (e) {
      debugPrint('Error purchasing premium (Firestore): $e');
      return false;
    }
  }

  double get unlockProgressPercentage {
    return _watchedVideos / _requiredVideosToUnlock;
  }
}
