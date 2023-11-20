import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:shrine/product_content.dart';

import 'app_state.dart';

class EditPage extends StatefulWidget {
  final String productId;

  EditPage({required this.productId});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  void initState() {
    super.initState();
    var products = Provider.of<AppState>(context, listen: false).productContents;
    var product = findProductById(widget.productId, products);

    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _descriptionController.text = product.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  final _nameFormKey = GlobalKey<FormState>(debugLabel: '_EditPageState');
  final _priceFormKey = GlobalKey<FormState>(debugLabel: '_EditPageState');
  final _descriptionFormKey = GlobalKey<FormState>(debugLabel: '_EditPageState');

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();



  XFile? _image;
  String? imageUrl;
  String? defaultImageUrl;

  final ImagePicker picker = ImagePicker();

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

  //This method update information of prodcut(name, price, descript, image url) on the firestore
  Future<void> updateProduct(
      String productId, String name, int price, String description, String imageUrl) async {
    DocumentReference productRef = FirebaseFirestore.instance
        .collection('product')
        .doc(productId);

    return await productRef.update({
      'name': name,
      'price': price,
      'description': description,
      'modified_time': FieldValue.serverTimestamp(),
      'image_url': imageUrl,
    });
  }

  /*This method uploads chosen image by user to storage
  * return url of uploaded image*/
  Future<String?> uploadImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      var fileRef = storageRef.child('image/${_image!.name}');
      await fileRef.putFile(File(_image!.path));
      return await fileRef.getDownloadURL();
    } else {
      //if user do not chose image,
      try {
        return defaultImageUrl;
      } on FirebaseException catch (e) {}
    }
  }

  /*This method get image from user's gallery and save it on _image*/
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var products = Provider.of<AppState>(context).productContents;
    var product = findProductById(widget.productId, products);
    defaultImageUrl = product.imageUrl;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        title: Text("Add"),
        actions: <Widget>[
          TextButton(
              onPressed: () async {{
                  imageUrl = await uploadImage();
                  updateProduct(
                      widget.productId, _nameController.text,
                      int.parse(_priceController.text),
                      _descriptionController.text,
                      imageUrl!);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"))
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_image == null)
            Container(
                width: 300,
                height: 300,
                child: Image.network(product.imageUrl, width: 300, height: 300))
          else
            Container(
              width: 300,
              height: 300,
              child: Image.file(File(_image!.path)),
            ),
          SizedBox(height: 6.0),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  semanticLabel: 'camera',
                ),
                onPressed: () => getImage(ImageSource.gallery),
              ),
            ],
          ),
          //get name of product
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _nameFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: "Product Name"
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your message to continue';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          //get price of product
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _priceFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: 'Price',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your message to continue';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          //get description of product
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _descriptionFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your message to continue';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}