import 'dart:convert';
import 'package:clothes_ecommerce/pages/detail_page.dart';
import 'package:clothes_ecommerce/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() {
    setState(() {
      wishlistItems = WishlistService.instance.items;
    });
  }

  void _removeFromWishlist(int index) {
    WishlistService.instance.removeItem(index);
    _loadWishlist();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.redAccent,
        content: const Text("Removed from Wishlist",
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildImage(String imageData, String localFallback) {
    if (imageData.isEmpty) return _fallbackImage(localFallback);
    try {
      final bytes = base64Decode(imageData);
      return Image.memory(bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _fallbackImage(localFallback));
    } catch (_) {
      if (imageData.startsWith('http')) {
        return Image.network(imageData,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _fallbackImage(localFallback));
      }
    }
    return _fallbackImage(localFallback);
  }

  Widget _fallbackImage(String path) => Padding(
        padding: const EdgeInsets.all(20),
        child: Image.asset(path, fit: BoxFit.contain),
      );

  final Map<String, String> _localImages = {
    "T-Shirt": "images/t-shirt.png",
    "Pant": "images/jeans.png",
    "Dress": "images/dress.png",
    "Jacket": "images/jacket.png",
  };

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
                      child: const Icon(Icons.favorite_rounded,
                          color: Color(0xFFFF6161), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("My Wishlist",
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          "${wishlistItems.length} item(s) saved",
                          style: GoogleFonts.poppins(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (wishlistItems.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          WishlistService.instance.clearAll();
                          _loadWishlist();
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

          Expanded(
            child: wishlistItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No Saved Items",
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 20, color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text("Heart items you love from the store!",
                            style: GoogleFonts.poppins(
                                color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: wishlistItems.length,
                    itemBuilder: (context, index) {
                      final item = wishlistItems[index];
                      final name = item['name'] ?? '';
                      final price = item['price'] ?? '0';
                      final image = item['image'] ?? '';
                      final detail = item['detail'] ?? '';
                      final category = item['category'] ?? '';
                      final localFallback = _localImages[category] ??
                          "images/t-shirt.png";
                      final double originalPrice =
                          (double.tryParse(price) ?? 0) * 1.3;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(
                              image: image,
                              name: name,
                              price: price,
                              detail: detail,
                              category: category,
                              localFallback: localFallback,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(12)),
                                      child: Container(
                                        color: const Color(0xFFF8F4F0),
                                        child: _buildImage(
                                            image, localFallback),
                                      ),
                                    ),
                                    // Remove from wishlist
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _removeFromWishlist(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.12),
                                                  blurRadius: 4)
                                            ],
                                          ),
                                          child: const Icon(
                                              Icons.favorite_rounded,
                                              size: 15,
                                              color: Color(0xFFFF6161)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (category.isNotEmpty)
                                        Text(category.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    const Color(0xFF212121))),
                                      Text(name,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color:
                                                  const Color(0xFF666666)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Row(
                                        children: [
                                          Text("₹$price",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                  color: const Color(
                                                      0xFF212121))),
                                          const SizedBox(width: 5),
                                          Text(
                                            "₹${originalPrice.toStringAsFixed(0)}",
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          ),
                                        ],
                                      ),
                                      Text("Free delivery",
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: const Color(0xFF388E3C),
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}