import '../../imports/imports.dart';

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 72, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? size * 0.22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.account_balance_outlined,
                color: cs.primary,
                size: size * 0.42,
              );
            },
          ),
        ),
      ),
    );
  }
}
