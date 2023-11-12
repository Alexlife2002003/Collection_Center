import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final Widget icon;
  final int badgeValue;

  CustomBadge({
    required this.icon,
    required this.badgeValue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        children: [
          icon,
          if (badgeValue > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Center(
                  child: Text(
                    badgeValue > 99 ? '99+' : badgeValue.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
