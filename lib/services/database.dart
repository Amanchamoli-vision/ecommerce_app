import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // --- USER SECTION ---

  // User registration ke waqt data save karna
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // --- WALLET SECTION (Tutorial Backend Connection) ---

  // 1. Wallet balance update karne ke liye (Razorpay success ke baad)
  Future updateWallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  // 2. Transaction history save karne ke liye
  Future addTransactions(Map<String, dynamic> transactionMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Transactions")
        .add(transactionMap);
  }

  // --- PRODUCT SECTION ---

  // Product add karna (Admin side)
  Future addProduct(Map<String, dynamic> productInfoMap, String categoryName) async {
    try {
      return await FirebaseFirestore.instance
          .collection("Product")
          .doc(categoryName)
          .collection("items")
          .add(productInfoMap);
    } catch (e) {
      print("Firestore Error: $e");
      rethrow;
    }
  }

  // Category wise products fetch karna (Home page ke liye)
  Stream<QuerySnapshot> getProducts(String category) {
    return FirebaseFirestore.instance
        .collection("Product")
        .doc(category)
        .collection("items")
        .snapshots();
  }

  // --- ORDER SECTION ---

  // Order place karne ke liye
  Future orderDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .add(userInfoMap);
  }
}