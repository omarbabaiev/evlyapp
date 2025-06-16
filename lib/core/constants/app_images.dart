import 'package:flutter/material.dart';

class AppImages {
  // Asset paths
  static const String logoWord = 'assets/images/logo_word.png';
  static const String splash = 'assets/images/splash.png';

  // Placeholder widget for CachedNetworkImage
  static Widget cachedNetworkImagePlaceholder({
    double opacity = 0.3,
    BoxFit fit = BoxFit.contain,
  }) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            logoWord,
            fit: fit,
          ),
        ),
      ),
    );
  }

  // Error widget for CachedNetworkImage
  static Widget cachedNetworkImageError({
    double opacity = 0.3,
    BoxFit fit = BoxFit.contain,
  }) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            logoWord,
            fit: fit,
          ),
        ),
      ),
    );
  }
}
