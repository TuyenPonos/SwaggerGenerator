import 'package:equatable/equatable.dart';

class SwaggerInfo extends Equatable {
  /// It is considered to be a good practice to include general information about your API into the specification: version number, license notes, contact data, links to documentation, and more
  /// https://swagger.io/docs/specification/api-general-info/
  const SwaggerInfo({
    required this.title,
    this.contact,
    required this.version,
  });

  final String title;
  final Contact? contact;
  final String version;

  SwaggerInfo copyWith({
    String? title,
    Contact? contact,
    String? version,
  }) =>
      SwaggerInfo(
        title: title ?? this.title,
        contact: contact ?? this.contact,
        version: version ?? this.version,
      );

  factory SwaggerInfo.fromJson(Map<String, dynamic> json) => SwaggerInfo(
        title: json['title'],
        contact:
            json['contact'] != null ? Contact.fromJson(json['contact']) : null,
        version: json['version'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'contact': contact?.toJson() ?? {},
        'version': version,
      };

  @override
  List<Object?> get props => [
        version,
        title,
      ];
}

class Contact {
  Contact({
    this.email = 'contact@info.com',
  });

  final String email;

  Contact copyWith({
    String? email,
  }) =>
      Contact(
        email: email ?? this.email,
      );

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}
