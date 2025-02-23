import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:plando/features/login/data/services/apple_auth_service.dart';

final appleAuthProvider = StateNotifierProvider<AppleAuthNotifier,
    AsyncValue<AuthorizationCredentialAppleID?>>((ref) => AppleAuthNotifier());

class AppleAuthNotifier
    extends StateNotifier<AsyncValue<AuthorizationCredentialAppleID?>> {
  AppleAuthNotifier() : super(const AsyncValue.data(null));

  final AppleAuthService _appleAuthService = AppleAuthService();

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final isAvailable = await _appleAuthService.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available');
      }

      final credential = await _appleAuthService.signIn();
      state = AsyncValue.data(credential);

      if (credential != null) {
        print('User signed in with Apple: ${credential.email}');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
