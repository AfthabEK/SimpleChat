import 'dart:async';
import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'dart:math';

import 'dart:convert';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

String encrypt(String plaintext, String key, String pubkey) {
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

String decrypt(String ciphertext, String key, String pubkey) {
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

class RSAKeyPair {
  int n;
  int e;
  int d;

  RSAKeyPair(this.n, this.e, this.d);
}

int charToAscii(String character) {
  return character.runes.first;
}

String asciiToChar(int asciiValue) {
  return String.fromCharCode(asciiValue);
}

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

String encrypt1(String plaintext, RSAKeyPair publicKey) {
  String ciphertext = '';
  for (int i = 0; i < plaintext.length; i++) {
    int asciiValue = charToAscii(plaintext[i]);
    int encryptedAsciiValue = modExp(asciiValue, publicKey.e, publicKey.n);
    String encryptedCharacter = asciiToChar(encryptedAsciiValue);
    ciphertext += encryptedCharacter;
  }
  return ciphertext;
}

String decrypt1(String ciphertext, RSAKeyPair privateKey) {
  String plaintext = '';
  for (int i = 0; i < ciphertext.length; i++) {
    int asciiValue = charToAscii(ciphertext[i]);
    int decryptedAsciiValue = modExp(asciiValue, privateKey.d, privateKey.n);
    String decryptedCharacter = asciiToChar(decryptedAsciiValue);
    plaintext += decryptedCharacter;
  }
  return plaintext;
}

Future<RSAKeyPair> getUserRSAKeys(String userId) async {
  RSAKeyPair keyPair;

  // retrieve the user's document from Firestore
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users2').doc(userId).get();
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
