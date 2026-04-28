import 'dart:convert';
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

class _AddProductState extends State<AddProduct> with TickerProviderStateMixin {
  final List<String> clothingCategory = ['T-Shirt', 'Pant', 'Dress', 'Jacket'];
  String? value;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  // ✅ Multiple images list
  final List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  // ✅ Page controller for image preview
  final PageController _previewController = PageController();
  int _previewIndex = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _previewController.dispose();
    nameController.dispose();
    priceController.dispose();
    detailController.dispose();
    super.dispose();
  }

  // ✅ Gallery se multiple images pick karo
  Future<void> getImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 40);
    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  // ✅ Camera se single image
  Future<void> getCameraImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 40);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  // ✅ Specific image remove karo
  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      if (_previewIndex >= selectedImages.length && _previewIndex > 0) {
        _previewIndex = selectedImages.length - 1;
      }
    });
  }

  Future<String> _convertToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> uploadItem() async {
    if (selectedImages.isEmpty) {
      _showSnack("Please select at least one product image", Colors.redAccent);
      return;
    }
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        detailController.text.trim().isEmpty ||
        value == null) {
      _showSnack("Please fill all fields and select category", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ Saari images ko base64 mein convert karo
      final List<String> base64Images = [];
      for (final img in selectedImages) {
        final b64 = await _convertToBase64(img);
        base64Images.add(b64);
      }

      final Map<String, dynamic> addProductData = {
        "Image": base64Images.first, // backward compatibility ke liye pehli image
        "Images": base64Images,       // ✅ saari images
        "Name": nameController.text.trim(),
        "Price": priceController.text.trim(),
        "Detail": detailController.text.trim(),
        "Category": value,
      };

      await DatabaseMethods().addProduct(addProductData, value!);

      setState(() {
        isLoading = false;
        selectedImages.clear();
        _previewIndex = 0;
        nameController.clear();
        priceController.clear();
        detailController.clear();
        value = null;
      });

      _showSnack("✅ Product Added Successfully!", const Color(0xff2ecc71));
    } catch (e) {
      setState(() => isLoading = false);
      _showSnack("Error: $e", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
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
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Login()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
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

                  // ✅ IMAGE SECTION
                  _buildLabel("Product Images (${selectedImages.length} selected)"),
                  const SizedBox(height: 10),

                  // ✅ Image preview slider (agar koi image hai)
                  if (selectedImages.isNotEmpty) ...[
                    Stack(
                      children: [
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: const Color(0xff6e5038), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PageView.builder(
                              controller: _previewController,
                              itemCount: selectedImages.length,
                              onPageChanged: (i) =>
                                  setState(() => _previewIndex = i),
                              itemBuilder: (context, i) => Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(selectedImages[i],
                                      fit: BoxFit.cover),
                                  // Delete button
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => removeImage(i),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                  // Image number badge
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${i + 1}/${selectedImages.length}",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Dot indicators
                        if (selectedImages.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                selectedImages.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  height: 7,
                                  width: i == _previewIndex ? 20 : 7,
                                  decoration: BoxDecoration(
                                    color: i == _previewIndex
                                        ? const Color(0xff6e5038)
                                        : Colors.white70,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ Thumbnail row
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final isActive = i == _previewIndex;
                          return GestureDetector(
                            onTap: () {
                              _previewController.animateToPage(i,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xff6e5038)
                                      : Colors.grey.shade300,
                                  width: isActive ? 2.5 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(selectedImages[i],
                                    fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ✅ Image pick buttons
                  Row(
                    children: [
                      Expanded(
                        child: _imagePickButton(
                          icon: Icons.photo_library_rounded,
                          label: "Gallery",
                          color: const Color(0xff6e5038),
                          onTap: getImages,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _imagePickButton(
                          icon: Icons.camera_alt_rounded,
                          label: "Camera",
                          color: const Color(0xFF388E3C),
                          onTap: getCameraImage,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      selectedImages.isEmpty
                          ? "⚠️ At least 1 image required"
                          : "✅ ${selectedImages.length} image(s) selected",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: selectedImages.isEmpty
                            ? Colors.redAccent
                            : const Color(0xff2ecc71),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel("Product Name"),
                  _buildInput(
                      controller: nameController,
                      hint: "e.g. Classic White Tee",
                      icon: Icons.label_rounded),
                  const SizedBox(height: 18),

                  _buildLabel("Price (₹)"),
                  _buildInput(
                      controller: priceController,
                      hint: "e.g. 299",
                      icon: Icons.currency_rupee_rounded,
                      isNumber: true),
                  const SizedBox(height: 18),

                  _buildLabel("Product Description"),
                  _buildInput(
                      controller: detailController,
                      hint: "Describe the product...",
                      icon: Icons.description_rounded,
                      maxLines: 4),
                  const SizedBox(height: 18),

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
                                                fontWeight: FontWeight.w500)),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => value = v),
                              hint: Text("Select Category",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[400], fontSize: 14)),
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
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  isLoading
                      ? Column(
                          children: [
                            const CircularProgressIndicator(
                                color: Color(0xff6e5038)),
                            const SizedBox(height: 10),
                            Text("Saving product...",
                                style: GoogleFonts.poppins(
                                    color: const Color(0xff6e5038),
                                    fontSize: 13)),
                          ],
                        )
                      : GestureDetector(
                          onTap: uploadItem,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff8B6346), Color(0xff6e5038)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff6e5038).withOpacity(0.4),
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
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
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
              color: const Color(0xff2D1F14))),
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
              offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff2D1F14)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xff6e5038), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}