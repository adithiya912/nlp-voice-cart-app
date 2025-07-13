import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cart_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL
      )
    ''');

    // Create cart items table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Insert initial products
    await _insertInitialProducts(db);
  }

  Future _insertInitialProducts(Database db) async {
    final products = [
      {'name': 'Pen', 'price': 5.0, 'stock_quantity': 100},
      {'name': 'Pencil', 'price': 3.0, 'stock_quantity': 150},
      {'name': 'Notebook', 'price': 25.0, 'stock_quantity': 50},
      {'name': 'Eraser', 'price': 2.0, 'stock_quantity': 200},
      {'name': 'Ruler', 'price': 8.0, 'stock_quantity': 75},
      {'name': 'Marker', 'price': 12.0, 'stock_quantity': 80},
      {'name': 'Highlighter', 'price': 15.0, 'stock_quantity': 60},
      {'name': 'Stapler', 'price': 45.0, 'stock_quantity': 30},
      {'name': 'Calculator', 'price': 120.0, 'stock_quantity': 25},
      {'name': 'Scissors', 'price': 35.0, 'stock_quantity': 40},
      {'name': 'Glue Stick', 'price': 18.0, 'stock_quantity': 70},
      {'name': 'Paper Clips', 'price': 6.0, 'stock_quantity': 120},
      {'name': 'Rubber Band', 'price': 4.0, 'stock_quantity': 180},
      {'name': 'Folder', 'price': 22.0, 'stock_quantity': 55},
      {'name': 'Binder', 'price': 65.0, 'stock_quantity': 35},
      {'name': 'Sticky Notes', 'price': 14.0, 'stock_quantity': 90},
      {'name': 'Tape', 'price': 28.0, 'stock_quantity': 45},
      {'name': 'Correction Fluid', 'price': 16.0, 'stock_quantity': 65},
      {'name': 'Compass', 'price': 38.0, 'stock_quantity': 25},
      {'name': 'Protractor', 'price': 20.0, 'stock_quantity': 40},
    ];

    for (var product in products) {
      await db.insert('products', product);
    }
  }

  // Product operations
  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<Product?> getProductByName(String name) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${name.toLowerCase()}%'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // Cart operations
  Future<List<CartItem>> getCartItems() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT ci.id, ci.product_id, ci.quantity, p.name, p.price
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
    ''');

    return result.map((json) => CartItem.fromMap(json)).toList();
  }

  Future<int> addToCart(int productId, int quantity) async {
    final db = await instance.database;

    // Check if item already exists in cart
    final existing = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      final currentQuantity = existing.first['quantity'] as int;
      return await db.update(
        'cart_items',
        {'quantity': currentQuantity + quantity},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      // Insert new item
      return await db.insert('cart_items', {
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<int> removeFromCart(int productId, int quantity) async {
    final db = await instance.database;

    final existing = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (existing.isNotEmpty) {
      final currentQuantity = existing.first['quantity'] as int;
      final newQuantity = currentQuantity - quantity;

      if (newQuantity <= 0) {
        // Remove item completely
        return await db.delete(
          'cart_items',
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      } else {
        // Update quantity
        return await db.update(
          'cart_items',
          {'quantity': newQuantity},
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      }
    }
    return 0;
  }

  Future<int> clearCart() async {
    final db = await instance.database;
    return await db.delete('cart_items');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}