class ProductModel {
  final int id;
  final String name;
  final double price;
  final String description;
  final String createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.createdAt,
  });

  // Membuat objek ProductModel dari JSON response API
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  // Mengubah objek ProductModel menjadi Map untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price.toInt(),
      'description': description,
    };
  }
}