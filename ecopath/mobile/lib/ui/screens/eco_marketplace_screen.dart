import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EcoMarketplaceScreen extends StatefulWidget {
  const EcoMarketplaceScreen({super.key});

  @override
  State<EcoMarketplaceScreen> createState() => _EcoMarketplaceScreenState();
}

class _EcoMarketplaceScreenState extends State<EcoMarketplaceScreen> {
  final List<Map<String, dynamic>> products = [
    {
      "name": "General Waste Bag (100L, 10pcs)",
      "image": "assets/images/general_bag.png",
      "price": "₩5,600",
      "unit": "(₩560 per bag)",
      "delivery": "🚀 Next-day eco delivery",
      "rating": 4.7,
      "reviews": 610
    },
    {
      "name": "Food Waste Bag (20L, 10pcs)",
      "image": "assets/images/food_bag.png",
      "price": "₩4,690",
      "unit": "(₩469 per bag)",
      "delivery": "🚀 Arrives by tomorrow",
      "rating": 4.8,
      "reviews": 21146
    },
    {
      "name": "Garbage Bag for Goods (60L, 200pcs)",
      "image": "assets/images/recycle_bag.png",
      "price": "₩9,620",
      "unit": "(₩48 per bag)",
      "delivery": "🌿 Fast eco-shipping",
      "rating": 4.8,
      "reviews": 42152
    },
    {
      "name": "Eco Black Plastic Bag",
      "images": [
        "assets/images/bag3.png",
        "assets/images/bag3_1.png",
        "assets/images/L7.png",
        "assets/images/L9.png",
        "assets/images/L13.png",
        "assets/images/L20.png",
        "assets/images/L40.png",
      ],
      "price": "₩1,900",
      "unit": "(₩85 per bag)",
      "delivery": "🌿 Eco delivery available",
      "rating": 4.9,
      "reviews": 845,
      "sizes": ["7L", "9L", "13L", "20L", "40L"],
      "colors": ["Black", "White"],
    },
    {
      "name": "Eco NTH Bag",
      "images": [
        "assets/images/nth1.png",
        "assets/images/nth2.png",
        "assets/images/nth3.png"
      ],
      "price": "₩2,000",
      "unit": "1 per bag",
      "delivery": "🚚 Free 2-day eco shipping",
      "rating": 4.8,
      "reviews": 1542
    },
    {
      "name": "Red Recycle Bag ",
      "images": [
        "assets/images/red1.png",
        "assets/images/red2.png"
      ],
      "price": "₩2,850",
      "unit": "1 per bag",
      "delivery": "♻️ Eco courier delivery",
      "rating": 4.7,
      "reviews": 289
    },
  ];

  int cartCount = 0;
  String selectedSize = "7L";
  String selectedColor = "Black";
  String searchQuery = "";

  void addToCart(String productName) {
    setState(() => cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$productName added to cart 🛒"),
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProductOptions(Map<String, dynamic> product) {
    final sizes = product["sizes"] ?? ["7L", "9L", "13L", "20L", "40L"];
    final colors = product["colors"] ?? ["Black", "White"];
    String tempSize = selectedSize;
    String tempColor = selectedColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(product["name"],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(product["price"],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                            fontSize: 18)),
                    Text(product["unit"],
                        style: GoogleFonts.lato(
                            fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 16),

                    Text("Choose Size",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: sizes.map<Widget>((size) {
                        return ChoiceChip(
                          label: Text(size),
                          selected: tempSize == size,
                          selectedColor: const Color(0xFF00A676),
                          onSelected: (_) {
                            setModalState(() => tempSize = size);
                          },
                          labelStyle: TextStyle(
                            color: tempSize == size
                                ? Colors.white
                                : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    Text("Choose Color",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    Row(
                      children: colors.map<Widget>((color) {
                        return GestureDetector(
                          onTap: () => setModalState(() => tempColor = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: tempColor == color
                                  ? (color == "Black"
                                      ? Colors.black
                                      : Colors.white)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: tempColor == color
                                    ? const Color(0xFF00A676)
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              color,
                              style: GoogleFonts.poppins(
                                color: tempColor == color
                                    ? (color == "Black"
                                        ? Colors.white
                                        : Colors.black)
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            selectedSize = tempSize;
                            selectedColor = tempColor;
                          });
                          addToCart(
                              "${product["name"]} ($tempSize, $tempColor)");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF004D40), Color(0xFF00A676)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Add to Cart",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products
        .where((p) => p["name"]
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Eco Marketplace",
          style: GoogleFonts.poppins(
            color: const Color(0xFF00221C),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF00221C), size: 26),
                onPressed: () {},
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search eco products...",
                        hintStyle:
                            GoogleFonts.poppins(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🏷️ Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip("Bags", true),
                  _buildChip("Cleaning", false),
                  _buildChip("Recycling", false),
                  _buildChip("Home", false),
                  _buildChip("Compost", false),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 🛍 Products grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildSimpleProductCard(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF00221C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : const Color(0xFF00221C),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSimpleProductCard(Map<String, dynamic> product) {
    final imageList = (product["images"] ?? [product["image"]]);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 90,
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: imageList.length,
                  itemBuilder: (context, imgIndex) {
                    return Image.asset(imageList[imgIndex],
                        fit: BoxFit.contain);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00221C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product["price"],
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            Text(
              product["unit"],
              style: GoogleFonts.lato(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade400, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${product["rating"]}",
                  style: GoogleFonts.lato(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  " (${product["reviews"]} reviews)",
                  style: GoogleFonts.lato(
                      fontSize: 10.5, color: Colors.black54),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  if (product["name"]
                      .toString()
                      .contains("Eco Black Plastic Bag")) {
                    _showProductOptions(product);
                  } else {
                    addToCart(product["name"]);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF00A676)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text("Add to Cart",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
