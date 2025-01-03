import 'package:flutterblockit/di/api/post_service.dart';
import 'package:flutterblockit/di/db/entity/post_entity.dart';
import 'package:flutterblockit/di/db/post_repo.dart';
import 'package:flutterblockit/utils/data_snapshot.dart';

class PostsUseCase {
  final PostApi _api;
  final PostRepo _repo;

  PostsUseCase(
    this._api,
    this._repo,
  );

  Future<DataSnapshot<List<PostEntity>>> loadPosts() async {
    try {
      final posts = await _api.getPosts();
      if (posts.isNotEmpty) {
        await _repo.clear();
        await _repo.insert(posts.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      //TODO: report analytics
    }
    final cache = await _repo.get();
    return DataSnapshot.data(cache);
  }

    Future<DataSnapshot<PostEntity>> getByUrl(String url) async {
    final cache = await _repo.getByUrl(url);
    if (cache == null) {
      return DataSnapshot.error("Post not found");
    }
    return DataSnapshot.data(cache);
  }
}
