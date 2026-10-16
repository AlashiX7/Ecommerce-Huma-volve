import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/product_link_config.dart';

class ShareProductButton extends StatelessWidget {
  final int productId;

  const ShareProductButton({super.key, required this.productId});

  Future<void> _share(BuildContext context) async {
    final productUri = buildProductShareUri(
      productId,
      hostingBaseUrl: productLinksHostingBaseUrl,
    );
    if (productUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product sharing will be available after Hosting is configured.',
          ),
        ),
      );
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out this product: $productUri',
          subject: 'Product details',
          sharePositionOrigin: _sharePositionOrigin(context),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the share menu. Try again.'),
        ),
      );
    }
  }

  Rect? _sharePositionOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('share-product-button'),
      tooltip: 'Share product',
      onPressed: () => _share(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.share_outlined, size: 18),
      ),
    );
  }
}
