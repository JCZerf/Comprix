import 'package:flutter/material.dart';

class WatermarkWidget extends StatelessWidget {
  const WatermarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Marca d'água no canto inferior esquerdo
            Text(
              'developbyjcleite',
              style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w300),
            ),
            // Versão no canto inferior direito
            Text(
              'v2.0.0',
              style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
