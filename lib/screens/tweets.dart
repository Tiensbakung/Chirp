import 'dart:async';

import 'package:chirp/api/twitter.dart';
import 'package:chirp/model/common.dart';
import 'package:chirp/views/tweets.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TweetListScreen extends StatefulWidget {
  const TweetListScreen({Key? key}) : super(key: key);

  @override
  TweetListScreenState createState() => TweetListScreenState();
}

class TweetListScreenState extends State<TweetListScreen> {
  static const String query = '#eth -is:retweet';
  final ApiTwitter api = ApiTwitter();
  final PagingController<String?, ExTweetModel> _pagingController =
      PagingController(
    firstPageKey: null,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchData(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(String? nextToken) async {
    try {
      final resp = await api.searchRecent(query, nextToken: nextToken);
      final items = resp.tweets
          .map((e) => ExTweetModel(
                tweet: e,
                user: resp.userMap[e.authorId]!,
                place: resp.placeMap[e.placeId],
                mediaMap: resp.mediaMap,
              ))
          .toList();
      if (resp.meta.nextToken == null) {
        //last page
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, resp.meta.nextToken);
      }
    } catch (error) {
      _pagingController.error = error;
      throw Exception(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Tweets'),
        backgroundColor: Colors.blueGrey[300],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[100],
      body: PagedListView<String?, ExTweetModel>.separated(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<ExTweetModel>(
          itemBuilder: (context, item, index) => TweetCard(
            user: item.user,
            tweet: item.tweet,
            place: item.place,
            mediaMap: item.mediaMap,
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }
}
