import 'package:equatable/equatable.dart';

class SwaggerServer extends Equatable {
  /// In OpenAPI 3.0, you use the servers array to specify one or more base URLs for your API
  const SwaggerServer({
    required this.url,
    required this.description,
  });

  final String url;
  final String description;

  SwaggerServer copyWith({
    String? url,
    String? description,
  }) =>
      SwaggerServer(
        url: url ?? this.url,
        description: description ?? this.description,
      );

  factory SwaggerServer.fromJson(Map<String, dynamic> json) => SwaggerServer(
        url: json['url'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'description': description,
      };

  @override
  List<Object?> get props => [url];
}
