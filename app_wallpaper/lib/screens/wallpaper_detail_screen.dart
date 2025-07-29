import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_theme.dart';
import '../models/wallpaper.dart';
import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/custom_button.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final String wallpaperId;

  const WallpaperDetailScreen({Key? key, required this.wallpaperId})
    : super(key: key);

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  bool _isLiked = false;
  bool _isDownloading = false;
  bool _showInfo = true;

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final premiumProvider = Provider.of<PremiumProvider>(context);

    // Find the wallpaper by ID
    final wallpaper = wallpaperProvider.wallpapers.firstWhere(
      (w) => w.id == widget.wallpaperId,
      orElse: () => Wallpaper(
        id: 'not_found',
        title: 'Wallpaper Not Found',
        imageUrl: '',
        authorId: '',
        authorName: '',
        createdAt: DateTime.now(),
      ),
    );

    // Check if wallpaper is accessible
    final bool isPremiumAccessible = premiumProvider.canAccessPremiumWallpaper(
      wallpaper.id,
      authProvider.currentUser,
    );

    final bool canDownload = !wallpaper.isPremium || isPremiumAccessible;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              wallpaperProvider.likeWallpaper(wallpaper.id);
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Colors.white),
            ),
            onPressed: () {
              // Share functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing is not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: wallpaper.id == 'not_found'
          ? const Center(child: Text('Wallpaper not found'))
          : Stack(
              fit: StackFit.expand,
              children: [
                // Wallpaper image
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showInfo = !_showInfo;
                    });
                  },
                  child: Hero(
                    tag: 'wallpaper_${wallpaper.id}',
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),

                // Premium overlay if needed
                if (wallpaper.isPremium && !isPremiumAccessible)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, color: Colors.white, size: 60),
                          const SizedBox(height: 16),
                          const Text(
                            'Premium Wallpaper',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Subscribe to Premium or watch videos to unlock',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                text: 'Go Premium',
                                onPressed: () {
                                  context.push('/premium');
                                },
                                backgroundColor: AppTheme.accentColor,
                                width: 150,
                              ),
                              const SizedBox(width: 16),
                              CustomButton(
                                text: 'Watch Videos',
                                onPressed: () {
                                  // Show video ad dialog
                                  _showVideoAdDialog(
                                    context,
                                    premiumProvider,
                                    wallpaper,
                                  );
                                },
                                isOutlined: true,
                                textColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                width: 150,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom info panel
                if (_showInfo)
                  Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            wallpaper.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'By ${wallpaper.authorName}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (wallpaper.isPremium)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'PREMIUM',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildInfoChip(
                                      icon: Icons.favorite,
                                      label: '${wallpaper.likes}',
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildInfoChip(
                                      icon: Icons.download,
                                      label: '${wallpaper.downloads}',
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 16),
                                    if (wallpaper.isAnime &&
                                        wallpaper.animeCharacter != null)
                                      _buildInfoChip(
                                        icon: Icons.person,
                                        label: wallpaper.animeCharacter!,
                                        color: Colors.purple,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: canDownload
                                      ? 'Download Wallpaper'
                                      : 'Premium Content',
                                  onPressed: canDownload
                                      ? () => _downloadWallpaper(wallpaper)
                                      : () {}, // Empty function instead of null
                                  isLoading: _isDownloading,
                                  backgroundColor: canDownload
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                  prefixIcon: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 300))
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: const Duration(milliseconds: 300),
                      ),
              ],
            ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadWallpaper(Wallpaper wallpaper) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final wallpaperProvider = Provider.of<WallpaperProvider>(
        context,
        listen: false,
      );
      final success = await wallpaperProvider.downloadWallpaper(wallpaper);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Wallpaper downloaded successfully'
                  : 'Failed to download wallpaper',
            ),
            backgroundColor: success
                ? AppTheme.successColor
                : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showVideoAdDialog(
    BuildContext context,
    PremiumProvider premiumProvider,
    Wallpaper wallpaper,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Watch Video Ads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Watch ${premiumProvider.requiredVideosToUnlock} video ads to unlock this premium wallpaper.',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: premiumProvider.unlockProgressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: ${premiumProvider.watchedVideos}/${premiumProvider.requiredVideosToUnlock}',
              style: AppTheme.captionStyle,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simulate watching a video ad
              premiumProvider.watchVideo();

              // Check if enough videos have been watched
              if (premiumProvider.watchedVideos >=
                  premiumProvider.requiredVideosToUnlock) {
                premiumProvider.unlockWallpaper(wallpaper.id);
                Navigator.of(context).pop();

                // Refresh the screen
                setState(() {});
              } else {
                // Show progress
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Video ${premiumProvider.watchedVideos}/${premiumProvider.requiredVideosToUnlock} watched',
                    ),
                  ),
                );
              }
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }
}
