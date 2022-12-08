import 'swagger_security.dart';

class SwaggerComponent {
  final List<SwaggerSecurity> securities;

  /// SwaggerComponent now support securitySchemes only, using to make Authentication
  /// Reference: https://swagger.io/docs/specification/components/?sbsearch=Component

  SwaggerComponent({
    this.securities = const [],
  });

  factory SwaggerComponent.fromJson(Map<String, dynamic> json) {
    return SwaggerComponent(
      securities: (json['securities'] as List)
          .map((e) => SwaggerSecurity.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toSaveObject() {
    return {
      'securities': securities.map((e) => e.toSaveObject()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    final properties = <String, dynamic>{};
    for (final s in securities) {
      properties.putIfAbsent(s.name, () => s);
    }
    return {
      if (properties.isNotEmpty) 'securitySchemes': properties,
    };
  }
}
