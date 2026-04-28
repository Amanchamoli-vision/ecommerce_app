import 'dart:convert';
import 'package:clothes_ecommerce/pages/bottom_nav.dart';
import 'package:clothes_ecommerce/pages/cart.dart';
import 'package:clothes_ecommerce/pages/detail_page.dart';
import 'package:clothes_ecommerce/pages/wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "T-Shirt",
    "Pant",
    "Dress",
    "Jacket"
  ];

  final Map<String, IconData> categoryIcons = {
    "All": Icons.grid_view_rounded,
    "T-Shirt": Icons.checkroom,
    "Pant": Icons.accessibility_new,
    "Dress": Icons.woman,
    "Jacket": Icons.boy,
  };

  final Map<String, String> categoryLocalImage = {
    "T-Shirt": "images/t-shirt.png",
    "Pant": "images/jeans.png",
    "Dress": "images/dress.png",
    "Jacket": "images/jacket.png",
  };

  Stream<QuerySnapshot> _getCategoryStream(String category) {
    return FirebaseFirestore.instance
        .collection("Product")
        .doc(category)
        .collection("items")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: CustomScrollView(
        slivers: [
          // ── Brown Header ──
          SliverToBoxAdapter(
            child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Style",
                                      style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Store",
                                      style: GoogleFonts.playfairDisplay(
                                        color: const Color(0xFFFFE0B2),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Explore Fashion",
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // ✅ Cart icon — CartPage pe navigate karo
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CartPage()),
                            ),
                            child:
                                _HeaderIcon(icon: Icons.shopping_cart_outlined),
                          ),
                          const SizedBox(width: 10),
                          // ✅ Wishlist icon — WishlistPage pe navigate karo
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WishlistPage()),
                            ),
                            child:
                                _HeaderIcon(icon: Icons.favorite_border_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search for clothes, brands and more",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[500], fontSize: 13),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xff6e5038), size: 22),
                            suffixIcon: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: Color(0xFFE0E0E0), width: 1),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.mic_none_rounded,
                                    color: Color(0xff6e5038), size: 20),
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Flash Sale Banner ──
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Flash Sale",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF212121))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6161),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text("50% OFF",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      Text("View All",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xff6e5038),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xff8B6346), Color(0xff4a3220)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -15,
                            top: -15,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.07)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE0B2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text("🔥 TODAY ONLY",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xff4a3220),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800)),
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Mega Fashion\nSale is Live!",
                                          style: GoogleFonts.playfairDisplay(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              height: 1.2)),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text("Shop Now",
                                            style: GoogleFonts.poppins(
                                                color: const Color(0xff6e5038),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    _MiniBadge(
                                        "Upto\n50% OFF", const Color(0xFFFF6161)),
                                    const SizedBox(height: 8),
                                    _MiniBadge(
                                        "Free\nShipping", const Color(0xFF388E3C)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Chips ──
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Shop by Category",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF212121))),
                        Text("See all →",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xff6e5038),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedCategory = cat),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xff6e5038)
                                          .withOpacity(0.12)
                                      : const Color(0xFFF5F0EB),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: const Color(0xff6e5038),
                                          width: 2)
                                      : Border.all(
                                          color: Colors.transparent,
                                          width: 2),
                                ),
                                child: Icon(
                                  categoryIcons[cat] ?? Icons.category,
                                  size: 24,
                                  color: isSelected
                                      ? const Color(0xff6e5038)
                                      : const Color(0xFF888888),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(cat,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xff6e5038)
                                          : const Color(0xFF555555))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section Title ──
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xff6e5038),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedCategory == "All"
                            ? "All Products"
                            : selectedCategory,
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xff6e5038)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text("Filter & Sort",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xff6e5038),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          // ── Product Grid ──
          if (selectedCategory == "All")
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
              sliver: _AllProductsGrid(
                  categoryLocalImage: categoryLocalImage),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
              sliver: StreamBuilder<QuerySnapshot>(
                stream: _getCategoryStream(selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                        child: _LoadingWidget());
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const SliverToBoxAdapter(
                        child: _EmptyWidget());
                  }
                  final docs = snapshot.data!.docs;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductCard(
                        data:
                            docs[i].data() as Map<String, dynamic>,
                        categoryLocalImage: categoryLocalImage,
                      ),
                      childCount: docs.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.68,
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

