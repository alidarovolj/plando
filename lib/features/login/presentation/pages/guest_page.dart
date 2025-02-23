import 'package:flutter/material.dart';
import 'package:plando/core/styles/constants.dart';
import 'package:plando/core/widgets/auth_app_bar.dart';
import 'package:plando/core/widgets/custom_button.dart';
import 'package:plando/core/widgets/custom_snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AuthAppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLength.body),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                ),
                const SizedBox(height: AppLength.xl),
                const Text(
                  'You Are Entering As A Guest',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppLength.xs),
                const Text(
                  'You won\'t be able to share lists or\nsell them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  label: 'Continue as a guest',
                  onPressed: () async {
                    try {
                      const storage = FlutterSecureStorage();

                      // Save mock guest user data
                      await storage.write(
                          key: 'user_email', value: 'guest@plando.app');
                      await storage.write(key: 'username', value: 'Guest User');
                      await storage.write(
                          key: 'is_authenticated', value: 'true');
                      await storage.write(key: 'is_guest', value: 'true');

                      if (context.mounted) {
                        CustomSnackBar.show(
                          context,
                          message: 'Welcome, Guest User!',
                          type: SnackBarType.success,
                        );
                        context.go('/home');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomSnackBar.show(
                          context,
                          message: 'Failed to continue as guest',
                          type: SnackBarType.error,
                        );
                      }
                    }
                  },
                  type: ButtonType.normal,
                  isFullWidth: true,
                  color: ButtonColor.black,
                  style: CustomButtonStyle.filled,
                ),
                const SizedBox(height: AppLength.sm),
                CustomButton(
                  label: 'Create an account',
                  onPressed: () => context.go('/login'),
                  type: ButtonType.normal,
                  isFullWidth: true,
                  color: ButtonColor.black,
                  style: CustomButtonStyle.outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
