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
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import '../database/article_api_dummy.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<HttpClientRequest>(),
  MockSpec<HttpClientResponse>(),
  MockSpec<HttpHeaders>(),
  MockSpec<FakeUrlLauncherPlatform>(),
  MockSpec<ArticleProvider>(),
])
import 'article_list_page.mocks.dart';

class FakeUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}


class MockImageHttpClient {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();


  MockImageHttpClient(){
    when(client.getUrl(any)).thenAnswer((_) => Future<HttpClientRequest>.value(request));
    when(request.close()).thenAnswer((_) => Future<HttpClientResponse>.value(response));
    when(response.statusCode).thenReturn(HttpStatus.ok);
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

void main() {

  late MockArticleProvider mockArticleProvider;
  late List<WorkoutArticle> dummyArticles;
  MockImageHttpClient mockImageHttpClient=MockImageHttpClient();

  setUp(() {
    mockArticleProvider = MockArticleProvider();
    dummyArticles = List.generate(10, (index) => WorkoutArticle.fromMap(dummy['posts'][0]));

    HttpOverrides.global =MockHttpOverrides(mockImageHttpClient.client);
  });


  testWidgets('ListView widget이 잘 나타나는지 확인', (WidgetTester tester) async {
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Thumbnail image가  잘 나오는지 확인', (WidgetTester tester) async {
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsAny);
  });

  testWidgets('Profile image가 CircleAvatar widget을 이용하고, radius 18인지 확인', (WidgetTester tester) async {
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final CircleAvatar profile=tester.widget(find.byType(CircleAvatar).last);

    expect(profile.radius, equals(18));
  });

  testWidgets('Title 길이가 길때 overflow없는지 확인', (WidgetTester tester) async {
    List<WorkoutArticle> longTitleDummyArticles=[...dummyArticles];
    when(mockArticleProvider.workoutArticleList).thenAnswer((_){

      longTitleDummyArticles.first.postTitle='개인적으로 판단하기에 첫 프레임을 16ms 안에 얻는게 개행을 적용하는것보다 훨씬 중요했기 때문에 ‘정석’ 방식인 Character 처리를 포기했고, String 만을 이용해 처리하는 방식을 채택했습니다.';
      return longTitleDummyArticles;
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final titleFinder = find.text(longTitleDummyArticles.first.postTitle);
    final Text title=tester.widget(titleFinder);
    expect(titleFinder, findsOneWidget);
    expect(title.maxLines, equals(2));
    expect(title.overflow, equals(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Date는 0000-00-00 format으로 출력되는지 확인', (WidgetTester tester) async {
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final dateFinder = find.descendant(
      of: find.byType(Row),
      matching: find.byType(Text).last,
    );
    final Iterable<Text> dateWidgetList=tester.widgetList<Text>(dateFinder);
    for(Text date in dateWidgetList){
      final String actualText = date.data ?? '';
      final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      expect(dateRegex.hasMatch(actualText), isTrue, reason: '날짜 형식이 올바르지 않습니다.$actualText');
    }
  });

  testWidgets('contents길이가 길때 overflow없는지 확인', (WidgetTester tester) async {
    List<WorkoutArticle> longTitleDummyArticles=[...dummyArticles];
    when(mockArticleProvider.workoutArticleList).thenAnswer((_){
      longTitleDummyArticles.first.postExcerpt ='화면에 그려지는 텍스트에 다양한 효과를 적용하기 위한 속성들을 지정하는 데에 사용된다.      글자색, 배경색, 글자체, 글자 크기, 폰트 종류 등 다양한 그래픽적 효과를 지정할 수 있다.      Text 나 RichText 등 Text 를 처리하는 class 의  style 속성에 사용된다.';
      return longTitleDummyArticles;
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final contentFinder = find.text(longTitleDummyArticles.first.postExcerpt);
    final Text content=tester.widget(contentFinder);
    expect(contentFinder, findsOneWidget);
    expect(content.maxLines, equals(2));
    expect(content.overflow, equals(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tag가 화면 width 에따라 Responsive 하게 배치되는지 확인', (WidgetTester tester) async {
    List<WorkoutArticle> longTagDummyArticles=[...dummyArticles];
    when(mockArticleProvider.workoutArticleList).thenAnswer((_){
      longTagDummyArticles.first.postTag=['웨이트트레이닝','집에서 혼자 따라하는 트레이닝, 집에서 혼자 따라하는 트레이닝, 집에서 혼자 따라하는 트레이닝','헬스','운동','근육운동','다이어트','운동기록','유산소'];
      return longTagDummyArticles;
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final tagFinder = find.descendant(
      of: find.byType(Wrap).first,
      matching: find.byType(Chip),
    );
    expect(tagFinder, findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });


  testWidgets('Article영역 전체 click되는지 확인', (WidgetTester tester) async {

    final MockFakeUrlLauncherPlatform mockUrlLauncherPlatform = MockFakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncherPlatform;

    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    when(mockUrlLauncherPlatform.launchUrl(dummyArticles.first.postURL,any),).thenAnswer((_) async => true);


    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    verify(
      mockUrlLauncherPlatform.launchUrl(dummyArticles.first.postURL,any),
    ).called(1);
  });

  testWidgets('ListView scroll 확인', (WidgetTester tester) async {
    List<WorkoutArticle> longTitleDummyArticles=[...dummyArticles];
    when(mockArticleProvider.workoutArticleList).thenAnswer((_){
      for (int i = 0; i < longTitleDummyArticles.length; i++) {
        longTitleDummyArticles[i].postTitle = '${i+1}';
      }
      return longTitleDummyArticles;
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final TestGesture gesture = await tester.startGesture(const Offset(0.0, 500.0));
    await gesture.moveBy(const Offset(0.0, -400));

    await tester.pumpAndSettle();
    final titleFinder = find.text(longTitleDummyArticles[2].postTitle);
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('Thumbnail image가 없을시 default image가 잘 나오는지 확인', (WidgetTester tester) async {
    when(mockArticleProvider.workoutArticleList).thenReturn(dummyArticles);
    when(mockImageHttpClient.client.getUrl(Uri.parse(
        'https://0.gravatar.com/avatar/32d9af9c7f55b4d77ca26c7169447cc5dff4564a85e0de91d458ba6e6bec0246?s=96&d=identicon&r=G'
    ))).thenAnswer((_) async {
      final MockHttpClientRequest request = MockHttpClientRequest();
      final MockHttpClientResponse response = MockHttpClientResponse();

      when(request.close()).thenAnswer((_) => Future<HttpClientResponse>.value(response));
      when(response.statusCode).thenReturn(HttpStatus.ok);

      return request;
    });

    when(mockImageHttpClient.client.getUrl(Uri.parse(
        'https://thefatlossfactorycom.wordpress.com/wp-content/uploads/2025/02/pexels-photo-1092730.jpeg'
    ))).thenAnswer((_) async {
      final MockHttpClientRequest request = MockHttpClientRequest();
      final MockHttpClientResponse response = MockHttpClientResponse();

      when(request.close()).thenAnswer((_) => Future<HttpClientResponse>.value(response));
      when(response.statusCode).thenReturn(HttpStatus.forbidden);

      return request;
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
            (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsNWidgets(2),
    );
  });
  testWidgets('10개의 Article이 잘 출력되는지 확인', (WidgetTester tester) async {
    List<WorkoutArticle> longTitleDummyArticles=[...dummyArticles];
    when(mockArticleProvider.workoutArticleList).thenAnswer((_){
      for (int i = 0; i < longTitleDummyArticles.length; i++) {
        longTitleDummyArticles[i].postTitle = '${i+1}';
      }
      return longTitleDummyArticles;
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleProvider>(
        create: (_) => mockArticleProvider,
        child: MaterialApp(
          home: WorkoutArticleListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final TestGesture gesture = await tester.startGesture(const Offset(0.0, 500.0));
    await gesture.moveBy(const Offset(0.0, -5000));


    await tester.pumpAndSettle();
    final titleFinder = find.text(longTitleDummyArticles[9].postTitle);
    expect(titleFinder, findsOneWidget);

  });
}
