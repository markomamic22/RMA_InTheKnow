import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_know/rss_utils.dart' as utils;
import 'package:url_launcher/url_launcher_string.dart';
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
      title: 'Flutter Demo',
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _url = "https://www.nytimes.com/";

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder<RssFeed>(
              future: utils.findFeed(_url),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.items?.length,
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
                                      snapshot.data!.items![position].title!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  ConstrainedBox(
                                      constraints:
                                          const BoxConstraints.tightFor(
                                              width: 100, height: 100),
                                      child: Image.network(snapshot
                                                  ?.data
                                                  ?.items?[position]
                                                  .media
                                                  ?.contents
                                                  ?.length !=
                                              0
                                          ? snapshot.data!.items![position]
                                              .media!.contents!.first!.url!
                                          : snapshot.data!.image!.url!))
                                ],
                              ),
                              SizedBox(height: 16,),
                              Text(snapshot.data!.items![position].pubDate!.toString().substring(0,19),
                              textAlign: TextAlign.left,),
                              Row(
                                children: [
                                   Expanded(
                                     flex: 5,
                                     child: Text(snapshot
                                         .data!.items![position].description!,),
                                   ),
                                  SizedBox(width: 8,),
                                  ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(width: 100,height: 100),
                                      child: IconButton(onPressed: () async{
                                            await launchUrlString(snapshot!.data!.items![position].link!);
                                      }, icon: Icon(Icons.launch)))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              })),
    );
  }
}
