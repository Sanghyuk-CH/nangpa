import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nangpa/models/postfree_model.dart';
import 'package:nangpa/screens/community-post_screen.dart';
import 'package:nangpa/screens/postdetail_screen.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/widgets/nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final List<PostModel> _posts = [];
  int _currentPage = 1;
  final int _rowsPerPage = 10;
  bool _isLoading = false;
  bool _hasMorePosts = true;

  @override
  void initState() {
    super.initState();
    _loadMorePosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMorePosts) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newPosts =
          await _apiService.fetchPosts(_currentPage, _rowsPerPage, 'free');
      setState(() {
        if (newPosts.isEmpty) {
          _hasMorePosts = false;
        } else {
          _posts.addAll(newPosts);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('게시물을 불러오는 도중 오류가 발생했습니다, 잠시 뒤에 다시 시도해주세요.')),
      );
    }
  }

  void _onClickPostAddBtn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityPostScreen(),
      ),
    ).then((_) {
      _posts.clear(); // 글 목록을 초기화합니다.
      _currentPage = 1; // 현재 페이지를 1로 재설정합니다.
      _hasMorePosts = true; // 더 많은 게시물이 있다고 가정합니다.
      _loadMorePosts(); // 게시물을 다시 불러옵니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            fontFamily: 'EF_watermelonSalad',
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.post_add,
            ),
            onPressed: () {
              _onClickPostAddBtn(context);
            },
            padding: const EdgeInsets.only(right: 10.0),
            iconSize: 30.0,
          ),
        ],
      ),
      body: _posts.isEmpty
          ? _buildEmptyPostsMessage()
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isLoading &&
                    _hasMorePosts) {
                  _loadMorePosts();
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: _posts.length + (_isLoading ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _posts.length) {
                      return _buildLoader();
                    } else {
                      return _buildPostTile(_posts[index]);
                    }
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildLoader() {
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : const SizedBox();
  }

  Widget _buildEmptyPostsMessage() {
    return const Center(
      child: Text(
        '게시물이 존재하지 않습니다.',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPostTile(PostModel post) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: ListTile(
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(post.user.nickname),
            Row(
              children: [
                const Icon(Icons.visibility, size: 20.0),
                const SizedBox(width: 5.0),
                Text(post.viewCount.toString()),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostFreeDetailScreen(postId: post.id),
            ),
          ).then((_) {
            _posts.clear(); // 글 목록을 초기화합니다.
            _currentPage = 1; // 현재 페이지를 1로 재설정합니다.
            _hasMorePosts = true; // 더 많은 게시물이 있다고 가정합니다.
            _loadMorePosts();
          });
        },
      ),
    );
  }
}
