import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Apple Liquid Glass 風のすりガラス背景。裏の内容をぼかしつつ半透明の色味を
// 重ね、外側の角を丸め、上端にハイライトの縁取りを入れることでガラスの
// 質感を表現する。中身は自身の背景を透明にしておくこと
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const GlassPanel(
      {super.key, required this.child, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.7);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// 背景専用レイヤー（childを持たない）。ガラス効果(BackdropFilter)はスライド
// 中の毎フレーム再計算が非常に重いため、スライド中はブラー無しの不透明背景に
// 切り替える。切り替えはこのウィジェットの「内部」で行うことが重要：型の
// 異なるラッパーでコンテンツを包み替えると、コンテンツのサブツリーごと
// 再マウントされて状態（フォーカス・スクロール位置等）が破棄されてしまう
class PanelBackground extends StatelessWidget {
  final bool glass;
  final BorderRadius borderRadius;
  const PanelBackground(
      {super.key, required this.glass, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // glass/非glassでtint・borderは共通にする（動いている間だけ不透明度の
    // 見え方が変わって浮いて見えないように）。差はBackdropFilterのブラーの
    // 有無だけにする
    final tint = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.7);
    final decoration = BoxDecoration(
      color: tint,
      borderRadius: borderRadius,
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4)),
      ],
    );
    if (!glass) {
      return DecoratedBox(
        decoration: decoration,
        child: const SizedBox.expand(),
      );
    }
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: DecoratedBox(
        decoration: decoration,
        child: const SizedBox.expand(),
      ),
    );
  }
}
