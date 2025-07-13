import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../helpers/database_helper.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<Product> _products = [];

  List<CartItem> get cartItems => _cartItems;
  List<Product> get products => _products;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> loadProducts() async {
    _products = await DatabaseHelper.instance.getAllProducts();
    notifyListeners();
  }

  Future<void> loadCartItems() async {
    _cartItems = await DatabaseHelper.instance.getCartItems();
    notifyListeners();
  }

  Future<bool> addToCart(String productName, int quantity) async {
    try {
      final product = await DatabaseHelper.instance.getProductByName(productName);
      if (product != null) {
        await DatabaseHelper.instance.addToCart(product.id, quantity);
        await loadCartItems();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  Future<bool> removeFromCart(String productName, int quantity) async {
    try {
      final product = await DatabaseHelper.instance.getProductByName(productName);
      if (product != null) {
        await DatabaseHelper.instance.removeFromCart(product.id, quantity);
        await loadCartItems();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  Future<void> clearCart() async {
    await DatabaseHelper.instance.clearCart();
    await loadCartItems();
  }

  Future<void> removeCartItem(int productId) async {
    final cartItem = _cartItems.firstWhere((item) => item.productId == productId);
    await DatabaseHelper.instance.removeFromCart(productId, cartItem.quantity);
    await loadCartItems();
  }
}