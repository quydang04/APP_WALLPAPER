import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/category.dart';
import '../models/wallpaper.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_card.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryId;

  const CategoryScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final isLoading = wallpaperProvider.isLoading;

    // Get category
    Category? category;
    List<Wallpaper> wallpapers = [];

    // Handle special categories
    if (widget.categoryId == 'popular') {
      category = Category(
        id: 'popular',
        name: 'Popular',
        description: 'Most popular wallpapers',
      );
      wallpapers = wallpaperProvider.popularWallpapers;
    } else if (widget.categoryId == 'new') {
      category = Category(
        id: 'new',
        name: 'New',
        description: 'Latest wallpapers',
      );
      wallpapers = wallpaperProvider.recentWallpapers;
    } else {
      // Find category by ID
      category = wallpaperProvider.categories.firstWhere(
        (c) => c.id == widget.categoryId,
        orElse: () => Category(id: 'not_found', name: 'Category Not Found'),
      );

      // Get wallpapers for this category
      wallpapers = wallpaperProvider.getWallpapersByCategory(widget.categoryId);
    }

    return Scaffold(
      appBar: AppBar(title: Text(category.name), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Category description if available
                if (category.description != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        category.description!,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Wallpapers grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: wallpapers.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              'No wallpapers found in this category',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final wallpaper = wallpapers[index];
                            return WallpaperCard(
                              wallpaper: wallpaper,
                              height: index % 5 == 0 || index % 5 == 3
                                  ? 280
                                  : 220,
                            ).animate().fadeIn(
                              delay: Duration(milliseconds: 50 * index),
                              duration: const Duration(milliseconds: 300),
                            );
                          }, childCount: wallpapers.length),
                        ),
                ),
              ],
            ),
    );
  }
}
