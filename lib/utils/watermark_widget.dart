import 'package:flutter/material.dart';

class WatermarkWidget extends StatelessWidget {
  const WatermarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'developbyjcleite',
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w300),
          ),
          Text(
            'v2.0.0',
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
