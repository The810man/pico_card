import 'package:flutter/material.dart';

class PixelTheme {
  // Pixel color palette
  static const Color pixelBlack = Color(0xFF0A0A0A);
  static const Color pixelGray = Color(0xFF2A2A2A);
  static const Color pixelLightGray = Color(0xFF4A4A4A);
  static const Color pixelWhite = Color(0xFFFFFFFF);
  static const Color pixelYellow = Color(0xFFFFD700);
  static const Color pixelRed = Color(0xFFFF4444);
  static const Color pixelBlue = Color(0xFF4444FF);
  static const Color pixelGreen = Color(0xFF44FF44);
  static const Color pixelPurple = Color(0xFF8844FF);
  static const Color pixelOrange = Color(0xFFFF8844);
  static const Color uiBoxBg = Color.fromARGB(255, 130, 118, 156);

  // Rarity colors
  static const Color commonColor = Color(0xFF888888);
  static const Color rareColor = Color(0xFF4488FF);
  static const Color epicColor = Color(0xFFAA44FF);
  static const Color legendaryColor = Color(0xFFFF8800);
  static const Color brokenColor = Color.fromARGB(255, 255, 0, 76);

  static TextStyle pixelText({
    double fontSize = 12,
    Color color = pixelWhite,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontFamily: 'SuperPixel',
      letterSpacing: 0.5,
    );
  }

  static TextStyle pixelTextBold({
    double fontSize = 12,
    Color color = pixelWhite,
  }) {
    return pixelText(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static BoxDecoration pixelContainer({
    Color color = pixelGray,
    Color borderColor = pixelLightGray,
    double borderWidth = 2,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: BorderRadius.zero, // Sharp pixel corners
    );
  }

  static BoxDecoration pixelButton({
    Color color = pixelBlue,
    Color borderColor = pixelWhite,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: 2),
      borderRadius: BorderRadius.zero,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  static InputDecoration pixelInput({
    String? hintText,
    Color borderColor = pixelLightGray,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: pixelText(color: pixelLightGray),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: pixelYellow, width: 2),
      ),
      filled: true,
      fillColor: pixelGray,
    );
  }
}

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double width;
  final double height;
  final IconData? icon;

  const PixelButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color = PixelTheme.pixelBlue,
    this.textColor = PixelTheme.pixelWhite,
    this.width = 120,
    this.height = 40,
    this.icon,
  }) : super(key: key);

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: PixelTheme.pixelButton(
                color: _isPressed
                    ? widget.color.withOpacity(0.8)
                    : widget.color,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 26),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: PixelTheme.pixelTextBold(
                        color: widget.textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PixelCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;

  const PixelCard({
    Key? key,
    required this.child,
    this.backgroundColor = PixelTheme.pixelGray,
    this.borderColor = PixelTheme.pixelLightGray,
    this.borderWidth = 2,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: PixelTheme.pixelContainer(
        color: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: child,
    );
  }
}
