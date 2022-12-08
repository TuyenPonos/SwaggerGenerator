import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../swagger_generator.dart';

class SwaggerGenerator {
  final String _swaggerLocalKey = 'swagger.generator';
  final String _gitLabInfo = 'swagger.gitlab.info';

  factory SwaggerGenerator() => instance;

  static final SwaggerGenerator instance = SwaggerGenerator._internal();
  SwaggerGenerator._internal();

  final BehaviorSubject<Swagger> _controller = BehaviorSubject<Swagger>();
  ValueStream<Swagger> get stream => _controller.stream;

  late final SharedPreferences _preferences;
  bool _includeResponse = false;
  final List<RegExp> _pathParamsRegs = List.from([
    RegExp(r'[0-9]+(-)[0-9]+(-)[0-9]+(-)[0-9]+'),
    RegExp(r'\d+'),
  ]);

  Swagger? swagger;

  /// Initial base swagger document information
  /// [pathParamsRegs] using to get query params from a path. Example: https://example.api/v1/user/1255421
  /// then the lib with create path such as: https://example.api/v1/user/{userId}
  /// By default have 2 regex:  RegExp(r'[0-9]+(-)[0-9]+(-)[0-9]+(-)[0-9]+') and RegExp(r'\d+')

  Future<void> initial(
    Swagger data, {
    bool includeResponse = false,
    List<RegExp> pathParamsRegs = const [],
  }) async {
    _pathParamsRegs.addAll(pathParamsRegs);
    _includeResponse = includeResponse;
    _preferences = await SharedPreferences.getInstance();
    final savedData =
        _localData != null ? Swagger.fromJson(jsonDecode(_localData!)) : null;
    swagger = savedData != null ? data.merge(savedData) : data;
    _save();
    _controller.add(swagger!);
    if (_localGitlabInfo != null) {
      _gitInformation = jsonDecode(_localGitlabInfo!);
    }
  }

  String? get _localData => _preferences.getString(_swaggerLocalKey);
  String? get _localGitlabInfo => _preferences.getString(_gitLabInfo);

  /// Update the version of document after initial

  void updateVersion(String value) {
    assert(swagger != null, 'SwaggerGeneratorController has not initial');
    swagger = swagger!.copyWith(info: swagger!.info.copyWith(version: value));
    _controller.add(swagger!);
  }

  /// Record response then create structure (if not existing) or update structure (if existing)

  void updateResponse(Response response) {
    assert(swagger != null, 'SwaggerGeneratorController has not initial');
    if (!_isValidServer(response.requestOptions.baseUrl)) {
      return;
    }
    final swgPath = SwaggerPath.fromResponse(
      response.requestOptions,
      swagger!.components?.securities ?? [],
      response,
      includeResponse: _includeResponse,
      pathRegs: _pathParamsRegs,
    );
    _gen(swgPath);
    _save();
  }

  /// Record error then create structure (if not existing) or update structure (if existing)

  void updateError(DioError error) {
    assert(swagger != null, 'SwaggerGeneratorController has not initial');
    if (!_isValidServer(error.requestOptions.baseUrl)) {
      return;
    }
    final swgPath = SwaggerPath.fromResponse(
      error.requestOptions,
      swagger!.components?.securities ?? [],
      error.response,
      includeResponse: _includeResponse,
      pathRegs: _pathParamsRegs,
    );
    _gen(swgPath);
    _save();
  }

  void _gen(SwaggerPath swgPath) {
    final isExistingTag =
        swagger!.tags.indexWhere((t) => t.name == swgPath.tag) != -1;
    final Map<String, List<SwaggerPath>> paths = Map.from(swagger!.paths);
    if (paths.containsKey(swgPath.path)) {
      var currentPaths = paths[swgPath.path] ?? [];
      final pathIndex = currentPaths.indexOf(swgPath);
      if (pathIndex == -1) {
        currentPaths.add(swgPath);
      } else {
        currentPaths = currentPaths.replace(
          currentPaths[pathIndex].updateResponse(swgPath),
        );
      }
      paths[swgPath.path] = List.from(currentPaths);
    } else {
      paths.addAll({
        swgPath.path: [swgPath]
      });
    }
    swagger = swagger!.copyWith(
      paths: paths,
      tags: isExistingTag
          ? null
          : (List.from(swagger!.tags)..add(SwaggerTag(name: swgPath.tag))),
    );
    _controller.add(swagger!);
  }

  /// Save latest to local storage
  Future<void> _save() async {
    if (swagger == null) {
      return;
    }
    _preferences.setString(
      _swaggerLocalKey,
      jsonEncode(swagger!.toSaveObject()),
    );
  }

  bool _isValidServer(String baseUrl) {
    for (final element in swagger?.servers ?? []) {
      if (element.url == baseUrl) {
        return true;
      }
    }
    return false;
  }

  /// Close the controller avoid leaking memory
  void dispose() {
    _controller.close();
  }

  /// Open a Material page that show preview of swagger.json file and can sync with gitlab
  Future<dynamic> openPreviewPage(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SwaggerPreviewPage();
      },
    ));
  }

  Map<String, dynamic> _gitInformation = {
    'domain': null,
    'project_id': null,
    'access_token': null,
    'branch': null,
  };
  Map<String, dynamic> get gitInformation => _gitInformation;

  /// The function using gitlab API to sync `swagger.json` file to your repo
  /// [domain] your gitlab domain, such as: https:www.git.corporaton.com
  /// [projectId] find it in gitlab repo description
  /// [accessToken] your access token to access into the repo
  /// [branch] branch you wanna put
  /// [message] is optional. If message is empty, default time Iso8601 will be used

  Future<bool> syncToGitlab({
    required String domain,
    required String projectId,
    required String accessToken,
    required String branch,
    String message = '',
  }) async {
    _gitInformation = {
      'domain': domain,
      'project_id': projectId,
      'access_token': accessToken,
      'branch': branch,
    };
    _preferences.setString(_gitLabInfo, jsonEncode(_gitInformation));
    final body = {
      'branch': 'develop',
      'content': swagger!.prettyJson(),
      'commit_message':
          message.isEmpty ? DateTime.now().toIso8601String() : message,
    };
    final header = {
      'PRIVATE-TOKEN': accessToken,
    };
    final isExisting = await _fileExisting();
    try {
      if (isExisting) {
        await Dio().put(
          '$domain/api/v4/projects/$projectId/repository/files/swagger.json',
          data: body,
          options: Options(headers: header),
        );
      } else {
        await Dio().post(
          '$domain/api/v4/projects/$projectId/repository/files/swagger.json',
          data: body,
          options: Options(headers: header),
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _fileExisting() async {
    try {
      final resp = await Dio().get(
        '${_gitInformation['domain']}/api/v4/projects/${_gitInformation['project_id']}/repository/files/swagger.json?ref=${_gitInformation['branch']}',
        options: Options(
          headers: {
            'PRIVATE-TOKEN': _gitInformation['access_token'],
          },
        ),
      );
      final file = resp.data;
      if (file['file_name'] == 'swagger.json') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
