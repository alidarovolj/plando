import 'dart:math';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io' show Platform;

class AppleAuthService {
  /// Generates a random string that will be used as the nonce
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      if (!Platform.isIOS) {
        throw Exception('Apple Sign In is only available on iOS');
      }

      // Generate secure, random nonce for authentication
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (credential.email == null && credential.userIdentifier == null) {
        throw Exception('Failed to get user information from Apple');
      }

      print('Successfully signed in with Apple: ${credential.email}');
      return credential;
    } catch (error) {
      print('Apple Sign In Error: $error');
      if (error.toString().contains('canceled')) {
        throw Exception('Sign in was canceled');
      } else if (error.toString().contains('network')) {
        throw Exception('Network error occurred. Please check your connection');
      } else if (error.toString().contains('not found')) {
        throw Exception('Apple Sign In is not properly configured');
      }
      throw Exception(error.toString());
    }
  }

  Future<bool> isAvailable() async {
    if (!Platform.isIOS) return false;
    return await SignInWithApple.isAvailable();
  }
}
