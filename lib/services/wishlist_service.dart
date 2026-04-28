import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WishlistService — Singleton + ChangeNotifier
/// - SharedPreferences mein persist hota hai
/// - ChangeNotifier se badge auto-update hoga
class WishlistService extends ChangeNotifier {
  WishlistService._internal();
  static final WishlistService instance = WishlistService._internal();

  final List<Map<String, dynamic>> _items = [];
  static const _key = 'wishlist_items_v1';

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

  bool isWishlisted(String name) =>
      _items.any((item) => item['name'] == name);

  void toggleWishlist({
    required String name,
    required String price,
    required String image,
    required String detail,
    required String category,
    required String localFallback,
  }) {
    final existing = _items.indexWhere((item) => item['name'] == name);
    if (existing != -1) {
      _items.removeAt(existing);
    } else {
      _items.add({
        'name': name,
        'price': price,
        'image': image,
        'detail': detail,
        'category': category,
        'localFallback': localFallback,
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

  void clearAll() {
    _items.clear();
    _save();
    notifyListeners();
  }

  int get itemCount => _items.length;
}