// ── All Products Grid ──────────────────────────────────────────────────────────
class _AllProductsGrid extends StatefulWidget {
  final Map<String, String> categoryLocalImage;
  const _AllProductsGrid({required this.categoryLocalImage});

  @override
  State<_AllProductsGrid> createState() => _AllProductsGridState();
}

class _AllProductsGridState extends State<_AllProductsGrid> {
  final List<String> _cats = ["T-Shirt", "Pant", "Dress", "Jacket"];
  List<QueryDocumentSnapshot> _allDocs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    List<QueryDocumentSnapshot> docs = [];
    for (final cat in _cats) {
      final snap = await FirebaseFirestore.instance
          .collection("Product")
          .doc(cat)
          .collection("items")
          .get();
      docs.addAll(snap.docs);
    }
    if (mounted)
      setState(() {
        _allDocs = docs;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const SliverToBoxAdapter(child: _LoadingWidget());
    if (_allDocs.isEmpty)
      return const SliverToBoxAdapter(child: _EmptyWidget());
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _ProductCard(
          data: _allDocs[i].data() as Map<String, dynamic>,
          categoryLocalImage: widget.categoryLocalImage,
        ),
        childCount: _allDocs.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.68,
      ),
    );
  }
}

// ── Header Icon ───────────────────────────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      );
}

Widget _MiniBadge(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(60),
        child: Center(
            child: CircularProgressIndicator(color: Color(0xff6e5038))),
      );
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(children: [
            Icon(Icons.shopping_bag_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text("No products yet",
                style: GoogleFonts.poppins(
                    color: Colors.grey, fontSize: 16)),
          ]),
        ),
      );
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> categoryLocalImage;
  const _ProductCard(
      {required this.data, required this.categoryLocalImage});

  @override
  Widget build(BuildContext context) {
    final String name = data["Name"] ?? "Product";
    final String price = data["Price"] ?? "0";
    final String image = data["Image"] ?? "";
    final List<String> images = data["Images"] != null
        ? List<String>.from(data["Images"])
        : [];
    final String detail = data["Detail"] ?? "";
    final String category = data["Category"] ?? "";
    final String localFallback =
        categoryLocalImage[category] ?? "images/t-shirt.png";
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
            images: images, // ✅ multiple images pass karo
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2)),
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
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8)),
                    child: Container(
                      color: const Color(0xFFF8F4F0),
                      child: _buildImage(image, localFallback),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.12),
                              blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 15, color: Color(0xFFFF6161)),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: const BoxDecoration(
                        color: Color(0xff6e5038),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text("30% off",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (category.isNotEmpty)
                      Text(category.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF212121))),
                    Text(name,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("₹$price",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: const Color(0xFF212121))),
                        const SizedBox(width: 5),
                        Text(
                            "₹${originalPrice.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey,
                                decoration:
                                    TextDecoration.lineThrough)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xff6e5038),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            children: [
                              Text("4.2",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 2),
                              const Icon(Icons.star,
                                  color: Colors.white, size: 9),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("(1.2k)",
                            style: GoogleFonts.poppins(
                                fontSize: 9, color: Colors.grey)),
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
  }

  Widget _buildImage(String imageData, String localPath) {
    if (imageData.isNotEmpty) {
      try {
        final bytes = base64Decode(imageData);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _localImage(localPath),
        );
      } catch (_) {
        if (imageData.startsWith('http')) {
          return Image.network(
            imageData,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _localImage(localPath),
          );
        }
      }
    }
    return _localImage(localPath);
  }

  Widget _localImage(String path) => Padding(
        padding: const EdgeInsets.all(24),
        child: Image.asset(path, fit: BoxFit.contain),
      );
}