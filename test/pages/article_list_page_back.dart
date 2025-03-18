import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:od_widget_test/logic/provider/article_provider.dart';
import 'package:od_widget_test/models/workout_article.dart';
import 'package:od_widget_test/pages/workout_article_list_page.dart';
import 'package:od_widget_test/services/article_api_service.dart';

import '../database/article_api_dummy.dart';
import '../http_override_for_networkimage.dart';


import 'article_list_page.mocks.dart';

final mockHttpClient = MockHttpClient();
// Custom ImageProvider that always fails.
class FailingImageProvider extends ImageProvider<FailingImageProvider> {
  @override
  Future<FailingImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FailingImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(FailingImageProvider key,  decode) {
    // Return a completer that fails.
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error('Failed to load image'),
    );
  }
}
class MockHttpOverrides extends HttpOverrides {
  MockHttpOverrides();
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return mockHttpClient;
  }
}

// 예시로 1x1 투명 PNG 데이터를 반환합니다.
final List<int> fakeImageData = <int>[
  137, 80, 78, 71, 13, 10, 26, 10, // PNG signature
  0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0,
  31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0,
  1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68,
  174, 66, 96, 130,
];
final fakeResponseBody = utf8.encode(
  jsonEncode(
    {
      "imageName": "sample.png",
      "imageData": fakeImageData,
    },
  ),
);

void main() {
  setUp(() {
    HttpOverrides.global = MockHttpOverrides();
    final request = MockHttpClientRequest();
    final response = MockHttpClientResponse();

    //when(mockHttpClient.getUrl(any)).thenAnswer((_) => Future.value(request));
    when(mockHttpClient.getUrl(any)).thenAnswer((invocation) {


      //final url = invocation.positionalArguments[0] as Uri;
      // if(url.host.isEmpty){
      //   when(request.close()).thenThrow(Exception());
      // }else{
      //
      // }

      final body = fakeResponseBody;

      when(request.close()).thenAnswer((_) => Future.value(response));
      //when(request.addStream(any)).thenAnswer((_) async => null);
      when(response.headers).thenReturn(MockHttpHeaders());
      //when(response.handleError(any, test: anyNamed('test'))).thenAnswer((_) => Stream.value(body));
      //when(response.statusCode).thenReturn(200);
      //when(response.reasonPhrase).thenReturn('OK');
      when(response.contentLength).thenReturn(body.length);
      when(response.isRedirect).thenReturn(false);

      when(response.persistentConnection).thenReturn(false);
      return Future.value(request);
    });
  });

  testWidgets('NetworkImage가 정상적으로 로드되는지 확인', (WidgetTester tester) async {
    final mockArticleProvider = MockArticleProvider();
    final dummyArticles = List.generate(
      10,
      (index) {
        int i=index%2;
        return WorkoutArticle.fromMap(dummy['posts'][i]);
      },
    );
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ArticleProvider>(
            create: (_) => mockArticleProvider,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<ArticleProvider>(builder: (context, articleProvider, child) {
              final articles = articleProvider.workoutArticleList;

              if (articles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  Expanded(
                    child: Text('111'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: dummyArticles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Card(
                          key: Key('card-$index'),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.network(
                            article.thumbnailURL,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Image.asset(
                                'assets/me.jpg',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
    // 네트워크 호출 후 이미지가 로드될 시간을 줌
    await tester.pumpAndSettle();


    //expect(find.byType(Text), findsOneWidget);
    // Card 위젯이 화면에 있는지 확인
    expect(find.byType(Card), findsNWidgets(10));

    final invalidThumbnailDummyCount=dummyArticles.where((article) => article.thumbnailURL == '').length;
    final vaildThumbnailDummyCount=dummyArticles.length-dummyArticles.where((article) => article.thumbnailURL == '').length;


    //dummy data를 기준으로 NetworkImage가 잘 나오는지 확인,
    // expect(
    //   find.byWidgetPredicate(
    //     (widget) => widget is Image && widget.image is NetworkImage,
    //   ),
    //   findsNWidgets(10),
    // );

    // //dummy data를 기준으로 ErrorBuilder에 의해 AssetImage 잘 나오는지 확인,
    expect(
      find.byWidgetPredicate(
            (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsNWidgets(10),
    );

  });
  // tearDown(() {
  //   HttpOverrides.global = null;
  // });
  // testWidgets('10개의 Card widget이 출력된다.', (WidgetTester tester) async {
  //   // Create an instance of the mock provider.
  //   final mockArticleProvider = MockArticleProvider();
  //   //
  //   // // Stub 생성, 10개의 dummy model 객체 만들어서 provider의 workoutArticleList 변수에 저장
  //   final dummyArticles = List.generate(
  //     10,
  //     (index) => WorkoutArticle.fromMap(dummy['posts'][0]),
  //   );
  //   when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
  //
  //   await tester.pumpWidget(
  //     MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider<ArticleProvider>(
  //           create: (_) => mockArticleProvider,
  //         ),
  //       ],
  //       child: MaterialApp(
  //         home: WorkoutArticleListPage(),
  //       ),
  //     ),
  //   );
  //   // Wait for the widget tree to settle.
  //   await tester.pumpAndSettle();
  //
  //   // Verify that exactly 10 Card widgets are found.
  //   expect(find.byType(Card), findsNWidgets(10));
  // });
}
