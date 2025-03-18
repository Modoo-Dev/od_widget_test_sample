import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/provider/article_provider.dart';

import 'my_router.dart';
import 'services/article_api_service.dart';


void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider(ArticleApiService())),
      ],
      child: MaterialApp.router(
          routerConfig: router,

      ),
    );



  }
}