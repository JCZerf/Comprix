import 'package:flutter/material.dart';

class WatermarkWidget extends StatelessWidget {
  const WatermarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Developed by JCLeite',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
          Text(
            'v2.2.0',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
