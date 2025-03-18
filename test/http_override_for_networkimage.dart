import 'dart:convert';
import 'dart:io';

// Widget createHomeScreen(Widget child) {
//   return MultiProvider(
//     providers: [
//       ChangeNotifierProvider<ArticleProvider>(
//         create: (context) => MockArticleProvider(),
//       ),
//     ],
//     child: MaterialApp(
//       home: child,
//     ),
//   );
// }

//=====================================
/// A custom HttpOverrides that uses our FakeHttpClient.
// class TestHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return FakeHttpClient();
//   }
// }
//
// /// A fake HttpClient that intercepts GET requests.
// class FakeHttpClient implements HttpClient {
//   bool _autoUncompress = true;
//
//   @override
//   bool get autoUncompress => _autoUncompress;
//
//   @override
//   set autoUncompress(bool value) {
//     _autoUncompress = value;
//   }
//
//   @override
//   Future<HttpClientRequest> getUrl(Uri url) async {
//     return FakeHttpClientRequest(url);
//   }
//
//   // You can override other methods (like openUrl) as needed.
//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }
//
// /// A fake HttpClientRequest that immediately returns a FakeHttpClientResponse.
// class FakeHttpClientRequest implements HttpClientRequest {
//   final Uri url;
//   FakeHttpClientRequest(this.url);
//
//   @override
//   Future<HttpClientResponse> close() async {
//     return FakeHttpClientResponse();
//   }
//
//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }
//
// /// A fake HttpClientResponse that provides a dummy 1x1 transparent PNG.
// class FakeHttpClientResponse implements HttpClientResponse {
//   // This byte array represents a minimal 1x1 transparent PNG.
//   final Uint8List _imageData = Uint8List.fromList(
//     <int>[
//       137, 80, 78, 71, 13, 10, 26, 10, // PNG signature
//       0, 0, 0, 13, // IHDR chunk length
//       73, 72, 68, 82, // "IHDR"
//       0, 0, 0, 1, // width: 1
//       0, 0, 0, 1, // height: 1
//       8, // bit depth
//       6, // color type: RGBA
//       0, // compression method
//       0, // filter method
//       0, // interlace method
//       31, 21, 196, 137, // CRC
//       0, 0, 0, 10, // IDAT chunk length
//       73, 68, 65, 84, // "IDAT"
//       120, 156, // zlib header
//       99, 0, 1, 0, 0, 5, 0, 1, // compressed data
//       13, 10, 45, 180, // CRC
//       0, 0, 0, 0, // IEND chunk length
//       73, 69, 78, 68, // "IEND"
//       174, 66, 96, 130, // CRC
//     ],
//   );
//
//   @override
//   int get statusCode => 200;
//
//   @override
//   int get contentLength => _imageData.length;
//
//   @override
//   // Return the image data as a stream.
//   Stream<Uint8List> get listenStrem => Stream<Uint8List>.fromIterable([_imageData]);
//
//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }
