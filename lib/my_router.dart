
import 'package:go_router/go_router.dart';
import 'pages/workout_article_list_page.dart';

// GoRouter configuration
final router = GoRouter(

  initialLocation: '/articles',
  routes: [
    GoRoute(
      path: '/articles',
      builder: (context, state) => WorkoutArticleListPage(),
    ),
  ],
);
