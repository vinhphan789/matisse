import 'dart:ui';

import 'package:matisse/images/image_app.dart';

enum WebShopStep {
  optishadeStyleItaliano,
  matisseColorModelStains,
  colorModelResin,
  matisseSiliconePad,
  matisseStainingKit;

  String get title {
    switch (this) {
      case WebShopStep.optishadeStyleItaliano:
        return 'Optishade StyleItaliano';
      case WebShopStep.matisseColorModelStains:
        return 'Matisse ColorModel Stains';
      case WebShopStep.colorModelResin:
        return 'Color Model Resin';
      case WebShopStep.matisseSiliconePad:
        return 'Matisse Mixing Tray & Silicone Portioner';
      case WebShopStep.matisseStainingKit:
        return 'Matisse Staining Instruments Full Kit';
    }
  }

  String get description {
    switch (this) {
      case WebShopStep.optishadeStyleItaliano:
        return 'The image taken by OS can directly be imported into Matisse, which can be further used to generate ceramic recipes.';
      case WebShopStep.matisseColorModelStains:
        return 'Flowable stains to correct the 3D printed aesthetic model and match the color of the preparation.';
      case WebShopStep.colorModelResin:
        return 'Replicate the color of the preparation and adjacent teeth precisely.';
      case WebShopStep.matisseSiliconePad:
        return 'The precise portioner for ceramic pastes, easy mixing and consistent results.';
      case WebShopStep.matisseStainingKit:
        return 'The complete toolkit for staining.';
    }
  }

  String get continueTitle {
    switch (this) {
      case WebShopStep.optishadeStyleItaliano:
        return 'YES, I HAVE';
      default:
        return 'NEXT TIME';
    }
  }

  String get requestTitle {
    switch (this) {
      case WebShopStep.optishadeStyleItaliano:
      case WebShopStep.matisseSiliconePad:
        return 'Must-Have';
      default:
        return 'Good-to-Have';
    }
  }

  Color get requestBadgeColor {
    switch (this) {
      case WebShopStep.optishadeStyleItaliano:
      case WebShopStep.matisseSiliconePad:
        return const Color(0xFFEB2F96); // hồng
      default:
        return const Color(0xFF373EE5); // xanh
    }
  }

  /// Tên ảnh — thay bằng tên thật trong ImageApp sau
  String get imagePath {
    switch (this) {
      case WebShopStep.optishadeStyleItaliano:
        return ImageApp.webShopImaage;        // TODO: thay tên thật
      case WebShopStep.matisseColorModelStains:
        return ImageApp.colorModelStainsIcon;
      case WebShopStep.colorModelResin:
        return ImageApp.colorModelResigIcon;
      case WebShopStep.matisseSiliconePad:
        return ImageApp.matisseSiliconeIcon;
      case WebShopStep.matisseStainingKit:
        return ImageApp.matisseStainingIcon;
    }
  }

  WebShopStep? get next {
    final all = WebShopStep.values;
    final idx = all.indexOf(this);
    if (idx < all.length - 1) return all[idx + 1];
    return null; // đã là trang cuối
  }
}