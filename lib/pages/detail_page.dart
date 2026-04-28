import 'dart:convert';
import 'package:clothes_ecommerce/services/cart_service.dart';
import 'package:clothes_ecommerce/services/database.dart';
import 'package:clothes_ecommerce/services/shared_pref.dart';
import 'package:clothes_ecommerce/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatefulWidget {
  final String image, name, price, detail, category, localFallback;
  final List<String> images;

  const DetailPage({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.detail,
    this.category = "",
    this.localFallback = "images/t-shirt.png",
    this.images = const [],
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool small = true, medium = false, large = false, xl = false, xxl = false;
  int quantity = 1;
  int currentImageIndex = 0;
  String? id, wallet;
  final PageController _pageController = PageController();

  // ✅ Wishlist state
  bool _isWishlisted = false;

  late final List<String> allImages;

  String get _selectedSize {
    if (small) return "S";
    if (medium) return "M";
    if (large) return "L";
    if (xl) return "XL";
    if (xxl) return "XXL";
    return "S";
  }

  @override
  void initState() {
    super.initState();
    allImages = widget.images.isNotEmpty
        ? widget.images
        : (widget.image.isNotEmpty ? [widget.image] : []);
    _isWishlisted = WishlistService.instance.isWishlisted(widget.name);
    getontheload();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  getontheload() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

  // ✅ Wishlist toggle
  void _toggleWishlist() {
    WishlistService.instance.toggleWishlist(
      name: widget.name,
      price: widget.price,
      image: widget.image,
      detail: widget.detail,
      category: widget.category,
      localFallback: widget.localFallback,
    );
    setState(() {
      _isWishlisted = WishlistService.instance.isWishlisted(widget.name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor:
            _isWishlisted ? const Color(0xFFFF6161) : Colors.grey[700],
        content: Text(
          _isWishlisted ? "❤️ Added to Wishlist!" : "Removed from Wishlist",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  makeOrder() async {
    if (wallet != null && id != null) {
      int totalPrice = int.parse(widget.price) * quantity;
      if (int.parse(wallet!) >= totalPrice) {
        int updatedAmount = int.parse(wallet!) - totalPrice;
        await DatabaseMethods().updateWallet(id!, updatedAmount.toString());
        await SharedPreferenceHelper().saveUserWallet(updatedAmount.toString());

        Map<String, dynamic> orderDetailsMap = {
          "Product": widget.name,
          "Quantity": quantity.toString(),
          "Price": totalPrice.toString(),
          "Image": widget.image,
          "Status": "On the way",
        };

        await DatabaseMethods().orderDetails(orderDetailsMap);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF388E3C),
            content: const Text("✅ Order Placed Successfully!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        );
        await getontheload();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.redAccent,
            content: const Text("Insufficient Wallet Balance!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        );
      }
    }
  }

  // ✅ Add to Cart — cart mein daalke cart page pe navigate karo
  void _addToCart(BuildContext context) {
    CartService.instance.addItem(
      name: widget.name,
      price: widget.price,
      image: widget.image,
      detail: widget.detail,
      category: widget.category,
      localFallback: widget.localFallback,
      size: _selectedSize,
      quantity: quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xff6e5038),
        content: const Text("Added to Cart! 🛒",
            style: TextStyle(fontWeight: FontWeight.w600)),
        action: SnackBarAction(
          label: "View Cart",
          textColor: Colors.white,
          onPressed: () {
            // ✅ BottomNav ke Cart tab (index 2) pe navigate karo
            Navigator.of(context).popUntil((route) => route.isFirst);
            // BottomNav rebuild karke cart tab kholo
            // Ya seedha CartPage push karo
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageData,
      {BoxFit fit = BoxFit.cover}) {
    if (imageData.isEmpty) return _fallbackImage();
    try {
      final bytes = base64Decode(imageData);
      return Image.memory(bytes,
          fit: fit,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _fallbackImage());
    } catch (_) {
      if (imageData.startsWith('http')) {
        return Image.network(imageData,
            fit: fit,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _fallbackImage());
      }
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Image.asset(widget.localFallback,
              fit: BoxFit.contain, color: const Color(0xff6e5038)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double originalPrice =
        (double.tryParse(widget.price) ?? 0) * 1.3;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── IMAGE SLIDER ──
                  Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.48,
                        color: const Color(0xFFF0E9E0),
                        child: allImages.isEmpty
                            ? _fallbackImage()
                            : PageView.builder(
                                controller: _pageController,
                                itemCount: allImages.length,
                                onPageChanged: (i) =>
                                    setState(() => currentImageIndex = i),
                                itemBuilder: (context, i) =>
                                    _buildImageWidget(allImages[i]),
                              ),
                      ),

                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFFF7F3EE).withOpacity(0.9),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Image counter badge
                      if (allImages.length > 1)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          right: 70,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${currentImageIndex + 1}/${allImages.length}",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                      // Back Button
                      SafeArea(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, left: 16),
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xff6e5038),
                                size: 18),
                          ),
                        ),
                      ),

                      // ✅ Wishlist Button — clickable & animated
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 16,
                        child: GestureDetector(
                          onTap: _toggleWishlist,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: _isWishlisted
                                  ? const Color(0xFFFF6161)
                                      .withOpacity(0.1)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: Icon(
                              _isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: const Color(0xFFFF6161),
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Dot indicators
                      if (allImages.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              allImages.length,
                              (i) => AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                height: 7,
                                width: i == currentImageIndex ? 20 : 7,
                                decoration: BoxDecoration(
                                  color: i == currentImageIndex
                                      ? const Color(0xff6e5038)
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ✅ Thumbnail row
                  if (allImages.length > 1)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Text("All Photos",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff2D1F14))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: allImages.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final isActive = i == currentImageIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(i,
                                          duration: const Duration(
                                              milliseconds: 300),
                                          curve: Curves.easeInOut);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      width: 60,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isActive
                                              ? const Color(0xff6e5038)
                                              : Colors.grey.shade300,
                                          width: isActive ? 2 : 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(7),
                                        child: _buildImageWidget(
                                            allImages[i],
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── PRODUCT DETAILS ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xff6e5038)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.category.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff6e5038),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        const SizedBox(height: 8),

                        Text(
                          widget.name,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff2D1F14)),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xff6e5038),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Text("4.5",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.star,
                                      color: Colors.white, size: 13),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("128 Reviews",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 8),
                            Container(
                                height: 14,
                                width: 1,
                                color: Colors.grey.shade300),
                            const SizedBox(width: 8),
                            Text("2.4k Sold",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Price block
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹${widget.price}",
                                        style: GoogleFonts.poppins(
                                            color:
                                                const Color(0xff2D1F14),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 26),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 3),
                                        child: Text(
                                          "₹${originalPrice.toStringAsFixed(0)}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              decoration: TextDecoration
                                                  .lineThrough),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "30% OFF",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xFF388E3C),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF388E3C)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text("Free Delivery",
                                        style: GoogleFonts.poppins(
                                            color:
                                                const Color(0xFF388E3C),
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w600)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("by Tomorrow",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Size Selector
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Select Size",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xff2D1F14))),
                            Text("Size Guide →",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xff6e5038),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _sizeChip("S", small, () => setState(() { small=true; medium=false; large=false; xl=false; xxl=false; })),
                            _sizeChip("M", medium, () => setState(() { small=false; medium=true; large=false; xl=false; xxl=false; })),
                            _sizeChip("L", large, () => setState(() { small=false; medium=false; large=true; xl=false; xxl=false; })),
                            _sizeChip("XL", xl, () => setState(() { small=false; medium=false; large=false; xl=true; xxl=false; })),
                            _sizeChip("XXL", xxl, () => setState(() { small=false; medium=false; large=false; xl=false; xxl=true; })),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Quantity
                        Row(
                          children: [
                            Text("Quantity",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: const Color(0xff2D1F14))),
                            const Spacer(),
                            _qtyButton(Icons.remove, () {
                              if (quantity > 1)
                                setState(() => quantity--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Text(quantity.toString(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff2D1F14))),
                            ),
                            _qtyButton(Icons.add,
                                () => setState(() => quantity++)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Description
                        Text("Description",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: const Color(0xff2D1F14))),
                        const SizedBox(height: 8),
                        Text(
                          widget.detail.isNotEmpty
                              ? widget.detail
                              : "No description available.",
                          style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.6),
                        ),

                        // Highlights
                        const SizedBox(height: 18),
                        Text("Highlights",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: const Color(0xff2D1F14))),
                        const SizedBox(height: 10),
                        _highlight(Icons.local_shipping_outlined,
                            "Free delivery on orders above ₹499"),
                        _highlight(Icons.replay_rounded,
                            "7 day easy return & exchange"),
                        _highlight(Icons.verified_outlined,
                            "100% Authentic Products"),
                        _highlight(Icons.payments_outlined,
                            "Cash on Delivery available"),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM ACTION BAR ──
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
                    Text("Total Price",
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 13)),
                    Text(
                      "₹${int.parse(widget.price) * quantity}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: const Color(0xff2D1F14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // ✅ Add to Cart — cart mein add + navigate
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _addToCart(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xff6e5038), width: 2),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_outlined,
                                    color: Color(0xff6e5038), size: 18),
                                const SizedBox(width: 6),
                                Text("Add to Cart",
                                    style: GoogleFonts.poppins(
                                        color: const Color(0xff6e5038),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Buy Now
                    Expanded(
                      child: GestureDetector(
                        onTap: makeOrder,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff8B6346),
                                Color(0xff6e5038)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xff6e5038)
                                      .withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5))
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flash_on_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text("Buy Now",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlight(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xff6e5038)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.poppins(
                      color: Colors.grey[700], fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _sizeChip(
      String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        height: 42,
        width: 46,
        decoration: BoxDecoration(
          color:
              selected ? const Color(0xff6e5038) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? const Color(0xff6e5038)
                  : Colors.grey.shade300),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: const Color(0xff6e5038).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color:
                      selected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, size: 18, color: const Color(0xff6e5038)),
        ),
      );
}