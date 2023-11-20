// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //Anonymous sing-in
  Future<void> anonymousSignIn() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    User? user = userCredential.user;

    FirebaseFirestore.instance
        .collection('user')
        .doc(user?.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (!snapshot.exists) {
        //make document in user collection
        FirebaseFirestore.instance.collection('user').doc(user?.uid).set({
          'uid': user?.uid,
          'status_message': "I promise to take the test honestly before GOD.",
          'wish_list': []
        });
      }
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  //Google sing-in
  Future<UserCredential> googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    FirebaseFirestore.instance
        .collection('user')
        .doc(user?.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (!snapshot.exists) {
        //make document in user collection
        FirebaseFirestore.instance.collection('user').doc(user?.uid).set({
          'uid': user?.uid,
          'email': user?.email,
          'name': user?.displayName,
          'status_message': "I promise to take the test honestly before GOD.",
          'wish_list': []
        });
      }
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );

    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('Final'),
              ],
            ),
            const SizedBox(height: 120.0),
            // TODO: Remove filled: true values (103)
            const SizedBox(height: 40.0),
            Column(
              children: <Widget>[
                ElevatedButton(
                  child: const Text('Anonymous sign-in'),
                  onPressed: () {
                    anonymousSignIn();
                  },
                ),
                const SizedBox(height: 60.0),
                ElevatedButton(
                  child: const Text('Google sign-in'),
                  onPressed: () {
                    googleSignIn();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
