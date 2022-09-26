class UserPublicMetrics {
  final int followersCount;
  final int followingCount;
  final int tweetCount;
  final int listedCount;
  const UserPublicMetrics({
    required this.followersCount,
    required this.followingCount,
    required this.tweetCount,
    required this.listedCount,
  });

  factory UserPublicMetrics.fromJson(Map<String, dynamic> json) {
    return UserPublicMetrics(
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      tweetCount: json['tweet_count'],
      listedCount: json['listed_count'],
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String username; // twitter user handle
  final DateTime createdAt;
  final String? description;
  final String? pinnedTweetId;
  final String profileImageUrl;
  final bool protected;
  final UserPublicMetrics publicMetrics;
  final String? url;
  final bool verified;
  final String? location;
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.createdAt,
    this.description,
    this.pinnedTweetId,
    required this.profileImageUrl,
    required this.protected,
    required this.publicMetrics,
    this.url,
    required this.verified,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> el) {
    print('url: ${el["url"]}');
    return UserModel(
      id: el['id'],
      name: el['name'],
      username: el['username'],
      createdAt: DateTime.parse(el['created_at']),
      description: el['description'],
      pinnedTweetId: el['pinned_tweet_id'],
      profileImageUrl: el['profile_image_url'],
      protected: el['protected'],
      publicMetrics: UserPublicMetrics.fromJson(el['public_metrics']),
      verified: el['verified'],
      location: el['location'],
      url: el['url'],
    );
  }
}
