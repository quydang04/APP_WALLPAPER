import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/category.dart';
import '../models/wallpaper.dart';
import '../providers/auth_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/wallpaper_card.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _tabs = ['Home', 'Categories', 'Premium', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          const NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Premium',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCategoriesTab();
      case 2:
        return _buildPremiumTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final isLoading = wallpaperProvider.isLoading;
    final popularWallpapers = wallpaperProvider.popularWallpapers;
    final recentWallpapers = wallpaperProvider.recentWallpapers;
    final categories = wallpaperProvider.categories;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    authProvider.initialize();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await wallpaperProvider.fetchWallpapers(user!.isPremium);
          await wallpaperProvider.fetchCategories();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // App bar
                  SliverAppBar(
                    floating: true,
                    title: const Text('Anime Wallpapers'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          context.push('/search');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload_outlined),
                        onPressed: () {
                          context.push('/upload');
                        },
                      ),
                    ],
                  ),

                  // Categories section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories',
                                style: AppTheme.subheadingStyle,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentIndex =
                                        1; // Switch to Categories tab
                                  });
                                },
                                child: const Text('See All'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Categories horizontal list
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length > 5
                            ? 5
                            : categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            category: category,
                            width: 150,
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: 100 * index),
                            duration: 300.ms,
                          );
                        },
                      ),
                    ),
                  ),

                  // Popular section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Wallpapers',
                            style: AppTheme.subheadingStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/category/popular');
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Popular wallpapers grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childCount: popularWallpapers.length > 4
                          ? 4
                          : popularWallpapers.length,
                      itemBuilder: (context, index) {
                        final wallpaper = popularWallpapers[index];
                        return WallpaperCard(
                          wallpaper: wallpaper,
                          height: index % 2 == 0 ? 280 : 220,
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 100 * index),
                          duration: 300.ms,
                        );
                      },
                    ),
                  ),

                  // Recent section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Wallpapers',
                            style: AppTheme.subheadingStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/category/new');
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent wallpapers grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childCount: recentWallpapers.length > 4
                          ? 4
                          : recentWallpapers.length,
                      itemBuilder: (context, index) {
                        final wallpaper = recentWallpapers[index];
                        return WallpaperCard(
                          wallpaper: wallpaper,
                          height: index % 2 == 0 ? 220 : 280,
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 100 * index),
                          duration: 300.ms,
                        );
                      },
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final isLoading = wallpaperProvider.isLoading;
    final categories = wallpaperProvider.categories;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await wallpaperProvider.fetchCategories();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // App bar
                  const SliverAppBar(floating: true, title: Text('Categories')),

                  // Categories grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CategoryCard(
                          category: category,
                          margin: EdgeInsets.zero,
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 50 * index),
                          duration: 300.ms,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPremiumTab() {
    return const Center(child: Text('Premium Tab - To be implemented'));
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user?.username ?? 'User', style: AppTheme.headingStyle),
            Text(user?.email ?? 'email@example.com', style: AppTheme.bodyStyle),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
