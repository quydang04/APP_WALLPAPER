import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // Watch a video to progress towards unlocking premium content
  void watchVideo() {
    if (_watchedVideos < _requiredVideosToUnlock) {
      _watchedVideos++;
      notifyListeners();
    }
  }

  // Reset watched videos counter
  void resetWatchedVideos() {
    _watchedVideos = 0;
    notifyListeners();
  }

  // Unlock a wallpaper after watching required videos
  bool unlockWallpaper(String wallpaperId) {
    if (_watchedVideos >= _requiredVideosToUnlock) {
      _unlockedWallpapers[wallpaperId] = true;
      resetWatchedVideos();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Check if user can access premium wallpaper
  bool canAccessPremiumWallpaper(String wallpaperId, User? user) {
    // User is premium subscriber
    if (user != null && user.isPremium) {
      return true;
    }

    // Wallpaper is unlocked via watching videos
    if (isWallpaperUnlocked(wallpaperId)) {
      return true;
    }

    return false;
  }

  // Simulate purchase of premium subscription
  Future<bool> purchasePremium(User user, Function(User) updateUser) async {
    try {
      // This would be an actual payment processing in a real app
      await Future.delayed(const Duration(seconds: 1));
      String ID = user.id;
      final Uri apiUrl = Uri.parse(
        'http://10.0.2.2/testwallpapering/gopremium.php?user_id=$ID',
      );
      // Update user with premium status
      await http.post(apiUrl);
      final updatedUser = user.copyWith(isPremium: true);
      updateUser(updatedUser);

      return true;
    } catch (e) {
      debugPrint('Error purchasing premium: $e');
      return false;
    }
  }

  // Calculate progress percentage towards unlocking content
  double get unlockProgressPercentage {
    return _watchedVideos / _requiredVideosToUnlock;
  }
}
