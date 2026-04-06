import 'package:flutter/material.dart';

class ProductImageView extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImageView({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  bool get _isNetworkSource =>
      source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (source.trim().isEmpty) {
      return _placeholder();
    }

    if (_isNetworkSource) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EEF3),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined),
    );
  }
}
