import 'package:flutter/material.dart';

class KomichiTheme {
  KomichiTheme._(); // インスタンス化禁止

  // ---- カラー定義 ----
  static const Color _primary = Color(0xFF8B5E3C); // 茶色（メイン）
  static const Color _onPrimary = Color(0xFFFFFFFF); // 白文字
  static const Color _accent = Color(0xFF5C3D2E); // ダークブラウン（アクセント）
  static const Color _background = Color(0xFFF5F0E8); // 薄いベージュ（背景）
  static const Color _surface = Color(0xFFEDE6D6); // カード背景
  static const Color _onSurface = Color(0xFF2E1F0F); // 本文テキスト

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: _primary,
        onPrimary: _onPrimary,
        secondary: _accent,
        surface: _surface,
        onSurface: _onSurface,
      ),
      scaffoldBackgroundColor: _background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      // カード
      cardTheme: const CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // テキスト
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: _onSurface, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: _onSurface),
        bodyMedium: TextStyle(color: _onSurface),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: _onPrimary,
      ),
    );
  }
}
