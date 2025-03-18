import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:od_widget_test/logic/provider/article_provider.dart';
import 'package:od_widget_test/models/workout_article.dart';
import 'package:http/http.dart' as http;
import 'package:od_widget_test/pages/workout_article_list_page.dart';

import '../database/article_api_dummy.dart';
@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<HttpClientRequest>(),
  MockSpec<HttpClientResponse>(),
  MockSpec<HttpHeaders>(),
  MockSpec<ArticleProvider>(),
])
import 'article_list_page.mocks.dart';
// 예시로 1x1 투명 PNG 데이터를 반환합니다.
final List<int> fakeImageData = <int>[
  137, 80, 78, 71, 13, 10, 26, 10, // PNG signature
  0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0,
  31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0,
  1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68,
  174, 66, 96, 130,
];

class MockImageHttpClient {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();
  final MockHttpHeaders headers = MockHttpHeaders();


// Returns a mock HTTP client that responds with a blank image to all requests.
  MockHttpClient getClient() {
    when(client.getUrl(any)).thenAnswer((_) => Future<HttpClientRequest>.value(request));
    when(request.headers).thenReturn(headers);
    when(request.close()).thenAnswer((_) => Future<HttpClientResponse>.value(response));
    when(response.contentLength).thenReturn(fakeImageData.length);
    //when(response.statusCode).thenReturn(HttpStatus.forbidden);
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.listen(any)).thenAnswer((Invocation invocation) {
      final void Function(List<int>) onData = invocation.positionalArguments[0];
      final void Function() onDone = invocation.namedArguments[#onDone];
      final void Function(Object, [StackTrace]) onError = invocation.namedArguments[#onError];
      final bool cancelOnError = invocation.namedArguments[#cancelOnError];

      return Stream<List<int>>.fromIterable(<List<int>>[fakeImageData])
          .listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
    });

    return client;
  }
}

class MockHttpOverrides extends HttpOverrides {
  MockHttpClient mockHttpClient;
  MockHttpOverrides(this.mockHttpClient);
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return mockHttpClient;
  }
}

MockImageHttpClient sampleHttp=MockImageHttpClient();
void main() {

  late MockArticleProvider mockArticleProvider;
  late List<WorkoutArticle> dummyArticles;
  setUp(() {
    mockArticleProvider = MockArticleProvider();
    dummyArticles = List.generate(
      10,
      (index) {
        int i = index % 2;
        return WorkoutArticle.fromMap(dummy['posts'][i]);
      },
    );
    HttpOverrides.global =MockHttpOverrides(sampleHttp.getClient());
  });

  testWidgets('NetworkImage 성공', (WidgetTester tester) async {
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    when(sampleHttp.response.statusCode).thenReturn(HttpStatus.forbidden);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ArticleProvider>(
            create: (_) => mockArticleProvider,
          ),
        ],
        // child: MaterialApp(
        //   home: Image.network(
        //     key: Key('networkWidget'),
        //     //article.thumbnailURL,
        //     'https://www.python.org/static/apple-touch-icon-144x144-precomposed.png',
        //     //height: 180,
        //     width: double.infinity,
        //     fit: BoxFit.cover,
        //     errorBuilder: (_, __, ___) {
        //       return Image.asset(
        //         key: Key('assetWidget'),
        //         'assets/me.jpg',
        //       );
        //     },
        //   ),
        // ),
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    // 네트워크 호출 후 이미지가 로드될 시간을 줌
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsNWidgets(10),
    );
    expect(
      find.byWidgetPredicate(
            (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsNWidgets(10),
    );
    // expect(
    //   find.byKey(Key('networkWidget')),
    //   findsNWidgets(1),
    // );
    // expect(
    //   find.byKey(Key('assetWidget')),
    //   findsNWidgets(1),
    // );
  });

}
