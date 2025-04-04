import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../logic/provider/article_provider.dart';
import '../models/workout_article.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutArticleListPage extends StatefulWidget {
  const WorkoutArticleListPage({super.key});

  @override
  State<WorkoutArticleListPage> createState() => _WorkoutArticleListPageState();
}

class _WorkoutArticleListPageState extends State<WorkoutArticleListPage> {
  @override
  void initState() {
    Provider.of<ArticleProvider>(context, listen: false).getArticles();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article'),
      ),
      body: Consumer<ArticleProvider>(builder: (context, articleProvider, child) {
        final articles = articleProvider.workoutArticleList;

        if (articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];

            return Card(
              key: Key('card-$index'),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  //이동 action 처리
                  final url = article.postURL;

                  if (url.isNotEmpty) {
                    launchUrl(Uri.parse(article.postURL));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        article.thumbnailURL,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/me.jpg',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(article.avatarURL),
                                radius: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  article.authorName,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${article.postDate.year}-${article.postDate.month.toString().padLeft(2, '0')}-${article.postDate.day.toString().padLeft(2, '0')} ',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            article.postTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            parse(article.postExcerpt).documentElement?.text??'',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 5.0,
                            runSpacing: -8.0,
                            children: article.postTag.take(3)
                                .map(
                                  (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSecondary,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
