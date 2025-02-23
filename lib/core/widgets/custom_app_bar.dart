import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomHeader extends StatelessWidget {
  final String? username;
  final String? photoUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool showSearch;

  const CustomHeader({
    super.key,
    this.username,
    this.photoUrl,
    this.onNotificationTap,
    this.onProfileTap,
    this.showSearch = true,
  });

  Future<void> _handleLogout(BuildContext context) async {
    const storage = FlutterSecureStorage();

    // Clear all user data
    await storage.deleteAll();

    if (context.mounted) {
      // Navigate to login page and remove all previous routes
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLength.body,
        vertical: AppLength.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout(context);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    photoUrl != null && photoUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(photoUrl!),
                          )
                        : const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.backgroundLight,
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                    const SizedBox(width: AppLength.sm),
                    Text(
                      'Hello, ${username ?? 'Guest'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (showSearch) ...[
            const SizedBox(height: AppLength.sm),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppLength.sm,
                  vertical: AppLength.xs,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
