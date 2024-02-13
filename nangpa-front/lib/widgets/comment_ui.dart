import 'package:flutter/material.dart';
import 'package:nangpa/models/comment_model.dart';
import 'package:nangpa/models/user_model.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/services/authentication.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/utils/debounce.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentUI extends StatefulWidget {
  final CommentModel comment;
  final Function(int, String) onSendChildComment;
  final Function(int, String) updateComment;
  final Function(int) deleteComment;
  final bool isChild;
  final String? token;

  const CommentUI({
    super.key,
    required this.comment,
    required this.onSendChildComment,
    required this.isChild,
    required this.updateComment,
    required this.deleteComment,
    required this.token,
  });

  @override
  _CommentUIState createState() => _CommentUIState();
}

class _CommentUIState extends State<CommentUI> {
  bool isReplying = false;
  late final TextEditingController replyController;
  late String timeDifference;
  bool isCurrentUser = false;
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    replyController = TextEditingController();
    DateTime localDateTime =
        widget.comment.createdAt.add(const Duration(hours: 9));
    timeDifference = timeago.format(localDateTime);
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    if (widget.token == null) return;

    try {
      UserModel? user = await UserApiService().getUserProfileByPref();
      if (user.id == widget.comment.userId) {
        setState(() {
          isCurrentUser = true;
        });
      }
    } catch (e) {}
  }

  void _showOptionsModal(BuildContext context) async {
    TextEditingController reportController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentUser)
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('수정'),
                    onTap: () {
                      Navigator.pop(context);
                      // Perform edit/delete action
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final TextEditingController editController =
                                TextEditingController(
                                    text: widget.comment.contents);
                            return AlertDialog(
                              title: const Text("댓글 수정"),
                              content: TextField(
                                controller: editController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '수정할 내용을 입력하세요',
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('취소'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('저장'),
                                  onPressed: () {
                                    _debouncer.run(() {
                                      widget
                                          .updateComment(widget.comment.id,
                                              editController.text)
                                          .then((_) {
                                        Navigator.of(context).pop();
                                      });
                                    });
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                if (isCurrentUser)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('삭제'),
                    onTap: () async {
                      Navigator.pop(context);
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('정말로 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              child: const Text('아니요'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text('예'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await widget.deleteComment(widget.comment.id);
                        } catch (e) {
                          // Handle the error here. For example, show a SnackBar with the error message.
                        }
                      }
                    },
                  ),
                if (!isCurrentUser)
                  ListTile(
                    leading: const Icon(Icons.report),
                    title: const Text('신고'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('댓글 신고'),
                            content: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: reportController,
                                    decoration: const InputDecoration(
                                      labelText: '신고 사유',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.length < 10) {
                                        return '10자 이상 입력해주세요';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('신고하기'),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    _debouncer.run(() {
                                      // Call report API
                                      ApiService()
                                          .createReportComment(
                                        'free', // replace with the actual category
                                        widget.comment.id,
                                        reportController.text,
                                      )
                                          .then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('신고가 접수되었습니다.'),
                                        ));
                                      }).catchError((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('신고 접수에 실패했습니다.'),
                                        ));
                                      });
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkUserAndShowModal() async {
    await _checkCurrentUser();
    _showOptionsModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: widget.comment.user.profileImgUrl != null
                          ? NetworkImage(
                              widget.comment.user.profileImgUrl!,
                            ) as ImageProvider<Object>
                          : const AssetImage(
                              'assets/images/default-user-image.png'),
                      radius: 13,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.comment.user.nickname} · ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeDifference,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (widget.token != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _checkUserAndShowModal();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(widget.comment.contents),
            const SizedBox(height: 10.0),
            if (!widget.isChild)
              TextButton(
                child: const Text('대댓글 작성'),
                onPressed: () {
                  if (widget.token == null) {
                    checkLoginStatus(context, () {});
                  } else {
                    setState(() {
                      isReplying = true;
                    });
                  }
                },
              ),
            if (isReplying)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController, // 대댓글 컨트롤러 연결
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '대댓글을 입력하세요',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _debouncer.run(() {
                        widget.onSendChildComment(
                            widget.comment.id, replyController.text); // 대댓글 전송
                        setState(() {
                          isReplying = false;
                          replyController.clear();
                        });
                      });
                    },
                  ),
                ],
              ),
            for (var reply in widget.comment.childComments)
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: CommentUI(
                  comment: reply,
                  onSendChildComment: widget.onSendChildComment,
                  isChild: true,
                  updateComment: widget.updateComment,
                  deleteComment: widget.deleteComment,
                  token: widget.token,
                ), // 대댓글을 표시할 때는 reply 변수를 사용합니다.
              ),
          ],
        ),
      ),
    );
  }
}
