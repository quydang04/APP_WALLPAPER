import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.prefKeyUser);
      final token = prefs.getString(AppConstants.prefKeyToken);
      final isLoggedIn = prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;

      if (userJson != null && token != null && isLoggedIn) {
        _currentUser = User.fromJson(json.decode(userJson));
        _token = token;
        _isLoggedIn = true;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      // For now, we'll simulate a successful registration

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
      );

      _currentUser = newUser;
      _token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      _isLoggedIn = true;

      // Save to SharedPreferences
      await _saveUserToPrefs();

      return true;
    } catch (e) {
      debugPrint('Error registering: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      // For now, we'll simulate a successful login

      final user = User(
        id: '1',
        username: 'user_${email.split('@')[0]}',
        email: email,
      );

      _currentUser = user;
      _token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      _isLoggedIn = true;

      // Save to SharedPreferences
      await _saveUserToPrefs();

      return true;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      // For now, we'll simulate a successful password reset
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = null;
      _token = null;
      _isLoggedIn = false;

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyUser);
      await prefs.remove(AppConstants.prefKeyToken);
      await prefs.setBool(AppConstants.prefKeyIsLoggedIn, false);
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      _currentUser = updatedUser;

      // Save to SharedPreferences
      await _saveUserToPrefs();
    } catch (e) {
      debugPrint('Error updating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs() async {
    if (_currentUser != null && _token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.prefKeyUser,
        json.encode(_currentUser!.toJson()),
      );
      await prefs.setString(AppConstants.prefKeyToken, _token!);
      await prefs.setBool(AppConstants.prefKeyIsLoggedIn, _isLoggedIn);
    }
  }
}
