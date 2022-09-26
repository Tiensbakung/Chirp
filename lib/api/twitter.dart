import 'dart:convert';
import 'dart:io';

import 'package:chirp/model/media.dart';
import 'package:chirp/model/meta.dart';
import 'package:chirp/model/place.dart';
import 'package:chirp/model/tweet.dart';
import 'package:chirp/model/user.dart';
import 'package:chirp/utils/commons.dart';
import 'package:http/http.dart' as http;

const host = 'api.twitter.com';

class TweetResponse {
  final MetaModel meta;
  final List<TweetModel> tweets;
  final Map<String, UserModel> userMap;
  final Map<String, PlaceModel> placeMap;
  final Map<String, MediaModel> mediaMap;
  const TweetResponse({
    required this.meta,
    required this.tweets,
    required this.userMap,
    required this.placeMap,
    required this.mediaMap,
  });

  factory TweetResponse.fromJson(Map<String, dynamic> map) {
    final meta = MetaModel.fromJson(map['meta']);
    List<TweetModel> tweets = [];
    for (var el in map['data']) {
      tweets.add(TweetModel.fromJson(el));
    }
    Map<String, UserModel> userMap = {};
    for (var el in map['includes']['users']) {
      userMap[el['id']] = UserModel.fromJson(el);
    }
    Map<String, PlaceModel> placeMap = {};
    for (var el in map['includes']['places'] ?? []) {
      placeMap[el['id']] = PlaceModel.fromJson(el);
    }
    Map<String, MediaModel> mediaMap = {};
    for (var el in map['includes']['media']) {
      mediaMap[el['media_key']] = MediaModel.fromJson(el);
    }
    return TweetResponse(
      meta: meta,
      tweets: tweets,
      userMap: userMap,
      placeMap: placeMap,
      mediaMap: mediaMap,
    );
  }
}

class UserResponse {
  final UserModel user;
  const UserResponse({required this.user});
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      user: UserModel.fromJson(json['data']),
    );
  }
}

class ApiTwitter {
  Map<String, String> headers = {};

  Future<void> refreshToken() async {
    if (SecureStore.accessToken == null) {
      await SecureStore.loadToken();
    }
    final now = DateTime.now();
    if (SecureStore.accessToken == null ||
        SecureStore.expireAt == null ||
        SecureStore.expireAt!.compareTo(now) <= 0) {
      await _refreshAccessToken();
    }
    headers = {
      HttpHeaders.authorizationHeader: 'Bearer ${SecureStore.accessToken}',
    };
  }

  Future<void> _refreshAccessToken() async {
    final resp = await http.post(
      Uri.https('api.twitter.com', '/2/oauth2/token', {
        'client_id': 'YOUR_CLIENT_ID',
        'refresh_token': SecureStore.refreshToken,
        'grant_type': 'refresh_token',
      }),
      headers: {
        'content-type': 'application/x-www-form-urlencoded',
      },
    );
    if (resp.statusCode >= 300) {
      throw Exception('${resp.statusCode} ${resp.reasonPhrase}: ${resp.body}');
    }
    final map = jsonDecode(resp.body);
    final expire = DateTime.now().add(Duration(seconds: map['expires_in']));
    await SecureStore.saveToken(
      map['access_token'],
      map['refresh_token'],
      expire,
    );
  }

  Future<TweetResponse> searchRecent(
    String query, {
    String? nextToken,
    String? sinceId,
  }) async {
    if (query.length > 512) {
      throw Exception('$query longer than 512');
    }
    await refreshToken();
    final params = _getParams(query, nextToken: nextToken, sinceId: sinceId);
    final resp = await http.get(
      Uri.https(host, '/2/tweets/search/recent', params),
      headers: headers,
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return TweetResponse.fromJson(jsonDecode(resp.body));
    } else {
      throw '${resp.statusCode} ${resp.reasonPhrase}: ${resp.body}';
    }
  }

  Future<UserResponse> lookupUser(String id) async {
    await refreshToken();
    final params = _getUserParams();
    print('params: $params');
    final resp = await http.get(
      Uri.https(host, '/2/users/$id', params),
      headers: headers,
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      print(resp.body);
      return UserResponse.fromJson(jsonDecode(resp.body));
    } else {
      throw '${resp.statusCode} ${resp.reasonPhrase}: ${resp.body}';
    }
  }
}

Map<String, String> _getParams(String query,
    {String? nextToken, String? sinceId}) {
  Map<String, String> params = {
    'max_results': '10',
    'tweet.fields': _tweetFields,
    'expansions': _expansions,
    'user.fields': _userFields,
    'place.fields': _placeFields,
    'media.fields': _mediaFields,
    'query': query
  };
  if (nextToken != null) {
    params['next_token'] = nextToken;
  }
  if (sinceId != null) {
    params['since_id'] = sinceId;
  }
  return params;
}

Map<String, String> _getUserParams() {
  return {
    'user.fields': '$_userFields,description',
  };
}

final _tweetFields = [
  'conversation_id',
  'public_metrics',
  'created_at',
  'lang',
  'reply_settings',
  'source',
  'in_reply_to_user_id',
  'geo',
  'entities',
].join(',');

final _userFields = [
  'created_at',
  'profile_image_url',
  'location',
  'public_metrics',
  'verified',
  'protected',
  'url',
].join(',');

final _placeFields = [
  'name',
  'country',
  'country_code',
  'place_type',
].join(',');

final _mediaFields = [
  'url',
  'duration_ms',
  'height',
  'width',
  'preview_image_url',
].join(',');

final _expansions = [
  'author_id',
  'geo.place_id',
  'entities.mentions.username',
  'attachments.media_keys',
].join(',');
