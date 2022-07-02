import 'dart:convert';

import 'package:feed_finder/feed_finder.dart';
import 'package:webfeed/util/iterable.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

Future<RssFeed> findFeed(var url) async {
  //var feedUrl = await FeedFinder.scrape(url);
  final client = http.Client();
  final response = await client.get(Uri.parse(url));
  var y;
  try {
    y = RssFeed.parse(utf8.decode(response.bodyBytes));
  }catch (e) {
    y = AtomFeed.parse(utf8.decode(response.bodyBytes));
  }
  client.close();
  return y;
}

Future<List<RssFeed>> rssList(List listURL) async {
  var listRSS = <RssFeed>[];
  for (var element in listURL) {
    var x = await findFeed(element);
    listRSS.add(x);
  }
  return listRSS;
}