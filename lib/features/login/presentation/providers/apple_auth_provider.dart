import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../data/services/apple_auth_service.dart';

final appleAuthProvider = StateNotifierProvider<AppleAuthNotifier,
    AsyncValue<AuthorizationCredentialAppleID?>>((ref) {
  return AppleAuthNotifier(AppleAuthService());
});

class AppleAuthNotifier
    extends StateNotifier<AsyncValue<AuthorizationCredentialAppleID?>> {
  final AppleAuthService _authService;

  AppleAuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final credential = await _authService.signInWithApple();
      state = AsyncValue.data(credential);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
