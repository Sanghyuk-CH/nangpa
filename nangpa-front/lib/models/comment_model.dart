import 'package:nangpa/models/user_model.dart';

class CommentModel {
  final int id;
  final int userId;
  final String contents;
  final int postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel> childComments;
  final int? commentId;
  final UserModel user;

  CommentModel({
    required this.id,
    required this.userId,
    required this.contents,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.childComments,
    required this.user,
    this.commentId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    var commentListJson = json['comments'] as List?;
    List<CommentModel> commentList = commentListJson != null
        ? commentListJson.map((i) => CommentModel.fromJson(i)).toList()
        : [];

    return CommentModel(
        id: json['id'],
        userId: json['user_id'],
        contents: json['contents'],
        postId: json['post_id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        commentId: json['comment_id'],
        childComments: commentList,
        user: UserModel.fromJson(json['user']));
  }
}
