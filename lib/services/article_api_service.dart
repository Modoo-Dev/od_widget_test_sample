import 'package:http/http.dart';
import 'dart:convert';
import '../models/workout_article.dart';
//jhcomment method 구조 변경필요
class ArticleApiService {
  Future<List<WorkoutArticle>> getArticleData() async {
    String requestUrl = 'https://public-api.wordpress.com/rest/v1.1/read/tags/workout/posts';
    try {
      Response response = await get(
        Uri.parse(requestUrl),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return _jsonToWorkoutArticleList(decodedData['posts']); //아직 정의되지 않음
      } else {
        throw Exception('http request failed');
      }
    } catch (e) {
      throw Exception('failed: $e');
    }
  }
  //todo naming 변경
  Future<List<WorkoutArticle>> _jsonToWorkoutArticleList(List<dynamic> posts) async {
    List<WorkoutArticle> articleList = [];
    for (var post in posts) {
      articleList.add(
        WorkoutArticle.fromMap(post),
      );
    }
    return articleList;
    //위 for문은 다음과 같이 한 줄로 표현할 수도 있습니다.
    //return posts.map((post) => WorkoutArticle.fromMap(post)).toList();
  }
}
