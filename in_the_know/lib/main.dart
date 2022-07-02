import 'package:flutter/material.dart';
import 'package:in_the_know/FeedDetails.dart';
import 'package:in_the_know/rss_utils.dart';
import 'package:webfeed/webfeed.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InTheKnow',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
        splashColor: Colors.deepOrangeAccent.shade100,
      ),
      home: const GridFeed(title: 'InTheKnow'),
    );
  }
}

class GridFeed extends StatefulWidget {
  const GridFeed({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<GridFeed> createState() => _GridFeedState();
}

class _GridFeedState extends State<GridFeed> {
  final List feedList = [
    "https://www.nytimes.com/",
    "https://www.nytimes.com/",
    "https://www.nytimes.com/",
    "https://www.nytimes.com/",
    "https://www.nytimes.com/",
    "https://www.nytimes.com/"
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        
      },),
      body: FutureBuilder<List<RssFeed>>(
        future: rssList(feedList),
        builder: (context,snapshot) {
          if(snapshot.hasData){
          return GridView.builder(
            padding: const EdgeInsets.all(8),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, index) {
                return ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size(300, 400)),
                      child: Card(
                        child: InkWell(
                          splashColor: Theme.of(context).splashColor,
                          onTap: () {
                           Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => FeedDetails(feed: snapshot.data!.elementAt(index),)));
                          },
                          child: Image.network(snapshot.data!.elementAt(index).image!.url!),
                        ),
                      ),
                    );
              });
        }else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(
                height: 16,
              ),
              Text("Please hold a moment...")
            ],
          ));
        }
      ),
    );
  }
}
