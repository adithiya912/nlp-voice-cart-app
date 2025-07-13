class Product {
  final int id;
  final String name;
  final double price;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stockQuantity: map['stock_quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock_quantity': stockQuantity,
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, stockQuantity: $stockQuantity}';
  }
}