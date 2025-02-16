import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

class GoogleAuthService {
  GoogleAuthService() {
    print('Platform.isIOS: ${Platform.isIOS}');
    print('Platform.isAndroid: ${Platform.isAndroid}');
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // On iOS, we don't set clientId as it's configured in Info.plist
    clientId: Platform.isIOS
        ? null
        : '289697190381-br2157ipror7j94d1nsm7oia00bunrl3.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>?> signIn() async {
    try {
      print(
          'Attempting Google Sign In on ${Platform.isIOS ? 'iOS' : 'Android'}');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        print('Successfully signed in: ${account.email}');
        final GoogleSignInAuthentication auth = await account.authentication;
        print('Got authentication tokens');

        // Return user data
        return {
          'id': account.id,
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
          'serverAuthCode': account.serverAuthCode,
          'accessToken': auth.accessToken,
          'idToken': auth.idToken,
        };
      }
      print('Sign in cancelled or failed');
      return null;
    } catch (error) {
      print('Google Sign In Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('Successfully signed out');
    } catch (error) {
      print('Google Sign Out Error: $error');
    }
  }

  // Get current user if already signed in
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      return {
        'id': account.id,
        'email': account.email,
        'displayName': account.displayName,
        'photoUrl': account.photoUrl,
        'serverAuthCode': account.serverAuthCode,
        'accessToken': auth.accessToken,
        'idToken': auth.idToken,
      };
    }
    return null;
  }
}
