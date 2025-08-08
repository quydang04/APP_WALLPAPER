import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';

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
  InterstitialAd? _interstitialAd;
  Timer? _adTimer;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;

  void initialize() {
    _startAdTimer();
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      if (_currentUser != null && !_currentUser!.isPremium) {
        _loadAndShowInterstitialAd();
      }
    });
  }

  void _loadAndShowInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Replace with real Ad ID
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
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
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
    errormsg = null;
    notifyListeners();

    try {
      final fb_auth.UserCredential userCredential =
      await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      _currentUser = User(
        id: userCredential.user!.uid,
        username: username,
        email: email,
        isPremium: false,
      );

      _token = await userCredential.user!.getIdToken();
      _isLoggedIn = true;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'isPremium': false,
      });

      await _saveUserToPrefs();

      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      errormsg = e.message;
      debugPrint("FirebaseAuthException [register]: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      errormsg = 'Unexpected error.';
      debugPrint("Unexpected Error [register]: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    errormsg = null;
    notifyListeners();

    try {
      final userCredential = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final data = doc.data() ?? {};

      _currentUser = User(
        id: userCredential.user!.uid,
        username: data['username'] ?? 'Unknown',
        email: email,
        isPremium: data['isPremium'] ?? false,
      );

      _token = await userCredential.user!.getIdToken();
      _isLoggedIn = true;

      await _saveUserToPrefs();

      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      errormsg = e.message;
      debugPrint("FirebaseAuthException [login]: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      errormsg = 'Unexpected error.';
      debugPrint("Unexpected Error [login]: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required BoolWrapper success,
  }) async {
    try {
      await fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      success.value = true;
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      errormsg = e.message;
      debugPrint("FirebaseAuthException [resetPassword]: ${e.code} - ${e.message}");
      success.value = false;
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await fb_auth.FirebaseAuth.instance.signOut();

      _currentUser = null;
      _token = null;
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyUser);
      await prefs.remove(AppConstants.prefKeyToken);
      await prefs.setBool(AppConstants.prefKeyIsLoggedIn, false);
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: fb_auth.ActionCodeSettings(
          url: 'https://appwallpaper.page.link/reset',
          handleCodeInApp: true,
          androidPackageName: 'hiouuhuu.ii.l',
          androidInstallApp: true,
          androidMinimumVersion: '23',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error sending reset email: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmResetPassword({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(code: oobCode, newPassword: newPassword);
      return true;
    } catch (e) {
      debugPrint('Password reset failed: $e');
      return false;
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = updatedUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());

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
