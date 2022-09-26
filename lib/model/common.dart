import 'package:chirp/model/media.dart';
import 'package:chirp/model/place.dart';
import 'package:chirp/model/tweet.dart';
import 'package:chirp/model/user.dart';

class ExTweetModel {
  final TweetModel tweet;
  final UserModel user;
  final PlaceModel? place;
  final Map<String, MediaModel> mediaMap;

  const ExTweetModel({
    required this.tweet,
    required this.user,
    required this.mediaMap,
    this.place,
  });
}
