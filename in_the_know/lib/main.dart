import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:in_the_know/FeedDetails.dart';
import 'package:in_the_know/authentication.dart';
import 'package:in_the_know/rss_utils.dart';
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => MyApp(),
    ),
  );
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
  final _textFormFieldKey = GlobalKey<FormState>();
  late List _feedList = [];
  late TextEditingController _controller;
  late List temp = [];

  @override
  void initState() {
    super.initState();
    final doc_ref = FirebaseFirestore.instance.collection('feeds').doc(FirebaseAuth.instance.currentUser?.uid);
    doc_ref.get(const GetOptions(source: Source.serverAndCache)).then(
          (res) => { res.data()?.forEach((key, value) {
        temp.add(value);
      })},onError: (e) => print(e),
    );
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(children: [
                        Consumer<ApplicationState>(
                          builder: (context, appState, _) => Authentication(
                            email: appState.email,
                            loginState: appState.loginState,
                            startLoginFlow: appState.startLoginFlow,
                            verifyEmail: appState.verifyEmail,
                            signInWithEmailAndPassword:
                                appState.signInWithEmailAndPassword,
                            cancelRegistration: appState.cancelRegistration,
                            registerAccount: appState.registerAccount,
                            signOut: appState.signOut,
                          ),
                        ),
                      ]);
                    });
              },
              icon: const Icon(Icons.account_circle))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text("Add new RSS Feed"),
                    children: [
                      SimpleDialogOption(
                        child: TextFormField(
                          key: _textFormFieldKey,
                          controller: _controller,
                          decoration: InputDecoration(hintText: "Enter URL"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SimpleDialogOption(
                            child: TextButton(
                              onPressed: () {
                                _controller.clear();
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                          ),
                          SimpleDialogOption(
                            child: TextButton(
                              onPressed: () async {
                                setState(() {
                                  _feedList.add(_controller.value.text);
                                });
                                var temp = _feedList.asMap();
                                Map<String, String> map =
                                    new Map<String, String>();
                                temp.forEach((key, value) {
                                  map.putIfAbsent(key.toString(), () => value);
                                });
                                await FirebaseFirestore.instance
                                    .collection('feeds')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .set(map, SetOptions(merge: true));
                                var snackbar = const SnackBar(
                                    content:
                                        Text("Feed loading in background"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbar);
                                Navigator.pop(context);
                                _controller.clear();
                              },
                              child: Text("Add"),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                });
          },
          child: const Icon(Icons.add)),
      body: RefreshIndicator(onRefresh: () async{
        setState(() {
          _feedList = temp;
        },);
      },
        child: FutureBuilder<List<RssFeed>>(
            future: rssList(_feedList),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, index) {
                      return ConstrainedBox(
                        constraints: BoxConstraints.tight(const Size(300, 400)),
                        child: Card(
                          child: InkWell(
                            onLongPress: () {
                              setState(() {
                                _feedList.removeAt(index);
                                var temp = _feedList.asMap();
                                Map<String, String> map =
                                    new Map<String, String>();
                                temp.forEach((key, value) {
                                  map.putIfAbsent(key.toString(), () => value);
                                });
                                FirebaseFirestore.instance
                                    .collection('feeds')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .set(map, SetOptions(merge: false));
                              });
                            },
                            splashColor: Theme.of(context).splashColor,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          FeedDetails(
                                            feed: snapshot.data!.elementAt(index),
                                          )));
                            },
                            child: Image.network(
                                snapshot.data!.elementAt(index).image!.url!,
                                errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.rss_feed);
                            }, semanticLabel: "Placeholder"),
                          ),
                        ),
                      );
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16,
                  ),
                  Text("Please hold a moment...")
                ],
              ));
            }),
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  ApplicationLoginState get loginState => _loginState;

  String? _email;

  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
