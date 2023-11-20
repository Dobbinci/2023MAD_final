import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shrine/product_content.dart';
import 'package:shrine/user_content.dart';

class AppState extends ChangeNotifier {
  List<ProductContent> _productContents = [];
  List<UserContent> _userContents = [];
  bool _dropdownValue = false;

  List<ProductContent> get productContents => _productContents;
  bool get dropdownValue => _dropdownValue;
  List<UserContent> get userContents => _userContents;

  set dropdownValue(bool dropdownValue) {
    _dropdownValue = dropdownValue;
    FirebaseFirestore.instance
        .collection('product')
        .orderBy('price', descending: dropdownValue)
        .snapshots()
        .listen((event) {
      _productContents = event.docs.map((doc) {
        return ProductContent(
            id: doc.id,
            name: doc.data()['name'],
            price: doc.data()['price'],
            description: doc.data()['description'],
            like: doc.data()['like'],
            imageUrl: doc.data()['image_url'],
            whoLikes: doc.data()['who_likes'],
            createdTime:
            (doc.data()['created_time'] as Timestamp).toDate().toString(),
            modifiedTime:
            (doc.data()['modified_time'] as Timestamp).toDate().toString(),
            userId: doc.data()['user_id']);
      }).toList();
      notifyListeners();
    });
  }

  AppState() {
    init();
  }

  Future<void> init() async {
    //load product
    FirebaseFirestore.instance
        .collection('product')
        .orderBy('price', descending: dropdownValue)
        .snapshots()
        .listen((event) {
      _productContents = event.docs.map((doc) {
        return ProductContent(
            id: doc.id,
            name: doc.data()['name'],
            price: doc.data()['price'],
            description: doc.data()['description'],
            like: doc.data()['like'],
            imageUrl: doc.data()['image_url'],
            whoLikes: doc.data()['who_likes'],
            createdTime:
            (doc.data()['created_time'] as Timestamp?)?.toDate().toString() ?? DateTime.now().toString(),
            modifiedTime:
            (doc.data()['modified_time'] as Timestamp?)?.toDate().toString() ?? DateTime.now().toString(),
            userId: doc.data()['user_id']);
      }).toList();
      notifyListeners();
    });
    FirebaseFirestore.instance.collection('user').snapshots().listen((event) {
      _userContents = event.docs.map((doc) {
        return UserContent(
            id: doc.data()['uid'], wishList: doc.data()['wish_list']);
      }).toList();

      notifyListeners();
    });
  }
}
