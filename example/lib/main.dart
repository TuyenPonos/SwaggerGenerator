import 'package:dio/dio.dart';
import 'package:example/auth_interceptor.dart';
import 'package:example/error_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:swagger_generator/swagger_generator.dart';

void main() {
  SwaggerGenerator.instance.initial(
    Swagger(
      id: '1',
      info: const SwaggerInfo(
        title: 'Example API docs',
        version: '1.0.0',
      ),
      servers: const [
        SwaggerServer(
          url: 'https://example.swagger-test/api/v1',
          description: 'Test',
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
          SwaggerSecurity(
            name: 'Device-Type',
            type: 'apiKey',
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
      ..options.baseUrl = 'https://example.swagger-test/api/v1'
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

  void _incrementCounter() {
    _dio.get('/profile');
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
          children: const [
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
