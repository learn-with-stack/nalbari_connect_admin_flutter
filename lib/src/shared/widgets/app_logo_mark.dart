import '../../imports/imports.dart';

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 72, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    // Use the provided radius or default to a perfect circle (size / 2)

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle, // Forces circular shape
          border: Border.all(color: cs.outlineVariant),
        ),
        child: ClipOval(
          // Ensures the image is clipped into a perfect circle
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.account_balance_outlined,
                color: cs.primary,
                size: size * 0.5,
              );
            },
          ),
        ),
      ),
    );
  }
}
