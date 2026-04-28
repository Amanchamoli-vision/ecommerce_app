import 'dart:convert';
import 'package:clothes_ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    setState(() {
      cartItems = CartService.instance.items;
    });
  }

  void _removeItem(int index) {
    CartService.instance.removeItem(index);
    _loadCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.redAccent,
        content: const Text("Item removed from cart",
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _updateQuantity(int index, int qty) {
    if (qty < 1) return;
    CartService.instance.updateQuantity(index, qty);
    _loadCart();
  }

  int get totalPrice => CartService.instance.totalPrice;

  Widget _buildImage(String imageData) {
    if (imageData.isEmpty) {
      return const Icon(Icons.image_not_supported_rounded,
          color: Colors.grey, size: 40);
    }
    try {
      final bytes = base64Decode(imageData);
      return Image.memory(bytes, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_rounded, color: Colors.grey));
    } catch (_) {
      if (imageData.startsWith('http')) {
        return Image.network(imageData, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image_rounded, color: Colors.grey));
      }
    }
    return const Icon(Icons.image_not_supported_rounded, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff6e5038),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("My Cart",
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          "${cartItems.length} item(s)",
                          style: GoogleFonts.poppins(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (cartItems.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          CartService.instance.clearCart();
                          _loadCart();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("Clear All",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Cart Items ──
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("Your cart is empty",
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 20, color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text("Add items from the store!",
                            style: GoogleFonts.poppins(
                                color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final name = item['name'] ?? '';
                      final price = int.tryParse(item['price'] ?? '0') ?? 0;
                      final qty = item['quantity'] ?? 1;
                      final image = item['image'] ?? '';
                      final size = item['size'] ?? 'S';
                      final category = item['category'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16)),
                              child: Container(
                                width: 100,
                                height: 110,
                                color: const Color(0xFFF8F4F0),
                                child: _buildImage(image),
                              ),
                            ),
                            // Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (category.isNotEmpty)
                                      Text(category.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xff6e5038))),
                                    Text(name,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff2D1F14)),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0E9E0),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text("Size: $size",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color:
                                                      const Color(0xff6e5038),
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("₹${price * qty}",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color:
                                                    const Color(0xff2D1F14))),
                                        // Quantity controls
                                        Row(
                                          children: [
                                            _qtyBtn(
                                              Icons.remove,
                                              () => _updateQuantity(
                                                  index, qty - 1),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text("$qty",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                            _qtyBtn(
                                              Icons.add,
                                              () => _updateQuantity(
                                                  index, qty + 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Remove button
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _removeItem(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.delete_outline_rounded,
                                      color: Colors.red.shade400, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ── Bottom Bar ──
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount",
                          style: GoogleFonts.poppins(
                              color: Colors.grey, fontSize: 13)),
                      Text("₹$totalPrice",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: const Color(0xff2D1F14))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color(0xFF388E3C),
                          content: const Text("🎉 Proceeding to Checkout!",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff8B6346), Color(0xff6e5038)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xff6e5038).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Center(
                        child: Text("Proceed to Checkout",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E9E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xff6e5038)),
        ),
      );
}