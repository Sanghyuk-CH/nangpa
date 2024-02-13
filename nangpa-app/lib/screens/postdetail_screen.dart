import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:nangpa/models/postfree_model.dart';
import 'package:nangpa/models/user_model.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/utils/custom_error.dart';
import 'package:nangpa/widgets/comment.dart';

import '../utils/debounce.dart';

class PostFreeDetailScreen extends StatefulWidget {
  final int postId;

  const PostFreeDetailScreen({Key? key, required this.postId})
      : super(key: key);

  @override
  _PostFreeDetailScreenState createState() => _PostFreeDetailScreenState();
}

class _PostFreeDetailScreenState extends State<PostFreeDetailScreen> {
  late Future<PostModel?> _post;
  bool _isEnabledEdit = false;
  late bool _isEdit;
  late String _title;
  bool _isSubmitting = false;
  late List<dynamic> _contents;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode quillFocusNode = FocusNode();

  late final TextEditingController titleController =
      TextEditingController(text: _title);
  late final QuillController controller = QuillController(
    document: Document.fromJson(_contents
        .map<Map<String, dynamic>>((dynamic e) => e as Map<String, dynamic>)
        .toList()),
    selection: const TextSelection.collapsed(offset: 0),
  );

  TextEditingController reportController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _post = _fetchPost();
    _fetchUserProfile();
    _isEdit = false;
  }

  // 게시글 수정은 본인만 가능하므로 자신의 프로밀을 불러와서 게시글의 user_id와 비교하는 로직 필요.
  Future<void> _fetchUserProfile() async {
    try {
      final post = await _post;
      if (post == null) return;
      UserModel userProfile = await UserApiService().getUserProfileByPref();
      if ((post.userId == userProfile.id)) {
        setState(() {
          _isEnabledEdit = true;
        });
      }
    } catch (e) {}
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류 발생'),
          content: const Text('회원정보를 불러오는데 실패했습니다. 잠시 후에 시도해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<PostModel?> _fetchPost() async {
    try {
      final result = await ApiService().fetchPost(widget.postId, 'free');
      _title = result.title;
      _contents = result.contents;
      return result;
    } catch (e) {
      String message = '글을 불러오는데에 실패했습니다.';

      if (e is CustomException) {
        message = e.message;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('주의!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
      Navigator.pop(context);
    }
    return null;
  }

  Future<void> _deletePost(BuildContext constext) async {
    try {
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
        await ApiService().deletePost(widget.postId, 'free');
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          content: const Text('글이 성공적으로 삭제되었습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      String message = '글을 삭제하는 것에 실패했습니다.';

      if (e is CustomException) {
        message = e.message;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _reportPost(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시물 신고'),
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
                    if (value == null || value.isEmpty || value.length < 10) {
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
                        .createReportPost(
                      'free', // replace with the actual category
                      widget.postId,
                      reportController.text,
                    )
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('신고가 접수되었습니다.'),
                      ));
                    }).catchError((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
  }

  onModifyPostSendBtn(context) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final content = controller.document.toDelta().toJson();
    final plainTextContent = controller.document.toPlainText();
    final title = titleController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );

      setState(() {
        _isSubmitting = false; // 추가: 완료 버튼 동작 종료
      });

      return;
    }

    if (content.isEmpty || plainTextContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글 내용을 입력해주세요')),
      );

      setState(() {
        _isSubmitting = false; // 추가: 완료 버튼 동작 종료
      });

      return;
    }

    try {
      final post = (await _post);
      if (post == null) return;
      await ApiService().modifyPost(
        post.id,
        'free',
        title,
        content as List<Map<String, dynamic>>,
      );

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('성공'),
          content: const Text('글 수정이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );

      setState(
        () => {
          _isEdit = false,
          quillFocusNode.unfocus(),
        },
      );
    } catch (e) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글 작성 중 오류가 발생했습니다')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // 추가: 완료 버튼 동작 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('게시물 상세'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (_isEnabledEdit)
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () => {_deletePost(context)},
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          if (_isEnabledEdit)
            if (!_isEdit)
              IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => {
                        setState(() => {
                              _isEdit = true,
                              quillFocusNode.requestFocus(),
                            })
                      },
                  icon: const Icon(Icons.edit))
            else
              IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => {
                        onModifyPostSendBtn(context),
                      },
                  icon: const Icon(Icons.send)),
          if (!_isEnabledEdit)
            IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => {_reportPost(context)},
                icon: const Icon(Icons.report))
        ],
      ),
      body: FutureBuilder<PostModel?>(
        future: _post,
        builder: (BuildContext context, AsyncSnapshot<PostModel?> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    _buildPostDetails(snapshot.data!),
                    const SizedBox(height: 40),
                    Comment(postId: snapshot.data!.id)
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildPostDetails(PostModel post) {
    void _handleFocusChange(bool hasFocus) {
      if (!hasFocus) {
        setState(() => {
              _title = titleController.text,
              _contents = controller.document.toDelta().toJson()
            });
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEdit)
            Focus(
              onFocusChange: _handleFocusChange,
              child: TextField(
                focusNode: titleFocusNode,
                controller: titleController,
              ),
            ),
          if (!_isEdit)
            Text(
              _title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 16.0),
          Text(
            '작성자: ${post.user.nickname}',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24.0),
          QuillEditor(
            showCursor: _isEdit,
            controller: controller,
            readOnly: !_isEdit,
            autoFocus: false,
            focusNode: quillFocusNode,
            expands: false,
            padding: EdgeInsets.zero,
            scrollController: ScrollController(),
            scrollable: true,
            embedBuilders: [...FlutterQuillEmbeds.builders()],
          ),
        ],
      ),
    );
  }
}
