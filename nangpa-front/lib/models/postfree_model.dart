import 'package:nangpa/models/user_model.dart';

class PostModel {
  final int id;
  final String userName;
  final String title;
  final List<Map<String, dynamic>> contents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final int viewCount;
  final UserModel user;

  PostModel({
    required this.id,
    required this.userName,
    required this.user,
    required this.title,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.viewCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'],
        userName: json['user_name'],
        title: json['title'],
        contents: (json['contents'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        userId: json['user_id'],
        viewCount: json['view_count'],
        user: UserModel.fromJson(json['user']));
  }
}
