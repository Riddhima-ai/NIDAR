import 'package:flutter/material.dart';

class DesignScale extends StatelessWidget {
  final Widget child;
  final double designWidth;
  final double designHeight;

  const DesignScale({
    super.key,
    required this.child,
    this.designWidth = 1440,
    this.designHeight = 900,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaleX = constraints.maxWidth / designWidth;
          final scaleY = constraints.maxHeight / designHeight;
         
          final scale = scaleX < scaleY ? scaleX : scaleY;

          return Center(
            child: SizedBox(
              width: designWidth * scale,
              height: designHeight * scale,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: designWidth,
                maxWidth: designWidth,
                minHeight: designHeight,
                maxHeight: designHeight,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: MediaQuery(
                    // Force every descendant's MediaQuery.size to the
                    // fixed design size, regardless of the real window.
                    data: MediaQuery.of(context).copyWith(
                      size: Size(designWidth, designHeight),
                      devicePixelRatio: 1.0,
                    ),
                    child: SizedBox(
                      width: designWidth,
                      height: designHeight,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}