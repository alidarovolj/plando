import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/core/widgets/custom_app_bar.dart' show CustomHeader;
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/models/movie.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/movie_card.dart';
import 'package:plando/core/widgets/movie_card_skeleton.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _storage = const FlutterSecureStorage();
  String? username;
  String? photoUrl;
  String selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
  }

  Future<void> _loadUserData() async {
    final email = await _storage.read(key: 'user_email');
    final photo = await _storage.read(key: 'user_photo');
    if (mounted) {
      setState(() {
        username = email?.split('@')[0];
        photoUrl = photo;
      });
    }
  }

  Future<void> _loadData() async {
    // Имитация загрузки данных
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLength.sm,
          vertical: AppLength.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFFFF1E6),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomHeader(
              username: username,
              photoUrl: photoUrl,
              onNotificationTap: () {
                // Handle notification tap
              },
              onProfileTap: () {
                // Handle profile tap
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLength.body,
                ),
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    'You don\'t have any\nlists yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppLength.xs),
                  const Text(
                    'You can click on the button below and create\nyour first list',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Create new list',
                    onPressed: () {
                      // Handle create list
                    },
                    type: ButtonType.normal,
                    color: ButtonColor.black,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Inspiration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppLength.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Movies and series'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Restaurants'),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Games'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppLength.body),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.615,
                    ),
                    itemCount: _isLoading ? 6 : mockMovies.length,
                    itemBuilder: (context, index) {
                      if (_isLoading) {
                        return const MovieCardSkeleton();
                      }
                      return MovieCard(
                        movie: mockMovies[index],
                        onAddTap: () {
                          // Handle add to list
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
