import 'package:clothes_ecommerce/pages/detail_page.dart';
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

  final List<String> categories = ["All", "T-Shirt", "Pant", "Dress", "Jacket"];

  final Map<String, IconData> categoryIcons = {
    "All": Icons.grid_view_rounded,
    "T-Shirt": Icons.checkroom,
    "Pant": Icons.accessibility_new,
    "Dress": Icons.woman,
    "Jacket": Icons.boy,
  };

  // ✅ Category ke hisaab se local fallback image
  final Map<String, String> categoryLocalImage = {
    "T-Shirt": "images/t-shirt.png",
    "Pant": "images/jeans.png",
    "Dress": "images/dress.png",
    "Jacket": "images/jacket.png",
  };

  Future<List<QueryDocumentSnapshot>> _getAllProducts() async {
    final List<String> cats = ["T-Shirt", "Pant", "Dress", "Jacket"];
    List<QueryDocumentSnapshot> allDocs = [];
    for (String cat in cats) {
      final snap = await FirebaseFirestore.instance
          .collection("Product")
          .doc(cat)
          .collection("items")
          .get();
      allDocs.addAll(snap.docs);
    }
    return allDocs;
  }

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
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff6e5038),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Location hataya, Welcome add kiya
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "👋 Welcome back!",
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Good to see you 😊",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white30, width: 1.5),
                            ),
                            child: const Icon(Icons.person_outline,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Find Your\nPerfect Style ✨",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search clothes...",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400], fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xff6e5038)),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xff6e5038),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.tune_rounded,
                                  color: Colors.white, size: 18),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Flash Sale Banner — OVERFLOW FIX ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Container(
                // ✅ Fixed height hataya, content ko khud size lene diya
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xff8B6346), Color(0xffD4A57A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff6e5038).withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        bottom: -30,
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      // ✅ Content — padding se size control hoga, fixed height nahi
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // ✅ Key fix
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text("🔥 Flash Sale",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Up to 50% OFF\non all collections",
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Shop Now →",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xff6e5038),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4), // ✅ Bottom breathing room
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Category Chips ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Categories",
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2D1F14))),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 20),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xff6e5038)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xff6e5038)
                                          .withOpacity(0.35)
                                      : Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  categoryIcons[cat] ?? Icons.category,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xff6e5038),
                                ),
                                const SizedBox(width: 6),
                                Text(cat,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xff6e5038),
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory == "All" ? "All Products" : selectedCategory,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D1F14)),
                  ),
                  Text("See all →",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xff6e5038),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // ── Product Grid ──
          if (selectedCategory == "All")
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _getAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: _LoadingWidget());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(child: _EmptyWidget());
                  }
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductCard(
                        data: snapshot.data![i].data() as Map<String, dynamic>,
                        categoryLocalImage: categoryLocalImage,
                      ),
                      childCount: snapshot.data!.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: StreamBuilder<QuerySnapshot>(
                stream: _getCategoryStream(selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(child: _LoadingWidget());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SliverToBoxAdapter(child: _EmptyWidget());
                  }
                  final docs = snapshot.data!.docs;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProductCard(
                        data: docs[i].data() as Map<String, dynamic>,
                        categoryLocalImage: categoryLocalImage,
                      ),
                      childCount: docs.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
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

// ── Loading ───────────────────────────────────────────────────────────────────
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: CircularProgressIndicator(color: Color(0xff6e5038))),
      );
}

// ── Empty ─────────────────────────────────────────────────────────────────────
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
                style:
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
          ]),
        ),
      );
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> categoryLocalImage;
  const _ProductCard({required this.data, required this.categoryLocalImage});

  @override
  Widget build(BuildContext context) {
    final String name = data["Name"] ?? "Product";
    final String price = data["Price"] ?? "0";
    final String image = data["Image"] ?? "";       // Network URL (agar ho)
    final String detail = data["Detail"] ?? "";
    final String category = data["Category"] ?? "";

    // ✅ Local fallback image category se match karke dikhao
    final String localFallback =
        categoryLocalImage[category] ?? "images/t-shirt.png";

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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 15,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Area ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: Container(
                      color: const Color(0xFFF0E9E0),
                      child: _buildImage(image, localFallback),
                    ),
                  ),
                  // Category badge
                  if (category.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff6e5038).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(category,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  // Wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6)
                        ],
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 14, color: Color(0xff6e5038)),
                    ),
                  ),
                ],
              ),
            ),
            // ── Name + Price ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xff2D1F14)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$$price",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: const Color(0xff6e5038))),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xff6e5038),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Network image ho toh dikhao, warna local asset image
  Widget _buildImage(String networkUrl, String localPath) {
    if (networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _localImage(localPath),
      );
    }
    return _localImage(localPath);
  }

  Widget _localImage(String path) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        color: const Color(0xff6e5038),
      ),
    );
  }
}