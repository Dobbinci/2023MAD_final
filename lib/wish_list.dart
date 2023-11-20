import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/user_content.dart';

import 'app_state.dart';

import 'product_content.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({Key? key}) : super(key: key);

  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  void removeFromWishList(String productId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('user').doc(userId);

    userRef.update({
      'wish_list': FieldValue.arrayRemove([productId])
    });
  }

  //This method finds user object by userid
  UserContent findUserById(String userId, List<UserContent> users) {
    return users.firstWhere(
          (user) => user.id == userId,
      orElse: () => throw Exception('User not found'),
    );
  }

  List<Widget> _buildListItems(
      BuildContext context, List<ProductContent> products) {
    if (products.isEmpty) {
      return const <Widget>[];
    }

    return products.map((product) {
      return SizedBox(
        height: 180.0,
        child: Card(
          child: Row(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  removeFromWishList(product.id);
                },
                icon: Icon(Icons.delete_outline),
              ),
            ],
          )
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var products = Provider.of<AppState>(context).productContents;
    var users = Provider.of<AppState>(context).userContents;
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var user = findUserById(userId, users);

    List<ProductContent> wishListProducts = products.where((product) {
      return user.wishList.contains(product.id);
    }).toList();

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Wish List'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: _buildListItems(context, wishListProducts),
        ));
  }
}