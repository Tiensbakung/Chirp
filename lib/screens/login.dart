import 'package:chirp/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:twitter_oauth2_pkce/twitter_oauth2_pkce.dart';

class TwitterLoginScreen extends StatefulWidget {
  const TwitterLoginScreen({Key? key}) : super(key: key);

  @override
  TwitterLoginScreenState createState() => TwitterLoginScreenState();
}

class TwitterLoginScreenState extends State<TwitterLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Access Token: ${SecureStore.accessToken}'),
            Text('Refresh Token: ${SecureStore.refreshToken}'),
            ElevatedButton(
              onPressed: () async {
                final oauth2 = getTwitterOAuth2Client();
                final resp = await oauth2.executeAuthCodeFlowWithPKCE(
                  scopes: Scope.values,
                );
                await SecureStore.saveToken(
                  resp.accessToken,
                  resp.refreshToken,
                  resp.expireAt,
                );
                super.setState(() {});
              },
              child: const Text('Login with Twitter'),
            ),
          ],
        ),
      ),
    );
  }
}

TwitterOAuth2Client getTwitterOAuth2Client() {
  return TwitterOAuth2Client(
    clientId: 'YOUR_TWITTER_CLIENT_ID',
    clientSecret: 'YOUR_CLIENT_SECRET',
    redirectUri: 'com.tiensbakung.chirp.oauth://callback/',
    customUriScheme: 'com.tiensbakung.chirp.oauth',
  );
}

Future<void> refreshAccessToken() async {
  final oauth2 = getTwitterOAuth2Client();
  await SecureStore.loadToken();
  if (SecureStore.refreshToken != null) {
    final token = SecureStore.refreshToken!;
    final resp = await oauth2.refreshAccessToken(token);
    await SecureStore.saveToken(
      resp.accessToken,
      resp.accessToken,
      resp.expireAt,
    );
  }
}
