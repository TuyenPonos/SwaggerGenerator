import 'swagger_security.dart';

class SwaggerComponent {
  final List<SwaggerSecurity> securities;

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
    for (var s in securities) {
      properties.putIfAbsent(s.name, () => s);
    }
    return {
      if (properties.isNotEmpty) 'securitySchemes': properties,
    };
  }
}
