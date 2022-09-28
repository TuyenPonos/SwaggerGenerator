// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:equatable/equatable.dart';

import '../swagger_generator.dart';

class Swagger extends Equatable {
  final String id;
  final String openapi;
  final SwaggerInfo info;
  final List<SwaggerServer> servers;
  final List<SwaggerTag> tags;
  final Map<String, List<SwaggerPath>> paths;
  final SwaggerComponent? components;

  const Swagger({
    required this.id,
    this.openapi = '3.0.3',
    required this.info,
    required this.servers,
    this.tags = const [],
    this.paths = const {},
    this.components,
  });

  factory Swagger.fromJson(Map<String, dynamic> json) {
    return Swagger(
      id: json['id'],
      openapi: json['openapi'],
      info: SwaggerInfo.fromJson(json['info']),
      servers: (json['servers'] as List)
          .map((e) => SwaggerServer.fromJson(e))
          .toList(),
      tags: (json['tags'] as List).map((e) => SwaggerTag.fromJson(e)).toList(),
      paths: (json['paths'] as Map).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => SwaggerPath.fromJson(e)).toList(),
        ),
      ),
      components: json['components'] != null
          ? SwaggerComponent.fromJson(json['components'])
          : null,
    );
  }

  Map<String, dynamic> toSaveObject() {
    return {
      'id': id,
      'openapi': openapi,
      'info': info.toJson(),
      'servers': servers.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'components': components?.toSaveObject(),
      'paths': paths.map(
        (key, value) => MapEntry(
          key,
          value.map((e) => e.toSaveObject()).toList(),
        ),
      )
    };
  }

  Swagger merge(Swagger other) {
    final _tags = List<SwaggerTag>.from(tags)..addAll(other.tags);
    final _servers = List<SwaggerServer>.from(servers)..addAll(other.servers);
    return copyWith(
      paths: other.paths,
      tags: _tags.toSet().toList(),
      servers: _servers.toSet().toList(),
    );
  }

  Swagger copyWith({
    String? openapi,
    SwaggerInfo? info,
    List<SwaggerServer>? servers,
    List<SwaggerTag>? tags,
    Map<String, List<SwaggerPath>>? paths,
    SwaggerComponent? components,
  }) {
    return Swagger(
      id: id,
      openapi: openapi ?? this.openapi,
      info: info ?? this.info,
      servers: servers ?? this.servers,
      tags: tags ?? this.tags,
      paths: paths ?? this.paths,
      components: components ?? this.components,
    );
  }

  String prettyJson() {
    final _paths = <String, dynamic>{};
    paths.forEach((key, value) {
      _paths.putIfAbsent(key, () {
        final _mapped = <String, dynamic>{};
        for (var v in value) {
          _mapped.addAll(v.toJson());
        }
        return _mapped;
      });
    });
    return {
      'openapi': openapi,
      'info': info,
      'servers': servers,
      'tags': tags,
      'paths': _paths,
      if (components != null) 'components': components,
    }.prettyJson();
  }

  @override
  List<Object?> get props => [
        id,
        openapi,
        info,
        servers,
        tags,
        paths,
        components,
      ];
}
