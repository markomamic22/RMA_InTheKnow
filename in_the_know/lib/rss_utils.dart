import 'dart:convert';

import 'package:feed_finder/feed_finder.dart';
import 'package:flutter/foundation.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
Future<RssFeed> findFeed(var url) async {
  var feedUrl = await FeedFinder.scrape(url);
  final client = http.Client();
  final response = await client.get(Uri.parse(feedUrl.first));
  var y = RssFeed.parse(utf8.decode(response.bodyBytes));
  client.close();
  return y;

}

/*RssFeed returnFeed(var url) {
  findFeed(url).then((data) {}, onError: (e){if (kDebugMode) {
    print(e);
  }
  });
  return data;
}
*/