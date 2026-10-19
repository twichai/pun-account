import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Clean, scalable vector Google "G" logo rendered from SVG asset.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/google.svg',
      width: size,
      height: size,
    );
  }
}
