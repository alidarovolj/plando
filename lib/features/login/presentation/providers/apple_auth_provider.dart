import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:plando/features/login/data/services/apple_auth_service.dart';
import 'package:plando/core/providers/requests/auth/user.dart';

final appleAuthProvider =
    StateNotifierProvider<AppleAuthNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  final userService = ref.read(requestCodeProvider);
  return AppleAuthNotifier(userService);
});

class AppleAuthNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  AppleAuthNotifier(this._userService) : super(const AsyncValue.data(null));

  final AppleAuthService _appleAuthService = AppleAuthService();
  final RequestCodeService _userService;

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final isAvailable = await _appleAuthService.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available');
      }

      final credential = await _appleAuthService.signIn();

      if (credential != null) {
        print('Apple User Data:');
        print('Email: ${credential.email}');
        print('User Identifier: ${credential.userIdentifier}');
        print('Identity Token: ${credential.identityToken}');
        print('Authorization Code: ${credential.authorizationCode}');

        if (credential.email == null || credential.email!.isEmpty) {
          throw Exception(
              'Email is required for authentication. Please ensure you share your email when signing in with Apple.');
        }

        if (credential.identityToken != null) {
          // Return all necessary data for authentication
          state = AsyncValue.data({
            'email': credential.email,
            'userIdentifier': credential.userIdentifier,
            'identityToken': credential.identityToken,
            'authorizationCode': credential.authorizationCode,
            'firstName': credential.givenName,
            'lastName': credential.familyName
          });
        } else {
          throw Exception('Missing required authentication token from Apple');
        }
      }
    } catch (error, stackTrace) {
      print('Apple Sign In Error: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
