import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'homepage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/api.dart' as crypto;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MyHomePage();
        } else {
          return const SignInScreen(
            providerConfigs: [EmailProviderConfiguration()],
          );
        }
      },
    );
  }
}

/*
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController pass = TextEditingController();

  var key = "null";
  String encryptedS = 'hii', decryptedS = 'hello';

  var password = "null";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Encrypt"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                controller: pass,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.blue)),
                  isDense: true, // Added this
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                ),
                cursorColor: Colors.white,
              ),
            ),
            MaterialButton(
              onPressed: () {
                Encrypt();
              },
              child: Text("Encrypt"),
            ),
            MaterialButton(
              onPressed: () {
                Decrypt();
              },
              child: Text("Decrypt"),
            ),
          ],
        ),
      ),
    );
  }

// method to Encrypt String Password
  void Encrypt() async {
    password = pass.text;

    // here pass the password entered by user and the key

    print(encryptedS);
  }

// method to decrypt String Password
  void Decrypt() async {
    print(decryptedS);
  }
}

*/
