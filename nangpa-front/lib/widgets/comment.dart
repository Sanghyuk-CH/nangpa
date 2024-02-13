import 'package:flutter/material.dart';
import 'package:nangpa/models/comment_model.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/services/authentication.dart';
import 'package:nangpa/token_key.dart';
import 'package:nangpa/utils/debounce.dart';
import 'package:nangpa/widgets/comment_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 추가

class Comment extends StatefulWidget {
  final int postId;
  const Comment({super.key, required this.postId});

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  late Future<List<CommentModel>> _comments;
  final TextEditingController commentController = TextEditingController();
  String? token;

  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _getToken();
    _comments = _fetchComments();
  }

  Future<List<CommentModel>> _fetchComments() async {
    return ApiService().fetchComments(widget.postId, 'free');
    // 댓글 데이터를 서버에서 불러오는 로직 구현
  }

  void _getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString(TokenKey.AUTH_TOKEN_KEY);
    });
  }

  // 댓글 전송을 위한 함수
  void _sendComment() async {
    if (commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 입력해주세요')),
      );
      return;
    }

    try {
      await ApiService()
          .createComment(widget.postId, 'free', commentController.text, null);

      // Clear the input field.
      commentController.clear();

      // Optionally, refresh the list of comments.
      setState(() {
        _comments = _fetchComments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 전송에 실패했습니다. 잠시 뒤에 다시 시도하세요.')),
      );
    }
  }

  // 대댓글 전송을 위한 함수
  void _sendChildComment(int parentCommentId, String commentText) async {
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 입력해주세요')),
      );
      return;
    }

    try {
      await ApiService()
          .createComment(widget.postId, 'free', commentText, parentCommentId);

      // Optionally, refresh the list of comments.
      setState(() {
        _comments = _fetchComments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 전송에 실패했습니다. 잠시 뒤에 다시 시도하세요.')),
      );
    }
  }

  void _updateComment(int commentId, String commentText) async {
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글에 1글자 이상 입력해주세요.')),
      );
      return;
    }

    try {
      await ApiService().modifyComment(commentId, 'free', commentText);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('댓글이 수정되었습니다.'),
      ));

      // Optionally, refresh the list of comments.
      setState(() {
        _comments = _fetchComments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 수정에 실패했습니다. 잠시 뒤에 다시 시도하세요.')),
      );
    }
  }

  void _deleteComment(int commentId) async {
    try {
      await ApiService().deleteComment(commentId, 'free');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('댓글이 삭제 되었습니다.'),
      ));

      setState(() {
        _comments = _fetchComments();
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 삭제에 실패했습니다. 잠시 뒤에 다시 시도하세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCommentInputSection(),
        _buildCommentsSection(),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return FutureBuilder<List<CommentModel>>(
      future: _comments,
      builder:
          (BuildContext context, AsyncSnapshot<List<CommentModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Text('댓글이 존재하지 않습니다.');
          }
          return ListView.separated(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return CommentUI(
                comment: snapshot.data![index],
                onSendChildComment: _sendChildComment,
                isChild: false,
                updateComment: _updateComment,
                deleteComment: _deleteComment,
                token: token,
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Text('댓글을 불러오는데 오류가 발생했습니다.');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCommentInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                controller: commentController, // 컨트롤러 연결
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '댓글을 입력하세요',
                ),
                onTap: () {
                  checkLoginStatus(context, () {});
                }),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _debouncer.run(_sendComment);
            },
          ),
        ],
      ),
    );
  }
}
