class AppConstants {
  // App info
  static const String appName = "Anime Wallpapers";
  static const String appVersion = "1.0.0";

  // Routes
  static const String routeHome = "/";
  static const String routeLogin = "/login";
  static const String routeRegister = "/register";
  static const String routeForgotPassword = "/forgot-password";
  static const String routeResetPassword = "/reset-password";
  static const String routeProfile = "/profile";
  static const String routeWallpaperDetail = "/wallpaper/:id";
  static const String routeCategory = "/category/:id";
  static const String routeSearch = "/search";
  static const String routeUpload = "/upload";
  static const String routePremium = "/premium";
  static const String routeSettings = "/settings";
  static const String routestock =
      "C:/Users/admin/Downloads/APP_WALLPAPER-main/uploads";

  // Shared Preferences Keys
  static const String prefKeyUser = "user";
  static const String prefKeyToken = "token";
  static const String prefKeyIsLoggedIn = "isLoggedIn";
  static const String prefKeyIsDarkMode = "isDarkMode";
  static const String prefKeyDownloadedWallpapers = "downloadedWallpapers";

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);

  // Ad related
  static const int adIntervalMinutes = 10;
  static const int videosToUnlockWallpaper = 5;

  // Premium features
  static const double premiumPrice = 4.99;
  static const int likesForReward = 1500;
  static const double rewardAmount = 5.0;

  // Default categories
  static final List<Map<String, String>> defaultCategories = [
    {'name': 'Popular', 'description': 'Most popular wallpapers'},
    {'name': 'New', 'description': 'Latest wallpapers'},
    {'name': 'Anime', 'description': 'Anime themed wallpapers'},
    {'name': 'Fantasy', 'description': 'Fantasy themed wallpapers'},
    {'name': 'Abstract', 'description': 'Abstract art wallpapers'},
    {'name': 'Nature', 'description': 'Nature themed wallpapers'},
    {'name': 'Dark', 'description': 'Dark themed wallpapers'},
    {'name': 'Minimal', 'description': 'Minimalist wallpapers'},
  ];

  // Anime characters
  static final List<String> animeCharacters = [
    'Shinji',
    'Ichigo'
        'Naruto',
    'Sasuke',
    'Luffy',
    'Goku',
    'Saitama',
    'Mikasa',
    'Eren',
    'Levi',
    'Tanjiro',
    'Nezuko',
    'Gojo',
    'Sukuna',
  ];
}
