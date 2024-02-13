import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nangpa/config.dart';
import 'package:nangpa/models/comment_model.dart';
import 'package:nangpa/models/ingredient_model.dart';
import 'package:nangpa/models/menu_model.dart';
import 'package:nangpa/models/postfree_model.dart';
import 'package:nangpa/models/user_model.dart';
import 'package:nangpa/services/dio.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/utils/custom_error.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = kReleaseMode ? releaseBaseUrl : debugBaseUrl;
  final Dio _dio = Dio();

  // 모든 재료 추출
  Future<IngredientListModel?> getIngredients() async {
    try {
      final response = await _dio.get('$baseUrl/ingredients/find');
      if (response.statusCode == 200) {
        return IngredientListModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (error) {
      return null;
      // throw Exception('Failed to connect to the API');
    }
  }

  // 모든 레시피 추출
  Future<List<MenuModel>> getMenuList() async {
    List<MenuModel> menuList = [];
    try {
      final response = await _dio.get('$baseUrl/menus/find');
      if (response.statusCode == 200) {
        final List<dynamic> menuJsons = response.data;

        for (var menuJson in menuJsons) {
          menuList.add(MenuModel.fromJson(menuJson));
        }
        return menuList;
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (error) {
      return menuList;
      // throw Exception('Failed to connect to the API');
    }
  }

  Future<MenuModel?> getMenuDetail(int id) async {
    try {
      final response = await _dio.get('$baseUrl/menus/find/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> menuJsons = response.data;
        return MenuModel.fromJson(menuJsons);
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (error) {
      return null;
    }
  }

  // 재료 기반 레시피 추출
  Future<List<SimplifiedMenu>> getMenuByIngredients(
      List<String> ingredientList) async {
    List<SimplifiedMenu> menuList = [];
    try {
      final response = await _dio.post(
        '$baseUrl/menus/by-ingredient',
        data: {'ingredients': ingredientList},
      );
      final List<dynamic> menuJsons = response.data;

      for (var menuJson in menuJsons) {
        menuList.add(SimplifiedMenu.fromJson(menuJson));
      }
      return menuList;
    } catch (error) {
      return menuList;
      // throw Exception('Failed to connect to the API');
    }
  }

  Future<String> getPresignedUrl(String filename) async {
    try {
      final url = '$baseUrl/post/free/presigned-url';
      final response = await _dio.get(url, queryParameters: {
        'filename': filename,
      });
      return response.data['presignedUrl'];
    } catch (error) {
      throw Exception('Failed to connect to the API');
    }
  }

  String _getContentType(String imagePath) {
    final fileExtension = extension(imagePath).toLowerCase();
    switch (fileExtension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.heif':
        return 'image/heif';
      default:
        throw Exception('Unsupported image format');
    }
  }

  String getPublicUrl(String filName) {
    return 'https://attraction-apricity.s3.ap-northeast-2.amazonaws.com/nangpa/$filName';
  }

  Future<void> uploadImage(
      Uint8List imageBytes, String presignedUrl, String imagePath) async {
    final contentType = _getContentType(imagePath); // 이미지 content type 구하기

    try {
      final response = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': contentType,
        },
        body: imageBytes,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to upload image');
    }
  }

  Future<void> createPost(
      String title, List<Map<String, dynamic>> contents) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();

      final response = await customDio.post(
        '$baseUrl/post/free',
        data: {
          'user_name': userProfile.nickname,
          'title': title,
          'contents': contents,
          'user_id': userProfile.id,
          'view_count': 0,
        },
      );
    } catch (error) {
      print(error);
      throw Exception('Failed to connect to the API');
    }
  }

  Future<List<PostModel>> fetchPosts(int page, int row, String category) async {
    try {
      final response = await _dio.get(
        '$baseUrl/post/$category',
        queryParameters: {
          'page': page,
          'row': row,
        },
      );

      return (response.data as List)
          .map((postJson) => PostModel.fromJson(postJson))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch posts: $e");
    }
  }

  Future<PostModel> fetchPost(int id, String category) async {
    try {
      final response = await _dio.get(
        '$baseUrl/post/$category/$id',
      );

      return PostModel.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        String message = e.response?.data?['message'] ?? '';
        int errorCode = e.response?.statusCode ?? 500;
        if (message == '신고된 게시물입니다.') {
          throw CustomException(errorCode, message);
        }
      }
      throw CustomException(500, "게시물을 불러오는데에 실패했습니다.\n 잠시 뒤에 다시 시도해주세요.");
    }
  }

  Future<void> deletePost(int postId, String category) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();

      final response = await customDio.post(
        '$baseUrl/post/$category/$postId',
        data: {
          'user_id': userProfile.id,
        },
      );
    } catch (e) {
      throw Exception("글을 삭제하는 것에 실패했습니다.");
    }
  }

  Future<void> modifyPost(int id, String category, String title,
      List<Map<String, dynamic>> contents) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();

      final response = await customDio.put(
        '$baseUrl/post/free/$id',
        data: {
          'user_id': userProfile.id,
          'title': title,
          'contents': contents,
        },
      );
    } catch (e) {
      print(e);
      throw Exception("Failed to modify post: $e");
    }
  }

  Future<List<CommentModel>> fetchComments(int postId, String category) async {
    try {
      final response = await _dio.get(
        '$baseUrl/comment/$category/$postId',
      );

      return (response.data as List)
          .map((commentJson) => CommentModel.fromJson(commentJson))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch comments: $e");
    }
  }

  Future<void> createComment(
      int postId, String category, String content, int? commentId) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();
      final response = await customDio.post(
        '$baseUrl/comment/$category',
        data: {
          'user_id': userProfile.id,
          'user_name': userProfile.nickname,
          'contents': content,
          'post_id': postId,
          'comment_id': commentId,
        },
      );
    } catch (e) {
      throw Exception("Failed to create comment: $e");
    }
  }

  Future<void> modifyComment(
      int commentId, String category, String content) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();

      final response = await customDio.put(
        '$baseUrl/comment/$category/$commentId',
        data: {
          'user_id': userProfile.id,
          'contents': content,
        },
      );
    } catch (e) {
      throw Exception("Failed to modify comment: $e");
    }
  }

  Future<void> deleteComment(int commentId, String category) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();

      final response = await customDio.post(
        '$baseUrl/comment/$category/$commentId',
        data: {
          'user_id': userProfile.id,
        },
      );
    } catch (e) {
      throw Exception("Failed to modify comment: $e");
    }
  }

  Future<void> createReportPost(
      String category, int postId, String reason) async {
    try {
      Dio customDio = createDio();

      final response =
          await customDio.post('$baseUrl/admin/create-report-post', data: {
        'category': category,
        'post_id': postId,
        'reason': reason,
      });
    } catch (e) {
      throw Exception("Failed to report post: $e");
    }
  }

  Future<void> createReportComment(
      String category, int commentId, String reason) async {
    try {
      Dio customDio = createDio();
      UserModel userProfile = await UserApiService().getUserProfileByPref();

      final response = await customDio.post(
        '$baseUrl/admin/create-report-comment',
        data: {
          'category': category,
          'comment_id': commentId,
          'reason': reason,
        },
      );
    } catch (e) {
      throw Exception("Failed to report comment: $e");
    }
  }
}
