import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/upcoming_meal.dart';
import 'package:rassoi/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

import 'authentication.dart';
import 'food_categories.dart';

void main() {
  /**
   * Rassoi
   */
  runApp(const HomePage());

  /**
   * Login
   */
/*  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => LoginPage(),
    ),
  );*/
}

/**
 * Rassoi
 */
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
      home: const HomeWidget(title: 'Flutter Demo Home Page'),
    );
  }
}

/**
 * Rassoi
 */
class HomeWidget extends StatelessWidget {
  final String title;
  static const int LEFT_PADDING = 20;
  static const int RIGHT_PADDING = 10;
  static const int TOP_PADDING = 50;
  static const int BOTTOM_PADDING = 20;

  const HomeWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return ChangeNotifierProvider<UpcomingMeal>(
      create: (context) {
        return UpcomingMeal();
      },
      child: Scaffold(
/*      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),*/
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 10, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text("Rassoi"),
                  Icon(Icons.search_outlined),
                ],
              ),
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 10, 0),
                child: Text("Upcoming Meals")),
            FutureBuilder<Iterable<String>>(
              future: getUpcomingMealsFuture(),
              builder: (BuildContext context,
                  AsyncSnapshot<Iterable<String>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('Loading...');
                  default:
                    return SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                            width: 10,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          String image = snapshot.data!.elementAt(index);
                          return Container(
                            color: Colors.red,
                            height: 100,
                            child: FadeInImage.memoryNetwork(
                              width: 100,
                              height: 100,
                              placeholder: kTransparentImage,
                              fit: BoxFit.cover,
                              image:
                              "https://images.unsplash.com/photo-1503818454-2a008dc38d43?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGFsbHxlbnwwfHwwfHw%3D&w=1000&q=80",
                            ),
                          );
                        },
                      ),
                    );
                }
              },
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                child: Text("Explore Food")),
            FutureBuilder(
              future: getFoodCategories(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                return Container(
                    alignment: Alignment.topLeft,
                    height: 90,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4),
                      itemBuilder: (_, index) {
                        bool shouldShowAllButton = index + 1 > snapshot.data!.docs.length;
                        Map<String, dynamic>? map;
                        if (!shouldShowAllButton) {
                          map = snapshot.data?.docs.elementAt(index).data();
                        }
                        return FoodCategory(
                                map?.values.last,
                                map?.values.first,
                                index > 7 ? true : shouldShowAllButton ? true : false
                        );
                      },
                      itemCount: getCategoriesCount(snapshot)
                    ));
              },
            ),
/*            ListView(
              scrollDirection: Axis.horizontal,
              children: [

              ],
            )*/
          ],
        ),
      ),
    );
  }

  int getCategoriesCount(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    if (snapshot.data == null) {
      return 0;
    }
    return snapshot.data!.docs.length >= 8 ? 8 : snapshot.data!.docs.length + 1;
  }

/*  List<Widget> getUpcomingMealsWidgets(List<String>? dataList) {
    if (dataList == null) {
      return [const Text("snapshot data is null")];
    }
    return dataList.map((imageUrl) => Container(
      color: Colors.red,
      height: 100,
      child: FadeInImage.memoryNetwork(
        width: 100,
        height: 100,
        placeholder: kTransparentImage,
        fit: BoxFit.cover,
        image: "https://images.unsplash.com/photo-1503818454-2a008dc38d43?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGFsbHxlbnwwfHwwfHw%3D&w=1000&q=80",
      ),
    ),
    ).toList();
  }*/

  Future<List<String>> getUpcomingMealsFuture() async {
    await Firebase.initializeApp();
    String uid = "Karan_g";
    return FirebaseFirestore.instance
        .collection("/users/$uid/meals")
        .get()
        .then((collection) {
      return collection.docs.map((documentSnapshot) {
        return documentSnapshot.get("dish_image") as String;
      }).toList();
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getFoodCategories() async {
    await Firebase.initializeApp();
    return FirebaseFirestore.instance.collection("/categories/").get();
  }
}

/**
 * Login
 */
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Meetup',
      routes: {
      //  '/' : (BuildContext context) => const LoginPage(),
        '/homePage' : (BuildContext context)=> const HomePage(),
      },
      theme: ThemeData(
        buttonTheme: Theme
            .of(context)
            .buttonTheme
            .copyWith(
          highlightColor: Colors.deepPurple,
        ),
        primarySwatch: Colors.deepPurple,
/*        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),*/
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginWidget(),
    );
  }
}
/**
 * Login
 */
