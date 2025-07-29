import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/wallpaper.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });

      final wallpaperProvider = Provider.of<WallpaperProvider>(
        context,
        listen: false,
      );
      wallpaperProvider.setSearchQuery(query);

      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final wallpaperProvider = Provider.of<WallpaperProvider>(
      context,
      listen: false,
    );
    wallpaperProvider.setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final wallpapers = wallpaperProvider.filteredWallpapers;
    final searchQuery = wallpaperProvider.searchQuery;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search wallpapers...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 18),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _performSearch),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : searchQuery.isEmpty
          ? _buildInitialContent()
          : _buildSearchResults(wallpapers),
    );
  }

  Widget _buildInitialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Search for wallpapers',
            style: AppTheme.subheadingStyle.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching by anime name, character, or style',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Wallpaper> wallpapers) {
    if (wallpapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: AppTheme.subheadingStyle.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.builder(
        itemCount: wallpapers.length,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          final wallpaper = wallpapers[index];
          return WallpaperCard(
            wallpaper: wallpaper,
            height: index % 5 == 0 || index % 5 == 3 ? 280 : 220,
          ).animate().fadeIn(
            delay: Duration(milliseconds: 50 * index),
            duration: 300.ms,
          );
        },
      ),
    );
  }
}
