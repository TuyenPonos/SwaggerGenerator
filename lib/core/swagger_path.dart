import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../swagger_generator.dart';

class SwaggerPath extends Equatable {
  final String path;
  final String tag;
  final String method;
  final String? summary;
  final List<SwaggerResponse> responses;
  final SwaggerContent? requestBody;
  final SwaggerQuery? queryParams;
  final List<Map<String, dynamic>> headers;
  final bool includeResponse;

  const SwaggerPath({
    required this.path,
    required this.tag,
    required this.method,
    this.responses = const [],
    this.requestBody,
    this.queryParams,
    this.headers = const [],
    this.includeResponse = false,
    this.summary,
  });

  factory SwaggerPath.fromJson(Map<String, dynamic> json) {
    return SwaggerPath(
      path: json['path'],
      tag: json['tag'],
      method: json['method'],
      summary: json['summary'],
      headers: json['headers'] != null
          ? (json['headers'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : [],
      responses: (json['responses'] as List)
          .map((e) => SwaggerResponse.fromJson(e))
          .toList(),
      requestBody: json['requestBody'] != null
          ? SwaggerContent.fromJson(json['requestBody'])
          : null,
      queryParams: json['queryParams'] != null
          ? SwaggerQuery.fromJson(json['queryParams'])
          : null,
    );
  }

  Map<String, dynamic> toSaveObject() {
    return {
      'path': path,
      'tag': tag,
      'method': method,
      'headers': headers,
      'queryParams': queryParams?.toSaveObject(),
      'requestBody': requestBody?.toSaveObject(),
      'responses': responses.map((e) => e.toSaveObject()).toList(),
      'summary': summary,
    };
  }

  factory SwaggerPath.fromResponse(
    RequestOptions requestOptions,
    List<SwaggerSecurity> securities,
    Response? response, {
    bool includeResponse = false,
  }) {
    String _path = '';
    final Map<String, dynamic> _queryParams = {};
    if (requestOptions.extra.containsKey('path')) {
      _path = requestOptions.extra['path'];
      RegExp('\{(.*?)\}').allMatches(_path).forEach((e) {
        final _param = _path.substring(e.start + 1, e.end - 1);
        _queryParams.putIfAbsent(
          _param,
          () => {
            'in': 'path',
            'type': 'string',
          },
        );
      });
    } else {
      _path = requestOptions.path;
    }
    final _splitPaths = _path.split('?');
    _path = _splitPaths.first;
    final _requestBody = requestOptions.data;
    if (requestOptions.queryParameters.isNotEmpty) {
      _queryParams.addAll(requestOptions.queryParameters);
    } else {
      final _pathQueryParam =
          _splitPaths.length == 2 ? requestOptions.path.split('?').last : null;
      if (_pathQueryParam != null) {
        _queryParams.addAll(Uri.splitQueryString(_pathQueryParam));
      }
    }
    final List<Map<String, dynamic>> _security = [];
    requestOptions.headers.forEach((key, _) {
      final _index = securities.indexWhere((s) => s.name == key);
      if (_index != -1) {
        _security.add({key: []});
      }
    });
    return SwaggerPath(
      path: _path,
      tag: Uri.dataFromString(_path).pathSegments[1],
      method: requestOptions.method,
      summary: requestOptions.extra['summary'],
      responses: [
        SwaggerResponse(
          statusCode: (response?.statusCode ?? 0).toString(),
          statusMessage: response?.statusMessage ?? '',
          response: response != null ? SwaggerContent(response.data) : null,
        )
      ],
      requestBody: _requestBody != null ? SwaggerContent(_requestBody) : null,
      queryParams: _queryParams.isNotEmpty ? SwaggerQuery(_queryParams) : null,
      headers: _security,
      includeResponse: includeResponse,
    );
  }

  SwaggerPath updateResponse(SwaggerPath other) {
    return copyWith(
      responses: responses.replace(other.responses.first),
      summary: other.summary,
      queryParams: other.queryParams,
      requestBody: other.requestBody,
    );
  }

  SwaggerPath copyWith({
    String? path,
    String? tag,
    String? method,
    String? summary,
    List<SwaggerResponse>? responses,
    SwaggerContent? requestBody,
    SwaggerQuery? queryParams,
    List<Map<String, dynamic>>? headers,
  }) {
    return SwaggerPath(
      path: path ?? this.path,
      tag: tag ?? this.tag,
      method: method ?? this.method,
      summary: summary ?? this.summary,
      responses: responses ?? this.responses,
      requestBody: requestBody ?? this.requestBody,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
    );
  }

  Map<String, dynamic> toJson() {
    final _responses = <String, SwaggerResponse>{};
    responses.forEach((e) {
      _responses.putIfAbsent(e.statusCode, () => e);
    });
    return {
      '${method.toLowerCase()}': {
        'tags': [
          tag,
        ],
        if (summary != null) 'summary': summary,
        'responses': includeResponse
            ? _responses
            : {
                'default': {
                  'description': 'API response',
                  'content': {
                    'application/json': {
                      'schema': {
                        'type': 'string',
                      },
                    }
                  }
                }
              },
        if (requestBody != null)
          'requestBody': {
            'content': requestBody,
          },
        if (queryParams != null) 'parameters': queryParams,
        if (headers.isNotEmpty) 'security': headers,
      }
    };
  }

  @override
  List<Object?> get props => [
        path,
        method,
      ];
}

class SwaggerContent {
  final dynamic data;

  SwaggerContent(this.data);

  factory SwaggerContent.fromJson(Map<String, dynamic> json) {
    final _type = json['type'];
    final _data = json['data'];
    if (_type == 'formdata') {
      final _formData = FormData()
        ..fields.addAll((_data['fields'] as List).map((e) => e))
        ..files.addAll((_data['files'] as List).map(
          (e) {
            return MapEntry(
              e['key'],
              MultipartFile.fromString(e['value']),
            );
          },
        ));
      return SwaggerContent(_formData);
    }
    return SwaggerContent(_data);
  }

  Map<String, dynamic> toSaveObject() {
    if (data is FormData) {
      return {
        'type': 'formdata',
        'data': {
          'fields': (data as FormData).fields.map((e) => e).toList(),
          'files': (data as FormData)
              .files
              .map((e) => {
                    'key': e.key,
                    'value': e.toString(),
                  })
              .toList(),
        }
      };
    }
    return {
      'type': 'primative',
      'data': data,
    };
  }

  Map<String, dynamic> mapProperties(Map<dynamic, dynamic> json) {
    final _mapped = <String, dynamic>{};
    json.forEach((key, value) {
      if (value is List) {
        _mapped.putIfAbsent(
          key,
          () {
            final _element = value.isNotEmpty ? value.first : null;
            return {
              'type': 'array',
              'items': _element is Map<dynamic, dynamic>
                  ? {
                      'type': 'object',
                      'properties': mapProperties(_element),
                    }
                  : SwaggerUtils().toPrimativeType(_element),
            };
          },
        );
      } else if (value is Map<dynamic, dynamic>) {
        _mapped.putIfAbsent(
            key,
            () => {
                  'type': 'object',
                  'properties': mapProperties(value),
                });
      } else {
        _mapped.putIfAbsent(key, () => SwaggerUtils().toPrimativeType(value));
      }
    });
    return _mapped;
  }

  Map<String, dynamic> toJson() {
    if (data is FormData) {
      final _properties = <String, dynamic>{};
      (data as FormData).fields.forEach((e) {
        _properties.putIfAbsent(
            e.key, () => SwaggerUtils().toPrimativeType(e.value));
      });
      (data as FormData).files.forEach((e) {
        _properties.putIfAbsent(
          e.key,
          () => {
            'type': 'string',
            'format': 'binary',
          },
        );
      });
      return {
        'multipart/form-data': {
          'schema': {
            'type': 'object',
            'properties': _properties,
          }
        },
      };
    }
    if (data is List) {
      final _element = data.isNotEmpty ? data.first : null;
      if (_element is Map<dynamic, dynamic>) {
        return {
          'application/json': {
            'schema': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': mapProperties(_element),
              },
            }
          }
        };
      }
      return {
        'application/json': {
          'schema': {
            'type': 'array',
            'items': {
              'type': 'string',
            },
          }
        }
      };
    }
    if (data is Map<dynamic, dynamic>) {
      return {
        'application/json': {
          'schema': {
            'type': 'object',
            'properties': mapProperties(data),
          }
        }
      };
    }
    try {
      return {
        'application/json': {
          'schema': {
            'type': 'object',
            'properties': mapProperties(jsonDecode(data)),
          }
        }
      };
    } catch (e) {
      return {
        'text/plain': {
          'schema': SwaggerUtils().toPrimativeType(data),
        }
      };
    }
  }
}

