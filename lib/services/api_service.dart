import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  //token

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ─── AUTH ────────────────────────────────────────────────

  //login pake nim sama pass nya juga nim
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      await saveToken(data['data']['token']);
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    }
  }

  //ambil data produk punya masing masing
  static Future<List<ProductModel>> getProducts() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List productsJson = data['data']['products'];
      return productsJson.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil produk');
    }
  }

  //nyimpan produk baru ke draft
  static Future<bool> addProduct(
    String name,
    int price,
    String description,
  ) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  /// ini utk hps produk tapi dia soft delet
  static Future<bool> deleteProduct(int id) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  //ini utk submit tugs
  static Future<Map<String, dynamic>> submitTugas(
    String name,
    int price,
    String description,
    String githubUrl,
  ) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/products/submit');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {'success': true, 'message': 'Tugas berhasil disubmit!'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Submit gagal'};
    }
  }
}
