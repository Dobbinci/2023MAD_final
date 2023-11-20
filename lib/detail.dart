import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/product_content.dart';
import 'package:shrine/user_content.dart';

import 'app_state.dart';
import 'edit.dart';

class DetailPage extends StatefulWidget {
  final String productId;

  DetailPage({required this.productId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ProductContent findProductById(
      String productId, List<ProductContent> products) {
    return products.firstWhere(
      (product) => product.id == productId,
      orElse: () => ProductContent(
          id: '',
          name: '',
          price: 1,
          description: '',
          like: 1,
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/mad-final2.appspot.com/o/default_image%2Fhandong_logo.png?alt=media&token=a1128ee7-05cc-42c5-ac8f-7d6a974f6647',
          whoLikes: [],
          createdTime: '',
          modifiedTime: '',
          userId: ''),
    );
  }

  //This method finds user object by userid
  UserContent findUserById(String userId, List<UserContent> users) {
    return users.firstWhere((user) => user.id == userId,
        orElse: () => UserContent(id: '', wishList: []));
  }

  void deleteProduct(String productId) async {
    DocumentReference productRef =
        FirebaseFirestore.instance.collection('product').doc(productId);
    await productRef.delete();
  }

  void likeProduct(ProductContent product) async {
    DocumentReference productRef =
        FirebaseFirestore.instance.collection('product').doc(widget.productId);

    if (!product.whoLikes.contains(FirebaseAuth.instance.currentUser!.uid)) {
      await productRef.update({
        'who_likes':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        'like': FieldValue.increment(1),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Like it!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only do it once!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void wishProduct() async {
    DocumentReference productRef = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await productRef.update({
      'wish_list': FieldValue.arrayUnion([widget.productId])
    });
  }

  @override
  Widget build(BuildContext context) {
    var products = Provider.of<AppState>(context).productContents;
    var users = Provider.of<AppState>(context).userContents;
    var product = findProductById(widget.productId, products);
    var user = findUserById(FirebaseAuth.instance.currentUser!.uid, users);
    bool isWished = user.wishList.contains(product.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Detail"),
        actions: <Widget>[
          Visibility(
              visible:
                  (product.userId == FirebaseAuth.instance.currentUser!.uid),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.create),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPage(productId: product.id),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Navigator.pop(context);
                      deleteProduct(widget.productId);
                    },
                  ),
                ],
              )),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Image.network(product.imageUrl, width: 300, height: 300),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.red),
                      onPressed: () {
                        likeProduct(product);
                      },
                    ),
                    Text("${product.like}")
                  ],
                ),
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  "\$${product.price}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  product.description,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 30.0),
                Text(
                  "Creator: <${product.userId}>",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "${product.createdTime} Created",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "${product.modifiedTime} Modified",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isWished ? {} : wishProduct();
        },
        child: Icon(isWished ? Icons.check : Icons.shopping_cart),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
