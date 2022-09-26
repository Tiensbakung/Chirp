import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:chirp/model/media.dart';
import 'package:chirp/model/place.dart';
import 'package:chirp/model/tweet.dart';
import 'package:chirp/model/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class TweetCard extends StatelessWidget {
  const TweetCard({
    Key? key,
    required this.user,
    required this.tweet,
    required this.place,
    required this.mediaMap,
  }) : super(key: key);

  final UserModel user;
  final TweetModel tweet;
  final PlaceModel? place;
  final Map<String, MediaModel> mediaMap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  onTap: () {
                    Beamer.of(context).beamToNamed('/users/${user.id}');
                  },
                  child: CircleAvatar(
                    radius: 24,
                    foregroundImage: NetworkImage(user.profileImageUrl),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Beamer.of(context).beamToNamed('/users/${user.id}');
                        },
                        child: Text(
                          '@${user.username}',
                          style: const TextStyle(
                            color: GFColors.PRIMARY,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(children: [
                        Text(
                          timeago.format(tweet.createdAt, locale: 'en'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(place?.country ?? ''),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildTweetText(),
            ),
            Row(children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite),
              ),
              Text('${tweet.publicMetrics.likeCount}'),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.sync_rounded),
              ),
              Text('${tweet.publicMetrics.quoteCount}'),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
              Text('${tweet.publicMetrics.retweetCount}'),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  '${tweet.publicMetrics.replyCount} comments',
                  style: const TextStyle(color: GFColors.PRIMARY),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(EntityUrl el) async {
    final uri = Uri.parse(el.unwoundUrl ?? el.expandedUrl);
    const mode = LaunchMode.externalApplication;
    if (!await launchUrl(uri, mode: mode)) {
      throw 'Could not Launch $uri';
    }
  }

  Widget _buildTweetText() {
    List<InlineSpan> list = [];
    int prev = 0;
    final chars = tweet.text.characters;
    for (var meta in tweet.entityMetas) {
      prev = min(prev, meta.start);
      final text = chars.getRange(prev, meta.start).toString();
      list.add(TextSpan(text: text));
      if (meta.type == EntityType.hashtag) {
        final el = tweet.entityHashtags[meta.index];
        list.add(TextSpan(
          text: '#${el.tag}',
          style: TextStyle(color: Colors.blueAccent[400]),
        ));
      } else if (meta.type == EntityType.cashtag) {
        final el = tweet.entityCashtags[meta.index];
        list.add(TextSpan(
          text: '\$${el.tag}',
          style: const TextStyle(color: Colors.lightBlueAccent),
        ));
      } else if (meta.type == EntityType.mention) {
        final el = tweet.entityMentions[meta.index];
        list.add(TextSpan(
          text: '@${el.username}',
          style: const TextStyle(color: Colors.amberAccent),
        ));
      } else if (meta.type == EntityType.url) {
        final el = tweet.entityUrls[meta.index];
        if (el.images.isNotEmpty) {
          final image = el.images[0];
          list.add(WidgetSpan(
            child: InkWell(
              child: GFImageOverlay(
                height: min(180, image.height.toDouble()),
                width: image.width.toDouble(),
                image: NetworkImage(image.url),
                boxFit: BoxFit.contain,
              ),
              onTap: () async {
                _launchUrl(el);
              },
            ),
          ));
        } else if (el.mediaKey != null) {
          final media = mediaMap[el.mediaKey]!;
          list.add(WidgetSpan(
            child: InkWell(
              child: GFImageOverlay(
                height: min(180, media.height.toDouble()),
                width: media.width.toDouble(),
                image: NetworkImage(media.url),
                boxFit: BoxFit.contain,
              ),
            ),
          ));
        } else {
          list.add(TextSpan(
            text: el.displayUrl,
            style: TextStyle(color: Colors.blue[900]),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await _launchUrl(el);
              },
          ));
        }
      }
      prev = meta.end;
    }
    list.add(TextSpan(text: chars.getRange(prev).toString()));
    return Text.rich(TextSpan(children: list));
  }
}

class TweetSummaryView2 extends StatelessWidget {
  const TweetSummaryView2({
    Key? key,
    required this.user,
    required this.tweet,
    required this.place,
  }) : super(key: key);

  final UserModel user;
  final TweetModel tweet;
  final PlaceModel? place;

  @override
  Widget build(BuildContext context) {
    return GFCard(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      titlePosition: GFPosition.start,
      title: GFListTile(
        avatar: GFAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
        ),
        title: Text(
          user.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subTitle: Text(
          '@${user.username}',
          style: const TextStyle(
            color: GFColors.PRIMARY,
            fontWeight: FontWeight.bold,
          ),
        ),
        description: Row(children: [
          Text(place?.country ?? ''),
          Text(timeago.format(tweet.createdAt, locale: 'en')),
        ]),
      ),
      content: Text(tweet.text),
      buttonBar: GFButtonBar(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        runSpacing: 0,
        children: [
          GFButton(
            type: GFButtonType.transparent,
            text: '${tweet.publicMetrics.likeCount}',
            icon: const Icon(Icons.favorite, color: GFColors.DANGER),
            size: GFSize.SMALL,
            onPressed: () {},
          ),
          GFButton(
            type: GFButtonType.transparent,
            text: '${tweet.publicMetrics.quoteCount}',
            icon: const Icon(Icons.sync_rounded),
            size: GFSize.SMALL,
            onPressed: () {},
          ),
          GFButton(
            type: GFButtonType.transparent,
            text: '${tweet.publicMetrics.retweetCount}',
            icon: const Icon(Icons.share),
            size: GFSize.SMALL,
            onPressed: () {},
          ),
          GFButton(
            type: GFButtonType.transparent,
            onPressed: () {},
            size: GFSize.SMALL,
            text: '${tweet.publicMetrics.replyCount} comments',
          ),
        ],
      ),
    );
  }
}
