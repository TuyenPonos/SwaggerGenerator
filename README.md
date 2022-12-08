The `swagger_generator` is a library using dio interceptor to generate swagger structure automatically. It's easy and useful to create API document with less effort.

## Features

- The model of the library is based on [Swagger Basic Structure](https://swagger.io/docs/specification/basic-structure/)
- Auto create swagger path, tags, request body, request response,... into `swagger.json` file
- Preview the `swagger.json` file
- Auto save to local and merge if request/response have any updated in same path
- Sync data to gitlab to view as Swagger Hub
- The library will ignore requests with base urls are outside `servers`


![DEMO](https://github.com/TuyenPonos/SwaggerGenerator/blob/main/example/demo.gif)


## Getting started

### Config interceptor

Add this library to dio interceptor. To avoid redirecting the response cause interceptor doesn't log full response in your project, should add this interceptor between auth interceptor and error interceptor

```dart
Dio()
..interceptors.addAll([
    AuthInterceptor(),
    SwaggerInterceptor(),
    ErrorInterceptor(),
]);
```

### 1. Initial plugin

**[REQUIRED]**

```dart
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
```

### 2. Add details for a path by using extra options

* Define params in path

By default, the library will spit query params from path. Example execute path `posts/1/comments`, then swagger path will be created as `"/posts/{postId}/comments"`. If you want make your personal, you can add it to options of dio request

```dart
final resp = await _dio.get(
      '/posts/1/comments',
      options: Options(
        extra: {
          'path': 'posts/{myPostId}/comments',
        },
      ),
    );

```

Other way, you can define the `RegExp` rule to extract query params by passing `pathParamsRegs` when call `initial`.

* Define summary or description

Define summary or description by using extra also

```dart
final resp = await _dio.get(
      '/posts/1/comments',
      options: Options(
        extra: {
          'summary': 'Summary of this API',
          'description': 'This API execute an action',
        },
      ),
    );

```

### 3. Preview data

The library support preview json data. In there, you can copy json content or sync to gitlab. Navigate to it by using

```dart
SwaggerGenerator.instance.openPreviewPage(context);
```

### 4. Sync to gitlab

Input your gitlab information then you can sync latest structure to gitlab

![FORM]((https://github.com/TuyenPonos/SwaggerGenerator/blob/main/example/sync_form.png))


## Example

Follow the example: [/example](https://github.com/TuyenPonos/SwaggerGenerator/blob/main/example)


## Contributions 

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an issue.
If you fixed a bug or implemented a feature, please send a pull request.