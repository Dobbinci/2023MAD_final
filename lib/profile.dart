import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shrine/product_content.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? defaultImageUrl;

  @override
  void initState() {
    super.initState();
    downloadDefaultImageUrl();
  }

  //This methods returns url of default image
  Future<String> downloadDefaultImageUrl() async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('default_image')
        .child('handong_logo.png')
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Profile"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          //the case of anonymous user
          if (user!.photoURL == null)
            FutureBuilder(
                future: downloadDefaultImageUrl(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    defaultImageUrl = snapshot.data;
                    return Image.network(defaultImageUrl!,
                        fit: BoxFit.contain, height: 300.0);
                  } else {
                    return CircularProgressIndicator();
                  }
                })
          //the case of google user
          else
            Image.network(user.photoURL!, fit: BoxFit.contain, height: 300.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "<"+user.uid+">",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  user.isAnonymous ? "Anonymous" : user.email!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 60.0),
                Text(
                  "Dabin Lee",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "I promise to take the test honestly before GOD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
