import 'dart:async';
import 'dart:convert';
import 'package:app_wallpaper/providers/wallpaper_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class BoolWrapper {
  bool value;
  BoolWrapper(this.value);
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _token;
  bool _isLoggedIn = false;
  String? errormsg;
  Map<String, dynamic>? userData;
  String? _email;
  InterstitialAd? _interstitialAd;
  Timer? _adTimer;
  bool ispre = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  void initialize() {
    _startAdTimer();
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if(_currentUser!.isPremium == false){
        _loadAndShowInterstitialAd();
      }
    });
  }

  void _loadAndShowInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Replace with real ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void dispose() {
    _adTimer?.cancel();
    _interstitialAd?.dispose();
  }
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

    const String apiUrl = 'http://10.0.2.2/testwallpapering/postuser.php'; // Replace with your API endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data is Map && data['success'] == true) {
            print('Registered User: $data');
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            print('API Error: $data');
          }
        } catch (e) {
          print('JSON Parse Error: $e');
          print('Raw Response: ${response.body}');
        }
      } else {
        print('Server Error: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Connection Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    errormsg = null;
    notifyListeners();
    final Uri apiUrl = Uri.parse(
        'http://10.0.2.2/testwallpapering/getuser.php?email=$email&password=$password');
    // Change 'localhost' to your server IP when testing on mobile

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login Success: $data');

        final user = User(
          id: data['user_id'].toString(),
          username: data['username'],
          email: data['email'],
          isPremium: data['Premium']!= 0
        );
        _currentUser = user;
        _isLoggedIn = true;
        _isLoading = false;
        await _saveUserToPrefs();

        return true;
      } else {
        final data = jsonDecode(response.body);
        errormsg = data['error'] ?? 'Login failed.';
        print('Login Failed: $errormsg');
      }
    } catch (e) {
      errormsg = 'Network error occurred.';
      print('Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> resetPassword({required String email, required BoolWrapper success}) async {
    _email = email;
    final Uri apiUrl = Uri.parse(
        'http://10.0.2.2/testwallpapering/sendresetemail.php'); // Adjust URL as needed
    final int token = Random().nextInt(100);
    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token}),
      );

      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _isLoading = false;
          success.value = true;
          notifyListeners();
        } else {
          print('Failed to send email: ${data['error']}');
          success.value = false;
        }
      } else {
        print('Server error: ${response.statusCode}');
        success.value = false;
      }
    } catch (e) {
      print('Network error: $e');
      success.value = false;
    }


    final url = Uri.parse('http://10.0.2.2/testwallpapering/ifverify.php?email=$email&token=$token');

    const int maxRetries = 30; // Max 30 attempts
    const Duration delayBetweenRetries = Duration(seconds: 2); // 2s interval

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['verified'] == true) {
          final a = await http.post(
            Uri.parse('http://10.0.2.2/testwallpapering/falseagain.php?email=$email&com&token=$token')
          );
          print('Response: ${a.body}');
          if(jsonDecode(a.body)['success'] == true) return true;
        } else {
          print('Still not verified. Attempt ${attempt + 1}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }

      // Wait before next poll
      await Future.delayed(delayBetweenRetries);
    }

    print('Verification timed out. Please try again later.');
    return false;
  }

  Future<bool> confirmResetPassword({
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      print(newPassword);

      // Assume you have saved the email & token from earlier (or pass them as params)
      final String email = _email ?? '';

      final response = await http.post(
        Uri.parse('http://10.0.2.2/testwallpapering/reset_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return true;  // Password reset successful
        } else {
          print('Reset failed: ${data['error']}');
          return false;
        }
      } else {
        print('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error in confirmResetPassword: $e');
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
