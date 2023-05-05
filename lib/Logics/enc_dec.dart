import 'dart:async';
import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';

late Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
    futureKeyPair;

// to store the KeyPair once we get data from our future
late crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey> keyPair;

// a sample text to be encrypted and decrypted
String sampleText = "Hello World";

// a string variable to hold the encrypted text
late String encryptedText;

// a string variable to hold the decrypted text
late String decryptedText;

Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
    getKeyPair() {
  var helper = RsaKeyHelper();
  return helper.computeRSAKeyPair(helper.getSecureRandom());
}

// function to encrypt a string using a public key

String encrypt(String plaintext, String key) {
  String ciphertext = plaintext;
  for (int i = 0; i < 3; i++) {
    ciphertext = _encryptRound(ciphertext, _generateSubKey(key, i));
  }
  return ciphertext;
}

String decrypt(String ciphertext, String key) {
  String plaintext = ciphertext;
  for (int i = 2; i >= 0; i--) {
    plaintext = _decryptRound(plaintext, _generateSubKey(key, i));
  }
  return plaintext;
}

String _encryptRound(String plaintext, String key) {
  String ciphertext = '';
  for (int i = 0; i < plaintext.length; i++) {
    int charCode = plaintext.codeUnitAt(i);
    int keyIndex = i % key.length;
    int keyShift = key.codeUnitAt(keyIndex) - 'a'.codeUnitAt(0);
    int encryptedCode = (charCode + keyShift * 8) % 256;
    ciphertext += String.fromCharCode(encryptedCode);
  }
  return ciphertext;
}

String _decryptRound(String ciphertext, String key) {
  String plaintext = '';
  for (int i = 0; i < ciphertext.length; i++) {
    int charCode = ciphertext.codeUnitAt(i);
    int keyIndex = i % key.length;
    int keyShift = key.codeUnitAt(keyIndex) - 'a'.codeUnitAt(0);
    int decryptedCode = (charCode - keyShift * 8) % 256;
    plaintext += String.fromCharCode(decryptedCode);
  }
  return plaintext;
}

String _generateSubKey(String key, int round) {
  int shift = 7 * round;
  String subKey = '';
  for (int i = 0; i < key.length; i++) {
    int charCode = key.codeUnitAt(i);
    int shiftedCode = (charCode + shift) % 256;
    subKey += String.fromCharCode(shiftedCode);
  }
  return subKey;
}

class RSAKeyPair {
  int n;
  int e;
  int d;

  RSAKeyPair(this.n, this.e, this.d);
}

/*

int charToAscii(String character) {
  return character.runes.first;
}

String asciiToChar(int asciiValue) {
  return String.fromCharCode(asciiValue);
}
*/
int modExp(int base, int exponent, int modulus) {
  if (modulus == 1) {
    return 0;
  }

  int result = 1;
  base = base % modulus;
  while (exponent > 0) {
    if (exponent % 2 == 1) {
      result = (result * base) % modulus;
    }
    exponent = exponent ~/ 2;
    base = (base * base) % modulus;
  }

  return result;
}

bool isPrime(int n) {
  if (n <= 1) {
    return false;
  }
  for (int i = 2; i <= sqrt(n); i++) {
    if (n % i == 0) {
      return false;
    }
  }
  return true;
}

int findGCD(int a, int b) {
  while (b != 0) {
    int temp = b;
    b = a % b;
    a = temp;
  }
  return a;
}

int generatePrimeNumber() {
  final rand = Random();
  int prime = rand.nextInt(25) +
      2; // generate a number between 2-26, representing a letter in the alphabet

  while (!isPrime(prime)) {
    prime = rand.nextInt(25) +
        2; // generate another number between 2-26, representing a letter in the alphabet
  }

  return prime;
}

RSAKeyPair generateRSAKeyPair() {
  final p = generatePrimeNumber();
  final q = generatePrimeNumber();
  final n = p * q;
  final phi = (p - 1) * (q - 1);

  int e = 3; // choose e = 3
  while (findGCD(e, phi) != 1) {
    e += 2;
  }

  int d = 0;
  while ((d * e) % phi != 1) {
    d++;
  }

  return RSAKeyPair(n, e, d);
}

