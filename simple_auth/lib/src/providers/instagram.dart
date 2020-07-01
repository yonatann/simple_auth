import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;
import "dart:convert" as convert;

class InstagramApi extends OAuthApi {
  InstagramApi(String identifier, String clientId, String clientSecret,
      String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(
            identifier,
            clientId,
            clientSecret,
            "https://api.instagram.com/oauth/access_token",
            "https://api.instagram.com/oauth/authorize",
            redirectUrl,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
    this.scopes = scopes ?? ["basic"];
  }

  @override
  Future<OAuthAccount> getAccountFromAuthCode(
      WebAuthenticator authenticator) async {
    if (tokenUrl?.isEmpty ?? true) throw new Exception("Invalid tokenURL");
    var postData = await authenticator.getTokenPostData(clientSecret);
    var resp = await httpClient.post(tokenUrl,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: postData);
    var map = convert.json.decode(resp.body);
    var result = OAuthResponse.fromJson(map);
    var account = OAuthAccount(identifier,
        created: DateTime.now().toUtc(),
        expiresIn: result.expiresIn,
        idToken: result.idToken,
        refreshToken: result.refreshToken,
        scope: authenticator.scope,
        tokenType: result.tokenType,
        token: result.accessToken,
        userData: {
          "userId": map["user_id"].toString()
        });
    return account;
  }

  @override
  Authenticator getAuthenticator() {
    var authenticator = super.getAuthenticator() as WebAuthenticator;
    authenticator.useEmbeddedBrowser = true;
    return authenticator;
  }
}
