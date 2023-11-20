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


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shrine/product_content.dart';
import 'package:shrine/profile.dart';
import 'package:shrine/user_content.dart';
import 'package:shrine/wish_list.dart';

import 'add.dart';
import 'app_state.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String queryValue = 'Asc';

  UserContent findUserById (String userId, List<UserContent> users) {
    return users.firstWhere(
          (user) => user.id == userId,
      orElse: () => UserContent(id: '', wishList: [])
    );
  }

  List<Card> _buildGridCards(
      BuildContext context, List<ProductContent> products) {
    if (products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return products.map((product) {
      var users = Provider.of<AppState>(context).userContents;
      var user = findUserById(FirebaseAuth.instance.currentUser!.uid, users);
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                AspectRatio(
                    aspectRatio: 18 / 11, child: Image.network(product.imageUrl)),
                Positioned(
                    right: 15,
                    top: 10,
                    child: Icon((user.wishList.contains(product.id))
                        ? Icons.check_circle
                        : null, color: Colors.blue)
                )
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  // TODO: Align labels to the bottom and center (103)
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // TODO: Change innermost Column (103)
                  children: <Widget>[
                    // TODO: Handle overflowing labels (103)
                    Text(
                      product.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      formatter.format(product.price),
                      style: theme.textTheme.titleSmall,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(productId: product.id),
                            ),
                          );
                        },
                        child: Text(
                          "more",
                          style: TextStyle(fontSize: 10.0),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var products = Provider.of<AppState>(context)
        .productContents; //get updated product content from firestore
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.person,
              semanticLabel: 'profile',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          title: const Text('Home'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.shopping_cart,
                semanticLabel: 'shopping cart',
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WishListPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
                semanticLabel: 'add',
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: queryValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  queryValue = value!;
                  setState(() {
                    if (value == 'Asc') {
                      Provider.of<AppState>(context, listen: false).dropdownValue = false;
                    } else {
                      Provider.of<AppState>(context, listen: false).dropdownValue = true;
                    }
                  });
                },
                items: <String>['Asc', 'Desc']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Flexible(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16.0),
                childAspectRatio: 7.0 / 9.0,
                children: _buildGridCards(context, products),
              ),
            )
          ],
        )
        //resizeToAvoidBottomInset: false,
        );
  }
}