class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'],
      productName: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'CartItem{id: $id, productName: $productName, price: $price, quantity: $quantity}';
  }
}