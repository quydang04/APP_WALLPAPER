import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/wallpaper.dart';
import '../providers/auth_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  bool _isAnime = true;
  String? _selectedAnimeCharacter;
  bool _isPremium = false;
  List<String> _selectedCategories = ['anime'];
  bool _isUploading = false;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _uploadWallpaper() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final wallpaperProvider = Provider.of<WallpaperProvider>(
          context,
          listen: false,
        );
        final user = authProvider.currentUser;

        if (user == null) {
          setState(() {
            _errorMessage = 'You must be logged in to upload wallpapers';
            _isUploading = false;
          });
          return;
        }

        // In a real app, we would upload the image to a server
        // For now, we'll just simulate the upload

        final newWallpaper = Wallpaper(
          id: 'wallpaper_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleController.text.trim(),
          imageUrl: _imageFile!.path, // In a real app, this would be a URL
          authorId: user.id,
          authorName: user.username,
          categories: _selectedCategories,
          tags: [..._selectedCategories],
          isPremium: _isPremium,
          isAnime: _isAnime,
          animeCharacter: _isAnime ? _selectedAnimeCharacter : null,
          createdAt: DateTime.now(),
          isApproved: false, // Requires approval
        );

        final success = await wallpaperProvider.uploadWallpaper(newWallpaper);

        if (success && mounted) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Wallpaper uploaded successfully! Pending approval.',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          setState(() {
            _errorMessage = 'Failed to upload wallpaper';
            _isUploading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isUploading = false;
        });
      }
    } else if (_imageFile == null) {
      setState(() {
        _errorMessage = 'Please select an image';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallpaperProvider = Provider.of<WallpaperProvider>(context);
    final categories = wallpaperProvider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Wallpaper'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to select image',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate().fadeIn().scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                ),

                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn().shake(),

                  const SizedBox(height: 16),
                ],

                // Title field
                CustomTextField(
                      label: 'Title',
                      hint: 'Enter wallpaper title',
                      controller: _titleController,
                      validator: Validators.validateWallpaperTitle,
                    )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(
                      begin: 0.3,
                      end: 0,
                      delay: 100.ms,
                      duration: 300.ms,
                    ),

                const SizedBox(height: 16),

                // Description field
                CustomTextField(
                      label: 'Description (Optional)',
                      hint: 'Enter wallpaper description',
                      controller: _descriptionController,
                      maxLines: 3,
                    )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideX(
                      begin: 0.3,
                      end: 0,
                      delay: 200.ms,
                      duration: 300.ms,
                    ),

                const SizedBox(height: 16),

                // Is Anime switch
                SwitchListTile(
                  title: const Text('Is this an anime wallpaper?'),
                  value: _isAnime,
                  onChanged: (value) {
                    setState(() {
                      _isAnime = value;
                      if (!value) {
                        _selectedAnimeCharacter = null;
                        _selectedCategories.remove('anime');
                      } else if (!_selectedCategories.contains('anime')) {
                        _selectedCategories.add('anime');
                      }
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ).animate().fadeIn(delay: 300.ms),

                // Anime character dropdown
                if (_isAnime) ...[
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Anime Character',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    value: _selectedAnimeCharacter,
                    items: AppConstants.animeCharacters.map((character) {
                      return DropdownMenuItem<String>(
                        value: character,
                        child: Text(character),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAnimeCharacter = value;
                      });
                    },
                    validator: _isAnime
                        ? (value) => value == null
                              ? 'Please select an anime character'
                              : null
                        : null,
                  ).animate().fadeIn(delay: 400.ms),
                ],

                const SizedBox(height: 16),

                // Categories
                Text(
                  'Categories',
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _selectedCategories.contains(
                      category.id,
                    );
                    return FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category.id);
                          } else {
                            _selectedCategories.remove(category.id);
                          }
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    ).animate().fadeIn(
                      delay: Duration(
                        milliseconds: 500 + 50 * categories.indexOf(category),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Premium switch
                SwitchListTile(
                  title: const Text('Premium content?'),
                  subtitle: const Text(
                    'Premium wallpapers are only available to premium users',
                  ),
                  value: _isPremium,
                  onChanged: (value) {
                    setState(() {
                      _isPremium = value;
                    });
                  },
                  activeColor: AppTheme.accentColor,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                // Upload button
                CustomButton(
                      text: 'Upload Wallpaper',
                      onPressed: _uploadWallpaper,
                      isLoading: _isUploading,
                      backgroundColor: AppTheme.primaryColor,
                      prefixIcon: const Icon(Icons.upload, color: Colors.white),
                    )
                    .animate()
                    .fadeIn(delay: 700.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 700.ms,
                      duration: 300.ms,
                    ),

                const SizedBox(height: 24),

                // Terms note
                Text(
                  'By uploading, you confirm that you have the rights to this image and agree to our terms of service.',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