String bigIntToChar(BigInt value) {
  String charString = '';
  List<int> byteList = value
      .toRadixString(16)
      .replaceAllMapped(RegExp(r'(..)'),
          (match) => String.fromCharCode(int.parse(match.group(0)!, radix: 16)))
      .codeUnits;
  for (int i = 0; i < byteList.length; i++) {
    int byte = byteList[i];
    if (byte >= 32 && byte <= 126) {
      charString += String.fromCharCode(byte);
    } else {
      charString += '\\x${byte.toRadixString(16).padLeft(2, '0')}';
    }
  }
  return charString;
}

String encrypt1(String plaintext, RSAKeyPair publicKey) {
  String ciphertext = '';
  for (int i = 0; i < plaintext.length; i++) {
    int asciiValue = charToAscii(plaintext[i]);
    BigInt m = BigInt.from(asciiValue);
    BigInt c = BigInt.from(modExp(m.toInt(), publicKey.e, publicKey.n));

    String encryptedCharacter = bigIntToChar(c);
    ciphertext += encryptedCharacter;
  }
  return ciphertext;
}

String decrypt1(String ciphertext, RSAKeyPair privateKey) {
  String plaintext = '';
  for (int i = 0; i < ciphertext.length; i++) {
    int asciiValue = charToAscii(ciphertext[i]);
    BigInt c = BigInt.from(asciiValue);
    BigInt m = BigInt.from(modExp(c.toInt(), privateKey.d, privateKey.n));

    String decryptedCharacter = bigIntToChar(m);
    plaintext += decryptedCharacter;
  }
  return plaintext;
}

int charToAscii(String character) {
  return character.runes.first;
}

String asciiToChar(int asciiValue) {
  return String.fromCharCode(asciiValue);
}

String encryptString(String plaintext, RSAKeyPair publicKey) {
  String ciphertext = '';
  for (int i = 0; i < plaintext.length; i++) {
    int asciiValue = charToAscii(plaintext[i]);
    int encryptedAsciiValue = modExp(asciiValue, publicKey.e, publicKey.n);
    String encryptedCharacter = asciiToChar(encryptedAsciiValue);
    ciphertext += encryptedCharacter;
  }
  return ciphertext;
}

String decryptString(String ciphertext, RSAKeyPair privateKey) {
  String plaintext = '';
  for (int i = 0; i < ciphertext.length; i++) {
    int asciiValue = charToAscii(ciphertext[i]);
    int decryptedAsciiValue = modExp(asciiValue, privateKey.d, privateKey.n);
    String decryptedCharacter = asciiToChar(decryptedAsciiValue);
    plaintext += decryptedCharacter;
  }
  return plaintext;
}

Future<void> addUserWithRSAKeys(String userId) async {
  // generate RSA key pair
  RSAKeyPair keyPair = generateRSAKeyPair();

  // create a new document for the user with their ID and RSA keys
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .set({
        'publicKey': {
          'n': keyPair.n,
          'e': keyPair.e,
        },
        'privateKey': {
          'n': keyPair.n,
          'd': keyPair.d,
        },
      })
      .then((value) => print('User added with RSA keys'))
      .catchError((error) => print('Failed to add user: $error'));
}

Future<RSAKeyPair> getUserRSAKeys(String userId) async {
  RSAKeyPair keyPair;

  // retrieve the user's document from Firestore
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users2').doc(userId).get();

  // extract the public and private keys from the document

  Map<String, dynamic> userDocData = userDoc.data() as Map<String, dynamic>;

// extract the public and private keys from the document
  Map<String, dynamic> publicKeyData =
      userDocData['publicKey'] as Map<String, dynamic>;
  Map<String, dynamic> privateKeyData =
      userDocData['privateKey'] as Map<String, dynamic>;

  // create an RSA key pair object from the data
  keyPair =
      RSAKeyPair(publicKeyData['n'], publicKeyData['e'], privateKeyData['d']);

  return keyPair;
}
