import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/wallpaper.dart';
import '../constants/app_theme.dart';

class WallpaperCard extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool isInGrid;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const WallpaperCard({
    Key? key,
    required this.wallpaper,
    this.onTap,
    this.showDetails = true,
    this.isInGrid = true,
    this.height,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(16);

    return GestureDetector(
      onTap:
          onTap ??
          () {
            context.push('/wallpaper/${wallpaper.id}');
          },
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: cardBorderRadius,
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: cardBorderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper image
              CachedNetworkImage(
                imageUrl: wallpaper.thumbnailUrl ?? wallpaper.imageUrl,
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

              // Gradient overlay for details
              if (showDetails)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallpaper.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${wallpaper.likes}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${wallpaper.downloads}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Premium badge
              if (wallpaper.isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child:
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 12),
                                SizedBox(width: 2),
                                Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 300))
                          .slideX(
                            begin: 0.5,
                            end: 0,
                            duration: const Duration(milliseconds: 300),
                          ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
