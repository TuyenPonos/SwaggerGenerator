import 'package:equatable/equatable.dart';

class SwaggerServer extends Equatable {
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
