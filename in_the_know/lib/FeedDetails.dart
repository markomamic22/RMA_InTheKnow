import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webfeed/webfeed.dart';

class FeedDetails extends StatefulWidget {
  const FeedDetails({Key? key, required this.feed}) : super(key: key);
  final RssFeed feed;

  @override
  State<FeedDetails> createState() => _FeedDetailsState();
}

class _FeedDetailsState extends State<FeedDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
// Here we take the value from the MyHomePage object that was created by
// the App.build method, and use it to set our appbar title.
        title: Text(widget.feed.title!),
      ),
      body: Center(
          child: ListView.builder(
        itemCount: widget.feed.items!.length,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.feed.items![position].title!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(
                              width: 100, height: 100),
                          child: Image.network(
                              widget.feed.items![position].media!.contents!
                                      .isNotEmpty
                                  ? widget.feed.items![position].media!
                                      .contents!.first.url!
                                  : widget.feed.image!.url!,
                              errorBuilder: (context, error, stackTrace) {
                            return Column(
                              children: [
                                Icon(Icons.rss_feed),
                                Text(widget.feed.title!)
                              ],
                            );
                          }))
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.feed.items![position].pubDate!
                        .toString()
                        .substring(0, 19),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          widget.feed.items![position].description!,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(
                              width: 100, height: 100),
                          child: IconButton(
                              color: Theme.of(context).primaryColorDark,
                              onPressed: () async {
                                await launchUrlString(
                                    widget.feed.items![position].link!);
                              },
                              icon: const Icon(Icons.launch)))
                    ],
                  )
                ],
              ),
            ),
          );
        },
      )),
    );
  }
}
