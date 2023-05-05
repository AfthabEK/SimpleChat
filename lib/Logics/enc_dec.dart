import 'dart:async';
import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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
