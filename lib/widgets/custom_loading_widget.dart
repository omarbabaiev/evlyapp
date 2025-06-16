import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomLoadingWidget extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const CustomLoadingWidget({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: Theme.of(context).colorScheme.surface,
        highlightColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: child,
    );
  }
}

class CustomCircularLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const CustomCircularLoading({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? Theme.of(context).primaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
