class TweetPublicMetrics {
  final int retweetCount;
  final int replyCount;
  final int likeCount;
  final int quoteCount;

  const TweetPublicMetrics({
    required this.retweetCount,
    required this.replyCount,
    required this.likeCount,
    required this.quoteCount,
  });

  factory TweetPublicMetrics.fromJson(Map<String, dynamic> json) {
    return TweetPublicMetrics(
      retweetCount: json['retweet_count'],
      replyCount: json['reply_count'],
      likeCount: json['like_count'],
      quoteCount: json['quote_count'],
    );
  }
}

enum ReplySettings {
  everyone,
  mentionedUsers,
  followers;

  factory ReplySettings.parse(String s) {
    return ReplySettings.values.byName(s);
  }
}

enum EntityType { hashtag, cashtag, mention, url }

class EntityMeta {
  final EntityType type;
  final int index;
  final int start;
  final int end;
  const EntityMeta(this.type, this.index, this.start, this.end);
}

class EntityHashtag {
  final int start;
  final int end;
  final String tag;

  const EntityHashtag(this.start, this.end, this.tag);

  factory EntityHashtag.fromJson(Map<String, dynamic> json) {
    return EntityHashtag(json['start'], json['end'], json['tag']);
  }
}

class EntityCashtag {
  final int start;
  final int end;
  final String tag;

  const EntityCashtag(this.start, this.end, this.tag);

  factory EntityCashtag.fromJson(Map<String, dynamic> json) {
    return EntityCashtag(json['start'], json['end'], json['tag']);
  }
}

class EntityMention {
  final int start;
  final int end;
  final String id;
  final String username;

  const EntityMention(this.start, this.end, this.id, this.username);

  factory EntityMention.fromJson(Map<String, dynamic> json) {
    return EntityMention(
      json['start'],
      json['end'],
      json['id'],
      json['username'],
    );
  }
}

class EntityUrlImage {
  final String url;
  final int width;
  final int height;
  const EntityUrlImage(this.url, this.width, this.height);
  factory EntityUrlImage.fromJson(Map<String, dynamic> json) {
    return EntityUrlImage(json['url'], json['width'], json['height']);
  }
}

class EntityUrl {
  final int start;
  final int end;
  final String url;
  final String expandedUrl;
  final String displayUrl;
  final String? unwoundUrl;
  final String? title;
  final int? status;
  final String? mediaKey;
  final String? description;
  final List<EntityUrlImage> images;

  const EntityUrl({
    required this.start,
    required this.end,
    required this.url,
    required this.expandedUrl,
    required this.displayUrl,
    this.unwoundUrl,
    this.title,
    this.status,
    this.mediaKey,
    this.description,
    required this.images,
  });

  factory EntityUrl.fromJson(Map<String, dynamic> json) {
    List<EntityUrlImage> images = [];
    if (json['images'] != null) {
      json['images'].forEach((el) {
        images.add(EntityUrlImage(el['url'], el['width'], el['height']));
      });
    }
    return EntityUrl(
      start: json['start'],
      end: json['end'],
      url: json['url'],
      expandedUrl: json['expanded_url'],
      displayUrl: json['display_url'],
      unwoundUrl: json['unwound_url'],
      title: json['title'],
      status: json['status'],
      mediaKey: json['media_key'],
      description: json['description'],
      images: images,
    );
  }
}

class TweetModel {
  final String id;
  final String text;
  final String authorId;
  final String conversationId;
  final DateTime createdAt;
  final String? inReplyToUserId;
  final String lang;
  final String source;
  final ReplySettings replySettings;
  final TweetPublicMetrics publicMetrics;
  final String? placeId;
  final List<EntityMeta> entityMetas;
  final List<EntityHashtag> entityHashtags;
  final List<EntityCashtag> entityCashtags;
  final List<EntityMention> entityMentions;
  final List<EntityUrl> entityUrls;
  const TweetModel({
    required this.id,
    required this.text,
    required this.authorId,
    required this.conversationId,
    required this.createdAt,
    this.inReplyToUserId,
    required this.lang,
    required this.source,
    required this.replySettings,
    required this.publicMetrics,
    this.placeId,
    required this.entityMetas,
    required this.entityHashtags,
    required this.entityCashtags,
    required this.entityMentions,
    required this.entityUrls,
  });

  factory TweetModel.fromJson(Map<String, dynamic> json) {
    List<EntityMeta> metas = [];
    List<EntityHashtag> hashtags = [];
    List<EntityCashtag> cashtags = [];
    List<EntityMention> mentions = [];
    List<EntityUrl> urls = [];
    int i = 0;
    for (var el in (json['entities']['hashtags'] ?? [])) {
      metas.add(EntityMeta(EntityType.hashtag, i, el['start'], el['end']));
      hashtags.add(EntityHashtag.fromJson(el));
      i += 1;
    }
    i = 0;
    for (var el in (json['entities']['cashtags'] ?? [])) {
      metas.add(EntityMeta(EntityType.cashtag, i, el['start'], el['end']));
      cashtags.add(EntityCashtag.fromJson(el));
      i += 1;
    }
    i = 0;
    for (var el in (json['entities']['mentions'] ?? [])) {
      metas.add(EntityMeta(EntityType.mention, i, el['start'], el['end']));
      mentions.add(EntityMention.fromJson(el));
      i += 1;
    }
    i = 0;
    for (var el in (json['entities']['urls'] ?? [])) {
      metas.add(EntityMeta(EntityType.url, i, el['start'], el['end']));
      urls.add(EntityUrl.fromJson(el));
      i += 1;
    }
    metas.sort((a, b) => a.start - b.start);
    return TweetModel(
      id: json['id'],
      text: json['text'],
      authorId: json['author_id'],
      conversationId: json['conversation_id'],
      createdAt: DateTime.parse(json['created_at']),
      lang: json['lang'],
      publicMetrics: TweetPublicMetrics.fromJson(json['public_metrics']),
      replySettings: ReplySettings.parse(json['reply_settings']),
      source: json['source'],
      inReplyToUserId: json['in_reply_to_user_id'],
      placeId: json['geo']?['place_id'],
      entityMetas: metas,
      entityHashtags: hashtags,
      entityCashtags: cashtags,
      entityMentions: mentions,
      entityUrls: urls,
    );
  }
}
