import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/utils/debounce.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';

class MyEditor extends StatefulWidget {
  const MyEditor({Key? key}) : super(key: key);

  @override
  _MyEditorState createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  late quill.QuillController _controller;
  bool _isSubmitting = false;
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();

  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _titleController.dispose(); // 추가
    super.dispose();
  }

  _onCreatePostBtn(BuildContext context) async {
    if (_isSubmitting) return; // 추가: 이미 제출 중이면 반환하여 중복 제출을 방지

    setState(() {
      _isSubmitting = true; // 추가: 완료 버튼 동작 시작
    });

    // 작성한 글의 제목과 내용을 가져옴
    final content = _controller.document.toDelta().toJson();
    final plainTextContent = _controller.document.toPlainText();
    final title = _titleController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );

      setState(() {
        _isSubmitting = false; // 추가: 완료 버튼 동작 종료
      });

      return;
    }
    // 작성한 글이 비어있는지 확인
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
      // 글 작성 API 호출
      await ApiService()
          .createPost(title, content as List<Map<String, dynamic>>);

      // 글 작성이 완료되면 이전 화면으로 이동
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('성공'),
          content: const Text('글 작성이 완료되었습니다.'),
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
          title: const Text(
            '글쓰기',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'EF_watermelonSalad',
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          actions: [
            ElevatedButton(
              onPressed: () {
                _debouncer.run(() {
                  _onCreatePostBtn(context);
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromRGBO(28, 176, 121, 1),
                ),
              ),
              child: const Text(
                '완료',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController, // 추가
              decoration: const InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: quill.QuillToolbar.basic(
              controller: _controller,
              // customButtons: [
              //   quill.QuillCustomButton(
              //       icon: Icons.image,
              //       onTap: () {
              //         _insertImage();
              //       }),
              // ]
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(_editorFocusNode);
                },
                child: SingleChildScrollView(
                  child: quill.QuillEditor(
                    controller: _controller,
                    scrollController: ScrollController(),
                    scrollable: true,
                    focusNode: _editorFocusNode,
                    autoFocus: true,
                    readOnly: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                    showCursor: true,
                    embedBuilders: [
                      ...FlutterQuillEmbeds.builders(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertImage,
        child: const Icon(Icons.image),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    if (await Permission.photos.status.isDenied) {
      await Permission.photos.request();
    }
  }

  Future<void> _insertImage() async {
    await _requestPermissions();

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // 이미지 압축
        final compressedBytes = await _compressImage(pickedFile.path);

        // 서버에 이미지 업로드
        final apiService = ApiService();
        final filename = basename(pickedFile.path);
        final presignedUrl = await apiService.getPresignedUrl(filename);
        await apiService.uploadImage(
            compressedBytes, presignedUrl, pickedFile.path);

        final publicUrl = apiService.getPublicUrl(filename);

        // Quill 에디터에 이미지 삽입
        final index = _controller.selection.baseOffset;
        final delta = quill.Delta()
          ..retain(index)
          ..insert({'image': publicUrl});
        _controller.compose(
            delta, _controller.selection, quill.ChangeSource.LOCAL);
      }
    } catch (e) {
      // 이미지 로드 에러
      print('Image Load Error');
      print(e);
    }
  }

  Future<Uint8List> _compressImage(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 800,
      minHeight: 600,
      quality: 85,
    );
  }
}