class LoginWidget extends StatelessWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rassoi'),
      ),
      body: ListView(
        children: <Widget>[
          /**
           * Image.asset('assets/codelab.png'),
           */
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          Consumer<ApplicationState>(
            builder: (context, appState, _) =>
                Authentication(
                  email: appState.email,
                  loginState: appState.loginState,
                  startLoginFlow: appState.startLoginFlow,
                  verifyEmail: appState.verifyEmail,
                  signInWithEmailAndPassword: appState
                      .signInWithEmailAndPassword,
                  cancelRegistration: appState.cancelRegistration,
                  registerAccount: appState.registerAccount,
                  signOut: appState.signOut,
                ),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("What we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),
          Consumer<ApplicationState>(
            builder: (context, appState, _) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add from here
                    if (appState.attendees >= 2)
                      Paragraph('${appState.attendees} people going')
                    else
                      if (appState.attendees == 1)
                        const Paragraph('1 person going')
                      else
                        const Paragraph('No one going'),
                    // To here.
                    if (appState.loginState ==
                        ApplicationLoginState.loggedIn) ...[
                      // Add from here
                      YesNoSelection(
                        state: appState.attending,
                        onSelection: (attending) =>
                        appState.attending = attending,
                      ),
                      // To here.
                      const Header('Discussion'),
                      GuestBook(
                        addMessage: (message) =>
                            appState.addMessageToGuestBook(message),
                        messages: appState.guestBookMessages,
                      ),
                    ],
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
/**
 * Login
 */
class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    // Add from here
    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      notifyListeners();
    });
    // To here

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners();
        });
        // Add from here
        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.data() != null) {
            if (snapshot.data()!['attending'] as bool) {
              _attending = Attending.yes;
            } else {
              _attending = Attending.no;
            }
          } else {
            _attending = Attending.unknown;
          }
          notifyListeners();
        });
        // to here
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel(); // new
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  ApplicationLoginState get loginState => _loginState;

  String? _email;

  String? get email => _email;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];

  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  int _attendees = 0;

  int get attendees => _attendees;

  Attending _attending = Attending.unknown;
  StreamSubscription<DocumentSnapshot>? _attendingSubscription;

  Attending get attending => _attending;

  set attending(Attending attending) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, dynamic>{'attending': true});
    } else {
      userDoc.set(<String, dynamic>{'attending': false});
    }
  }

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(String email,
      void Function(FirebaseAuthException e) errorCallback,) async {
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

  Future<void> signInWithEmailAndPassword(String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,) async {
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

  Future<void> registerAccount(String email,
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

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime
          .now()
          .millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
/**
 * Login
 */
class GuestBookMessage {
  GuestBookMessage({required this.name, required this.message});

  final String name;
  final String message;
}
/**
 * Login
 */
enum Attending { yes, no, unknown }
/**
 * Login
 */
class GuestBook extends StatefulWidget {
  const GuestBook({required this.addMessage, required this.messages});

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  _GuestBookState createState() => _GuestBookState();
}
/**
 * Login
 */
class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Leave a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var message in widget.messages)
          Paragraph('${message.name}: ${message.message}'),
        const SizedBox(height: 8),
      ],
    );
  }
}
/**
 * Login
 */
class YesNoSelection extends StatelessWidget {
  const YesNoSelection({required this.state, required this.onSelection});

  final Attending state;
  final void Function(Attending selection) onSelection;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case Attending.yes:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
      case Attending.no:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () => onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              StyledButton(
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              StyledButton(
                onPressed: () => onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
    }
  }
}
