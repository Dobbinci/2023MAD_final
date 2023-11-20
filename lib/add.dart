import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  XFile? _image;
  final ImagePicker imagePicker = ImagePicker();
  String? imageUrl;
  String? defaultImageUrl;

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await imagePicker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
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

  //This method uploads image to storage
  Future<String?> uploadImage() async {
    //if user chose image from gallery -> save the file in storage and return its url
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      var fileRef = storageRef.child('image/${_image!.name}');
      await fileRef.putFile(File(_image!.path));
      return await fileRef.getDownloadURL();
      //if not, url of default image is returned
    } else {
      try {
        return defaultImageUrl;
      } on FirebaseException catch (e) {}
    }
  }

  //This method adds product
  Future<DocumentReference> addProduct(String productName, int productPrice,
      String productDescription, String imageUrl) {
    return FirebaseFirestore.instance
        .collection('product')
        .add(<String, dynamic>{
      'name': productName,
      'price': productPrice,
      'description': productDescription,
      'like': 0,
      'image_url': imageUrl,
      'who_likes': [],
      'created_time': FieldValue.serverTimestamp(),
      'modified_time': FieldValue.serverTimestamp(),
      'user_id': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  final _nameKey = GlobalKey<FormState>(debugLabel: 'product name');
  final _priceKey = GlobalKey<FormState>(debugLabel: 'price name');
  final _descriptionKey = GlobalKey<FormState>(debugLabel: 'description name');

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        actions: [
          TextButton(
              onPressed: () async {
                imageUrl = await uploadImage(); //upload image to storage
                addProduct(
                    _nameController.text,
                    int.parse(_priceController.text),
                    _descriptionController.text,
                    imageUrl!);
                Navigator.pop(context);
              },
              child: Text('Save'))
        ],
      ),
      body: Column(children: <Widget>[
        //if user does not chose image from gallery -> show default image
        if (_image == null)
          FutureBuilder(
              future: downloadDefaultImageUrl(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  defaultImageUrl = snapshot.data;
                  return Image.network(snapshot.data!, width: 300, height: 300);
                } else {
                  return CircularProgressIndicator();
                }
              })
        else
          Container(
            width: 300,
            height: 300,
            child: Image.file(File(_image!.path)),
          ),
        SizedBox(height: 6.0),
        IconButton(
            onPressed: () => getImage(ImageSource.gallery),
            icon: const Icon(Icons.camera)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _nameKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Product name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _priceKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      hintText: 'Product price',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _descriptionKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Product description',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
