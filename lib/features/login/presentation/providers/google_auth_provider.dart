import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plando/features/login/data/services/google_auth_service.dart';

final googleAuthProvider = StateNotifierProvider<GoogleAuthNotifier,
    AsyncValue<Map<String, dynamic>?>>((ref) => GoogleAuthNotifier());

class GoogleAuthNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  GoogleAuthNotifier() : super(const AsyncValue.data(null));

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final userData = await _googleAuthService.signIn();
      state = AsyncValue.data(userData);
      if (userData != null) {
        print('User Data: $userData');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    await _googleAuthService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> checkCurrentUser() async {
    try {
      final userData = await _googleAuthService.getCurrentUser();
      state = AsyncValue.data(userData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
