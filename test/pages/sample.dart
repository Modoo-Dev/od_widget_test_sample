import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 항상 이미지 로드에 실패하도록 하는 ImageProvider
class FailingImageProvider extends ImageProvider<FailingImageProvider> {
  @override
  Future<FailingImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FailingImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(FailingImageProvider key,  decode) {
    // OneFrameImageStreamCompleter로 에러를 발생시킵니다.
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error('이미지 로드 실패'),
    );
  }
}

void main() {
  testWidgets('errorBuilder 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Image(
            image: FailingImageProvider(),
            errorBuilder: (context, error, stackTrace) {
              return const Text('에러 발생');
            },
          ),
        ),
      ),
    );

    // 비동기 에러 처리가 완료되도록 기다립니다.
    await tester.pumpAndSettle();

    // errorBuilder에 의해 생성된 텍스트 위젯이 존재하는지 확인합니다.
    expect(find.text('에러 발생'), findsOneWidget);
  });
}