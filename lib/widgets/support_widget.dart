import 'package:flutter/material.dart';

class Appwidget {
  // Modern Color Palette
  static const Color primaryColor = Color(0xFF2D2E32); // Deep Charcoal
  static const Color secondaryColor = Color(0xFF27AE60); // Forest Green
  static const Color surfaceColor = Color(0xFFF8F9FA); // Off-white/Grey
  static const Color borderColor = Color(0xFFE0E0E0);

  static TextStyle boldTextstyle(double size) {
    return TextStyle(
      color: primaryColor,
      fontSize: size,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    );
  }

  // Responsive Green Style: Changed to a more readable emerald green
  static TextStyle greenTextstyle(double size) {
    return TextStyle(
      color: secondaryColor, 
      fontFamily: "Roboto", 
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  // Helper for responsive size selection boxes
  static Widget _buildSizeContainer({
    required String sizeLabel,
    required Color bgColor,
    required Color textColor,
    required Color strokeColor,
  }) {
    return Container(
      // Using constraints and padding instead of fixed height/width
      // This ensures the box grows if the system font size is increased
      constraints: const BoxConstraints(
        minWidth: 45,
        minHeight: 45,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: strokeColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: bgColor != Colors.transparent 
          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
          : [],
      ),
      child: Center(
        child: Text(
          sizeLabel,
          style: TextStyle(
            color: textColor,
            fontSize: 16, // Base size, scales with system
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget nonSelected(String size) {
    return _buildSizeContainer(
      sizeLabel: size,
      bgColor: Colors.transparent,
      textColor: primaryColor.withOpacity(0.7),
      strokeColor: borderColor,
    );
  }

  static Widget selectedone(String size) {
    return _buildSizeContainer(
      sizeLabel: size,
      bgColor: primaryColor,
      textColor: Colors.white,
      strokeColor: primaryColor,
    );
  }

  static TextStyle? lightTextstyle(double d) {}
}