class SwaggerQuery {
  final Map<String, dynamic> data;

  SwaggerQuery(this.data);

  factory SwaggerQuery.fromJson(Map<String, dynamic> json) {
    return SwaggerQuery(json['data']);
  }

  Map<String, dynamic> toSaveObject() {
    return {
      'data': data,
    };
  }

  List<Map<String, dynamic>> toJson() {
    final List<Map<String, dynamic>> _mapped = [];
    data.forEach((key, value) {
      if (value is Map) {
        _mapped.add({
          'name': key,
          'in': value['in'],
          'required': true,
          'schema': SwaggerUtils().toPrimativeType(value['type'])
        });
      } else {
        _mapped.add({
          'name': key,
          'in': 'query',
          'schema': SwaggerUtils().toPrimativeType(value)
        });
      }
    });
    return _mapped;
  }
}

class SwaggerResponse extends Equatable {
  final String statusCode;
  final String? statusMessage;
  final SwaggerContent? response;

  const SwaggerResponse({
    required this.statusCode,
    this.statusMessage = '',
    this.response,
  });

  factory SwaggerResponse.fromJson(Map<String, dynamic> json) {
    return SwaggerResponse(
      statusCode: json['statusCode'],
      statusMessage: json['statusMessage'],
      response: SwaggerContent.fromJson(json['response']),
    );
  }

  Map<String, dynamic> toSaveObject() {
    return {
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'response': response?.toSaveObject(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'description': statusMessage ?? '$statusCode',
      'content': response,
    };
  }

  @override
  List<Object?> get props => [statusCode];
}
