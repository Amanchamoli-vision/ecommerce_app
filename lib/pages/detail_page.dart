import 'package:clothes_ecommerce/services/database.dart';
import 'package:clothes_ecommerce/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatefulWidget {
  final String image, name, price, detail, category, localFallback;
  const DetailPage({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.detail,
    this.category = "",
    this.localFallback = "images/t-shirt.png", // ✅ Default fallback
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool small = true, medium = false, large = false, xl = false, xxl = false;
  int quantity = 1;
  String? id, wallet;

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  getontheload() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
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

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("✅ Order Placed Successfully!",
              style: TextStyle(fontSize: 18.0)),
        ));
        await getontheload();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Insufficient Balance in Wallet!",
              style: TextStyle(fontSize: 18.0)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product Image ──
                  Stack(
                    children: [
                      // ✅ Network image ho toh dikhao, warna local asset
                      Container(
                        height: screenHeight * 0.48,
                        width: screenWidth,
                        color: const Color(0xFFF0E9E0),
                        child: _buildProductImage(screenHeight, screenWidth),
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

                      // Back Button
                      SafeArea(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, left: 20),
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xff6e5038),
                                size: 18),
                          ),
                        ),
                      ),

                      // Wishlist
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 20,
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite_border_rounded,
                              color: Color(0xff6e5038), size: 20),
                        ),
                      ),
                    ],
                  ),

                  // ── Details ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff2D1F14)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "\$${widget.price}",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xff6e5038),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        // Rating
                        Row(
                          children: [
                            ...List.generate(
                              4,
                              (_) => const Icon(Icons.star_rounded,
                                  color: Color(0xffF5A623), size: 18),
                            ),
                            const Icon(Icons.star_half_rounded,
                                color: Color(0xffF5A623), size: 18),
                            const SizedBox(width: 6),
                            Text("4.5 (128 reviews)",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Size
                        Text("Select Size",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xff2D1F14))),
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

                        const SizedBox(height: 20),

                        // Description
                        Text("Description",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
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

                        const SizedBox(height: 20),

                        // Quantity
                        Text("Quantity",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xff2D1F14))),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _qtyButton(Icons.remove, () {
                              if (quantity > 1) setState(() => quantity--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(quantity.toString(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff2D1F14))),
                            ),
                            _qtyButton(
                                Icons.add, () => setState(() => quantity++)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Total Price",
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 12)),
                    Text(
                      "\$${int.parse(widget.price) * quantity}",
                      style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: const Color(0xff2D1F14)),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: makeOrder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff6e5038),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff6e5038).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Place Order 🛍️",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                      ),
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

  // ✅ Network image pehle try karo, fail ho toh local asset show karo
  Widget _buildProductImage(double screenHeight, double screenWidth) {
    if (widget.image.isNotEmpty) {
      return Image.network(
        widget.image,
        height: screenHeight * 0.48,
        width: screenWidth,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _localProductImage(),
      );
    }
    return _localProductImage();
  }

  Widget _localProductImage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Image.asset(
          widget.localFallback,
          fit: BoxFit.contain,
          color: const Color(0xff6e5038),
        ),
      ),
    );
  }

  Widget _sizeChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        height: 42,
        width: 46,
        decoration: BoxDecoration(
          color: selected ? const Color(0xff6e5038) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xff6e5038)
                : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xff6e5038).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: selected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
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
}