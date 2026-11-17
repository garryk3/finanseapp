// ignore_for_file: type=lint
// uikit: единственное место, где разрешены сырые Material-виджеты
// (см. AGENTS.md «Сырые Material-виджеты», CI-гейты).
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

/// Изображение из asset или memory. Контент-изображение обязано получить
/// [semanticLabel]; декоративное исключается из Semantics.
///
/// Экраны: в v1 почти не используется — AboutScreen (иллюстрация),
/// экраны справочников при наличии иконок категорий.
class AppImage extends StatelessWidget {
  const AppImage.asset(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.semanticLabel,
  }) : bytes = null;

  const AppImage.memory(
    this.bytes, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.semanticLabel,
  }) : name = null;

  final String? name;
  final Uint8List? bytes;
  final double? width, height;
  final BoxFit? fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget image = name != null
        ? Image.asset(
            name!,
            width: width,
            height: height,
            fit: fit,
            excludeFromSemantics: semanticLabel == null,
            semanticLabel: semanticLabel,
          )
        : Image.memory(
            bytes!,
            width: width,
            height: height,
            fit: fit,
            excludeFromSemantics: semanticLabel == null,
            semanticLabel: semanticLabel,
          );
    return image;
  }
}
