import 'package:equatable/equatable.dart';

class SwaggerTag extends Equatable {
  /// You can assign a list of tags to each API operation. Tagged operations may be handled differently by tools and libraries. For example, Swagger UI uses tags to group the displayed operations.
  /// By default, tags is get from first part of path
  ///
  const SwaggerTag({
    required this.name,
  });

  final String name;

  SwaggerTag copyWith({
    String? name,
  }) =>
      SwaggerTag(
        name: name ?? this.name,
      );

  factory SwaggerTag.fromJson(Map<String, dynamic> json) => SwaggerTag(
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
      };

  @override
  List<Object?> get props => [name];
}
