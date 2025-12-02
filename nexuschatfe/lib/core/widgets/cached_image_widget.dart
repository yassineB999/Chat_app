import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cached image widget with proper error handling and loading states
class CachedImageWidget extends StatelessWidget {
  const CachedImageWidget({
    super.key,
    required this.imgUrl,
    required this.height,
    required this.width,
    this.radius = 0,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholderColor,
  });

  final String imgUrl;
  final double height;
  final double width;
  final double radius;
  final BoxFit fit;
  final Widget? errorWidget;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Validate URL
    if (imgUrl.isEmpty || imgUrl == 'null') {
      return _buildErrorWidget(theme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        fit: fit,
        height: height,
        width: width,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: placeholderColor ?? theme.colorScheme.surfaceVariant,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(theme),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: height * 0.4,
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }
}
