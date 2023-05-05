import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as en;
import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'homepage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:fast_rsa/fast_rsa.dart' as fast;
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pointycastle/asymmetric/api.dart' as asym;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

var privateKey;
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
      theme: ThemeData(primarySwatch: Colors.teal),
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  Future<void> _onSignIn(User user) async {
    // Generate RSA key pair
    var keyPair = await RSA.generate(2048);
    privateKey = keyPair.privateKey;
    var publicKey = keyPair.publicKey;

    // Encode public and private keys to PEM format

    // Save public and private keys to Firebase document
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.set({'public_key': publicKey, 'private_key': privateKey});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data as User;
          _onSignIn(user);
          final y = privateKey;
          return MyHomePage(x: y);
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

/*

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'Logics/enc_dec.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Future to hold our KeyPair

  // function to generate a keypair

  @override
  void initState() {
    super.initState();
    futureKeyPair = getKeyPair();
    futureKeyPair.then((value) {
      keyPair = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("RSA Encryption Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Sample Text: $sampleText',
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () {
                  encryptString(sampleText, keyPair.publicKey);
                },
                child: Text("Encrypt"),
              ),
              ElevatedButton(
                onPressed: () {
                  decryptString(encryptedText, keyPair.privateKey);
                },
                child: Text("Decrypt"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
/*
void main() async {
  // Generate a key pair with 2048-bit key size
  var keyPair = await RSA.generate(2048);
  var privateKey = keyPair.privateKey;
  var publicKey = keyPair.publicKey;

  // Convert the keys to string format
  var privateKeyString = await RSA.convertPrivateKeyToPKCS1(privateKey);
  var publicKeyString = await RSA.convertPublicKeyToPKCS1(publicKey);

  // Print the keys for demonstration purposes
  var pkey = parsePublicKeyFromPem(publicKeyString);
  // Sample text to encrypt and decrypt
  var plainText = 'Hello, world!';
  print(object)

  // Encrypt the sample text with the public key

  var encryptedText =
      await RSA.encryptOAEP(plainText, '', fast.Hash.SHA256, pkey);
  var encryptedTextBase64 = base64.encode(utf8.encode(encryptedText));

  print('Encrypted Text: $encryptedTextBase64');

  // Decrypt the encrypted text with the private key
  var decryptedText =
      await RSA.decryptOAEP(encryptedText, '', fast.Hash.SHA256, privateKey);
  print('Decrypted Text: $decryptedText');
}

**/