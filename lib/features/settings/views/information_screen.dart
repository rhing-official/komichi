import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../l10n/app_localizations.dart';

class InformationScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const InformationScreen({super.key, this.isActive = true});

  @override
  ConsumerState<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends ConsumerState<InformationScreen> {
  final FocusNode _focusNode = FocusNode();
  String? _version;

  // フォーカスはタブがアクティブになった時と画面内クリック時のみ取得する。
  // buildのたびにrequestFocusすると、サイドバーの検索欄など他所にフォーカスが
  // ある状態でも、無関係な再ビルドのたびにフォーカスを奪ってしまう
  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  @override
  void didUpdateWidget(covariant InformationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _shortcutRow(BuildContext context, String keys, String description) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 160,
          child: Text(keys,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: colorScheme.onSurface)),
        ),
        Expanded(
            child: Text(description,
                style: TextStyle(color: colorScheme.onSurfaceVariant))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) => KeyEventResult.ignored,
        child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _focusNode.requestFocus(),
            child: Scaffold(
              appBar: AppBar(title: Text(loc.information)),
              body: ListView(
                children: [
                  const SizedBox(height: 16),
                  const Center(
                      child: Text('komichi',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  Center(
                      child: Text(loc.appTagline,
                          style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(height: 4),
                  Center(
                      child: Text(loc.versionInfo(_version ?? '…'),
                          style: Theme.of(context).textTheme.bodySmall)),
                  const SizedBox(height: 8),
                  const Divider(),
                  _sectionTitle(context, loc.licensesSection),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () => showLicensePage(
                            context: context,
                            applicationName: 'komichi',
                            applicationVersion: _version),
                        child: Text(loc.licensesButton),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  _sectionTitle(context, loc.shortcutsSection),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(loc.shortcutCategoryNavigation,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  _shortcutRow(context, 'Alt + ←  /  Alt + →', loc.shortcutAltArrow),
                  _shortcutRow(
                      context, 'Mouse Back / Forward', loc.shortcutAltArrow),
                  _shortcutRow(context, 'Esc', loc.shortcutEsc),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(loc.shortcutCategoryTabs,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  _shortcutRow(context, 'Ctrl + Tab', loc.shortcutCtrlTab),
                  _shortcutRow(
                      context, 'Ctrl + Shift + Tab', loc.shortcutCtrlShiftTab),
                  _shortcutRow(context, 'Ctrl + T', loc.shortcutCtrlT),
                  _shortcutRow(context, 'Ctrl + W', loc.shortcutCtrlW),
                  _shortcutRow(context, 'Middle Click', loc.shortcutMiddleClick),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(loc.shortcutCategoryScreenFile,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  _shortcutRow(context, 'Ctrl + I', loc.shortcutCtrlI),
                  _shortcutRow(context, 'Ctrl + F', loc.shortcutCtrlF),
                  _shortcutRow(context, 'F1', loc.shortcutF1),
                  _shortcutRow(context, 'Ctrl + S', loc.shortcutCtrlS),
                  _shortcutRow(context, 'Ctrl + A', loc.shortcutCtrlA),
                  _shortcutRow(context, 'Ctrl + Click', loc.shortcutCtrlClick),
                  _shortcutRow(context, 'Shift + Click', loc.shortcutShiftClick),
                  _shortcutRow(context, 'F5', loc.shortcutF5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(loc.shortcutCategoryViewer,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  _shortcutRow(context, '← / →', loc.shortcutArrowLeftRight),
                  _shortcutRow(
                      context, 'Ctrl + ←  /  Ctrl + →', loc.shortcutCtrlArrowLeftRight),
                  _shortcutRow(context, '↑ / ↓', loc.shortcutArrowUpDown),
                  _shortcutRow(context, 'Space / Enter', loc.shortcutSpace),
                  const SizedBox(height: 24),
                ],
              ),
            )));
  }
}
