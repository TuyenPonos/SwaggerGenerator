import 'dart:convert';

extension JsonExtension on Map<String, dynamic> {
  String prettyJson() {
    final spaces = ' ' * 4;
    final encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(this);
  }
}

extension ListExtension<T> on List<T> {
  List<T> replace(T value) {
    final index = indexOf(value);
    if (index == -1) {
      return this..add(value);
    }
    return this
      ..removeAt(index)
      ..insert(index, value);
  }
}

class SwaggerUtils {
  Map<String, dynamic> toPrimativeType(dynamic value) {
    switch (value.runtimeType) {
      case String:
        return {'type': 'string'};
      case int:
      case double:
        return {'type': 'number'};
      case bool:
        return {'type': 'boolean'};
      default:
        return {'type': 'string'};
    }
  }
}
