import 'package:equatable/equatable.dart';

class SwaggerSecurity extends Equatable {
  final String name;
  final String position;
  final String type;
  final String? scheme;
  final String? bearerFormat;
  final String? description;

  const SwaggerSecurity({
    required this.name,
    this.position = 'header',
    required this.type,
    this.scheme,
    this.bearerFormat,
    this.description,
  })  : assert(
          position == 'query' || position == 'header' || position == 'cookie',
          'position should be: "query" | "header" | "cookie"',
        ),
        assert(
          type == 'http' ||
              type == 'apiKey' ||
              type == 'oauth2' ||
              type == 'openIdConnect',
          'type should be: "http" | "apiKey" | "oauth2" | "openIdConnect"',
        ),
        assert(
          scheme == null || scheme == 'basic' || scheme == 'bearer',
          'scheme should be: null | "basic" | "bearer"',
        );

  factory SwaggerSecurity.fromJson(Map<String, dynamic> json) {
    return SwaggerSecurity(
      name: json['name'],
      type: json['type'],
      description: json['description'],
      scheme: json['scheme'],
      bearerFormat: json['bearerFormat'],
    );
  }

  Map<String, dynamic> toSaveObject() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'scheme': scheme,
      'bearerFormat': bearerFormat,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (type != 'http') 'name': name,
      if (type != 'http') 'in': position,
      if (description != null) 'description': description,
      if (scheme != null) 'scheme': scheme,
      if (bearerFormat != null) 'bearerFormat': bearerFormat,
    };
  }

  @override
  List<Object?> get props => [name];
}
