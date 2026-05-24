import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthResult {
  final String provider;
  final String providerId;
  final String? email;
  final String? name;

  const SocialAuthResult({
    required this.provider,
    required this.providerId,
    this.email,
    this.name,
  });
}

class SocialAuthService {
  static final _google = GoogleSignIn(scopes: ['email', 'profile']);

  static Future<SocialAuthResult> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) throw Exception('Google sign-in cancelled.');
    return SocialAuthResult(
      provider: 'google',
      providerId: account.id,
      email: account.email,
      name: account.displayName,
    );
  }

  static Future<SocialAuthResult> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final nameParts = [credential.givenName, credential.familyName]
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => s!)
        .toList();

    return SocialAuthResult(
      provider: 'apple',
      providerId: credential.userIdentifier!,
      email: credential.email,
      name: nameParts.isEmpty ? null : nameParts.join(' '),
    );
  }
}
