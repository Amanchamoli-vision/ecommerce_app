import 'dart:io';
import 'package:clothes_ecommerce/pages/login.dart';
import 'package:clothes_ecommerce/services/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct>
    with TickerProviderStateMixin {
  final List<String> clothingCategory = [
    'T-Shirt',
    'Pant',
    'Dress',
    'Jacket'
  ];
  String? value;

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    nameController.dispose();
    priceController.dispose();
    detailController.dispose();
    super.dispose();
  }

  Future getImage() async {
    var image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  uploadItem() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        detailController.text.isEmpty ||
        value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.redAccent,
          content: const Text("Please fill all fields and select category"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      Map<String, dynamic> addProductData = {
        "Image": "",
        "Name": nameController.text.trim(),
        "Price": priceController.text.trim(),
        "Detail": detailController.text.trim(),
        "Category": value,
      };

      await DatabaseMethods().addProduct(addProductData, value!);

      setState(() {
        isLoading = false;
        selectedImage = null;
        nameController.clear();
        priceController.clear();
        detailController.clear();
        value = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xff2ecc71),
          content: const Text("✅ Product Added Successfully!",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: SlideTransition(
        position: _slideAnim,
        child: CustomScrollView(
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Row(
                      children: [
                        // ✅ BACK BUTTON — Login pe jaane ke liye
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ✅ Icon + Title
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Admin Panel",
                                style: GoogleFonts.poppins(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            Text("Add New Product",
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Image Picker ──
                  Center(
                    child: GestureDetector(
                      onTap: getImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: selectedImage != null
                              ? Colors.transparent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selectedImage != null
                                ? Colors.transparent
                                : const Color(0xff6e5038).withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff6e5038)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.add_photo_alternate_rounded,
                                        color: Color(0xff6e5038),
                                        size: 28),
                                  ),
                                  const SizedBox(height: 10),
                                  Text("Add Photo",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xff6e5038),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  Text("Optional",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 11)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(selectedImage!,
                                    fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Product Name ──
                  _buildLabel("Product Name"),
                  _buildInput(
                    controller: nameController,
                    hint: "e.g. Classic White Tee",
                    icon: Icons.label_rounded,
                  ),
                  const SizedBox(height: 18),

                  // ── Price ──
                  _buildLabel("Price (\$)"),
                  _buildInput(
                    controller: priceController,
                    hint: "e.g. 29",
                    icon: Icons.attach_money_rounded,
                    isNumber: true,
                  ),
                  const SizedBox(height: 18),

                  // ── Detail ──
                  _buildLabel("Product Description"),
                  _buildInput(
                    controller: detailController,
                    hint: "Describe the product...",
                    icon: Icons.description_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),

                  // ── Category Dropdown ──
                  _buildLabel("Category"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category_rounded,
                            color: Color(0xff6e5038), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              items: clothingCategory
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item,
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.w500)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => value = v),
                              hint: Text("Select Category",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14)),
                              value: value,
                              isExpanded: true,
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: const Color(0xff2D1F14),
                                  fontWeight: FontWeight.w600),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xff6e5038)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Category Preview ──
                  if (value != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff6e5038).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xff6e5038).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xff6e5038), size: 18),
                          const SizedBox(width: 10),
                          Text("Category: ",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[600], fontSize: 13)),
                          Text(value!,
                              style: GoogleFonts.poppins(
                                color: const Color(0xff6e5038),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Submit Button ──
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xff6e5038)))
                      : GestureDetector(
                          onTap: uploadItem,
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff8B6346),
                                  Color(0xff6e5038),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff6e5038)
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text("Add Product",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ),
                        ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D1F14),
          )),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xff2D1F14),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
          prefixIcon:
              Icon(icon, color: const Color(0xff6e5038), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}