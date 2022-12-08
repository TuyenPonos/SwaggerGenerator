import 'package:dio/dio.dart';
import 'package:example/auth_interceptor.dart';
import 'package:example/error_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:swagger_generator/swagger_generator.dart';

const baseUrl = 'https://jsonplaceholder.typicode.com';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SwaggerGenerator.instance.initial(
    Swagger(
      id: '1',
      info: const SwaggerInfo(
        title: 'Example API docs',
        version: '1.0.0',
      ),
      servers: const [
        SwaggerServer(
          url: baseUrl,
          description: 'Json placeholder',
        ),
      ],
      components: SwaggerComponent(
        securities: const [
          SwaggerSecurity(
            name: 'Authorization',
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
          ),
        ],
      ),
    ),
    includeResponse: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swagger Generator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Swagger Generator Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Dio _dio;

  @override
  void initState() {
    _dio = Dio()
      ..options.baseUrl = baseUrl
      ..options.contentType = 'application/json'
      ..interceptors.addAll(
        [
          AuthInterceptor(),
          SwaggerInterceptor(),
          ErrorInterceptor(),
        ],
      );
    super.initState();
  }

  Future<void> _fetchPost() async {
    final resp = await _dio.get('/posts/1/comments');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('We have ${(resp.data as List).length} post'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _fetchCommentByPost() async {
    final resp = await _dio.get(
      '/comments?postId=1',
      options: Options(
        extra: {
          'summary': 'Get comments in a post',
          'description': 'Get comments in a post by passing a postId'
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('We have ${(resp.data as List).length} comments in post 1'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _fetchPost();
              },
              child: const Text('Get all posts'),
            ),
            ElevatedButton(
              onPressed: () {
                _fetchCommentByPost();
              },
              child: const Text('Get comments by postId'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SwaggerGenerator.instance.openPreviewPage(context),
        child: const Icon(Icons.window),
      ),
    );
  }
}
