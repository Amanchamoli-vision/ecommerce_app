import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CartService — Singleton + ChangeNotifier
/// - SharedPreferences mein persist hota hai (app close pe bhi data rahega)
/// - ChangeNotifier se badge auto-update hoga
class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService instance = CartService._internal();

  final List<Map<String, dynamic>> _items = [];
  static const _key = 'cart_items_v1';

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  /// App start pe ek baar call karo
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final List decoded = jsonDecode(raw);
        _items.clear();
        _items.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_items));
  }

  void addItem({
    required String name,
    required String price,
    required String image,
    required String detail,
    required String category,
    required String localFallback,
    required String size,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item['name'] == name && item['size'] == size,
    );
    if (existingIndex != -1) {
      _items[existingIndex]['quantity'] =
          (_items[existingIndex]['quantity'] as int? ?? 1) + quantity;
    } else {
      _items.add({
        'name': name,
        'price': price,
        'image': image,
        'detail': detail,
        'category': category,
        'localFallback': localFallback,
        'size': size,
        'quantity': quantity,
      });
    }
    _save();
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _save();
      notifyListeners();
    }
  }

  void updateQuantity(int index, int qty) {
    if (index >= 0 && index < _items.length && qty > 0) {
      _items[index]['quantity'] = qty;
      _save();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _save();
    notifyListeners();
  }

  int get totalPrice => _items.fold<int>(0, (sum, item) {
        final price = int.tryParse(item['price']?.toString() ?? '0') ?? 0;
        final qty = item['quantity'] as int? ?? 1;
        return sum + (price * qty);
      });

  int get itemCount => _items.length;
}