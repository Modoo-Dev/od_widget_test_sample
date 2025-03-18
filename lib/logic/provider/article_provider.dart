import 'dart:collection';
import 'package:flutter/material.dart';
import '../../services/article_api_service.dart';
import '../../models/workout_article.dart';

class ArticleProvider extends ChangeNotifier {
  ArticleProvider(this.articleApiService);
  ArticleApiService articleApiService;
  List<WorkoutArticle> _workoutArticleList = [];
  List<WorkoutArticle> get workoutArticleList => UnmodifiableListView(_workoutArticleList);
  String get sample =>'d';
  Future<void> getArticles() async {
    _workoutArticleList=await articleApiService.getArticleData();
    notifyListeners();
  }

}