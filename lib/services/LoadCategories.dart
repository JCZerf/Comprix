import 'dart:convert';

import 'package:flutter/services.dart';

class CategoryService {
  static Future<List<String>> loadCategories() async {
    final String response = await rootBundle.loadString('assets/category.JSON');
    final List<dynamic> data = json.decode(response);
    return data.map<String>((cat) => cat['name'] as String).toList();
  }
}
