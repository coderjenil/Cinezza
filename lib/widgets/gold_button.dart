import 'package:flutter/material.dart';

class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool expanded;
  final double height;
  final double radius;

  const GoldButton({
    super.key,
    required this.text,
    required this.onTap,
    this.expanded = true,
    this.height = 52,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE08C), Color(0xFFE6B44B), Color(0xFFC89635)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
