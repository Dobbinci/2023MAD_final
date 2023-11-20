
/*This class get contents from firestore collection 'user'*/
class UserContent {
  UserContent({required this.id, required this.wishList});

  final String id;
  final List<dynamic> wishList;
}