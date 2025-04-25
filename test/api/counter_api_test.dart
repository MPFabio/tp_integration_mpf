import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('GET dummy user returns user data', () async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users/1'));

    expect(response.statusCode, 200);

    final json = jsonDecode(response.body);
    expect(json['id'], 1);
    expect(json['name'], isNotNull);
  });
}
