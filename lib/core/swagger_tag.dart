import 'package:equatable/equatable.dart';

class SwaggerTag extends Equatable {
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
