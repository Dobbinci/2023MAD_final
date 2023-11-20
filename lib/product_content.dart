
/*This class get user contents from firestore collection 'user'*/
class ProductContent{
  ProductContent({required this.id, required this.name, required this.price,
    required this.description, required this.like, required this.imageUrl, required this.whoLikes,
  required this.createdTime, required this.modifiedTime, required this.userId});

  final String id;
  final String name;
  final int price;
  final String description;
  final int like;
  final String imageUrl;
  final List<dynamic> whoLikes;
  final String createdTime;
  final String modifiedTime;
  final String userId;
}