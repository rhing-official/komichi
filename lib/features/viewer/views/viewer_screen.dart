import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewer_provider.dart';
import '../../../core/providers/tab_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/models/app_settings.dart';

// app.dart側でサイドバーがこのメニューと重ならないよう高さを共有する
const double kViewerBottomMenuHeight = 120;

class ViewerScreen extends ConsumerStatefulWidget {
  final String bookId;
  final bool isActive;
  const ViewerScreen({super.key, required this.bookId, this.isActive = true});
  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final FocusNode _focusNode = FocusNode();

  // フォーカスはタブがアクティブになった時と画面タップ時(onTapUp)のみ取得する。
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
  }

  @override
  void didUpdateWidget(covariant ViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) _focusNode.requestFocus();
  }

  void _handleZoom(PointerScrollEvent event) {
    final double zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
    final double currentScale =
        _transformationController.value.getMaxScaleOnAxis();
    final double newScale = (currentScale * zoomFactor).clamp(1.0, 10.0);
    if (newScale == 1.0 && currentScale == 1.0) {
      _transformationController.value = Matrix4.identity();
      return;
    }
    final Offset localCursor = event.localPosition;
    final Matrix4 matrix = _transformationController.value;
    final double dx =
        (localCursor.dx - matrix.getTranslation().x) / currentScale;
    final double dy =
        (localCursor.dy - matrix.getTranslation().y) / currentScale;
    setState(() {
      _transformationController.value = Matrix4.identity()
        ..translate(
            localCursor.dx - dx * newScale, localCursor.dy - dy * newScale)
        ..scale(newScale);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(viewerProvider(widget.bookId));
    final notifier = ref.read(viewerProvider(widget.bookId).notifier);
    final settings = ref.watch(settingsProvider);
    final tabNotifier = ref.read(tabProvider.notifier);
    final bool isLeftToNext =
        settings.pageDirection == PageDirection.leftToNext;

    if (state.isLoading)
      return const Center(child: CircularProgressIndicator());

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      descendantsAreFocusable: false,
      onKeyEvent: (node, event) {
        final isDown = event is KeyDownEvent;
        final isRepeat = event is KeyRepeatEvent;
        if (!isDown && !isRepeat) return KeyEventResult.ignored;
        final key = event.logicalKey;
        final isCtrl = HardwareKeyboard.instance.isControlPressed;

        // ★ Ctrl+Tab などのブラウザ制御系は無視（親ウィジェットにスルーさせる）
        if (isCtrl && key == LogicalKeyboardKey.tab)
          return KeyEventResult.ignored;

        if (isDown) {
          if (key == LogicalKeyboardKey.escape) {
            final tabState = ref.read(tabProvider);
            tabNotifier.closeBook(tabState.tabs[tabState.currentIndex]);
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.arrowDown) {
            notifier.switchBook(true);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowUp) {
            notifier.switchBook(false);
            return KeyEventResult.handled;
          }
          if (isCtrl) {
            if (key == LogicalKeyboardKey.arrowLeft ||
                key == LogicalKeyboardKey.numpad4) {
              isLeftToNext
                  ? notifier.jumpToPage(state.totalPages - 1)
                  : notifier.jumpToPage(0);
              return KeyEventResult.handled;
            }
            if (key == LogicalKeyboardKey.arrowRight ||
                key == LogicalKeyboardKey.numpad6) {
              isLeftToNext
                  ? notifier.jumpToPage(0)
                  : notifier.jumpToPage(state.totalPages - 1);
              return KeyEventResult.handled;
            }
          }
          if (key == LogicalKeyboardKey.space) {
            notifier.toggleUI();
            return KeyEventResult.handled;
          }
        }

        // ページめくりは長押し中(KeyRepeatEvent)も連続して実行する
        if (!isCtrl) {
          if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.numpad4) {
            notifier.nextPage();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.numpad6) {
            notifier.previousPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor:
            state.showUI ? SystemMouseCursors.basic : SystemMouseCursors.none,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) _handleZoom(event);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) {
                  _focusNode.requestFocus();
                  notifier.toggleUI();
                },
                child: SizedBox.expand(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 10.0,
                    panEnabled: true,
                    scaleEnabled: false,
                    child: Center(
                        child: notifier.currentImageBytes != null
                            ? Image.memory(notifier.currentImageBytes!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                gaplessPlayback: true)
                            : const CircularProgressIndicator(
                                color: Colors.white24)),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: state.showUI ? 0 : -130,
                left: 0,
                right: 0,
                child: _buildBottomMenu(settings, state, notifier)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBottomMenu(AppSettings settings, state, notifier) {
    final bool isLeftToNext =
        settings.pageDirection == PageDirection.leftToNext;
    return Container(
      height: kViewerBottomMenuHeight,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          border:
              const Border(top: BorderSide(color: Colors.white12, width: 0.5))),
      child: Column(children: [
        SizedBox(
          height: 20,
          child: Stack(children: [
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text('${state.totalPages}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text('${state.currentPage + 1}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
          ]),
        ),
        Directionality(
            textDirection: isLeftToNext ? TextDirection.rtl : TextDirection.ltr,
            child: Slider(
                value: state.currentPage.toDouble(),
                max:
                    (state.totalPages - 1).toDouble().clamp(0, double.infinity),
                onChanged: (v) => notifier.jumpToPage(v.toInt()))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              tooltip: isLeftToNext ? '最後のページへ' : '最初のページへ',
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () =>
                  notifier.jumpToPage(isLeftToNext ? state.totalPages - 1 : 0)),
          IconButton(
              tooltip: isLeftToNext ? '最初のページへ' : '最後のページへ',
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () =>
                  notifier.jumpToPage(isLeftToNext ? 0 : state.totalPages - 1)),
          const SizedBox(width: 40),
          IconButton(
              tooltip: isLeftToNext ? '次の本へ' : '前の本へ',
              icon: _bookNavIcon(isNext: isLeftToNext),
              onPressed: () => notifier.switchBook(isLeftToNext)),
          IconButton(
              tooltip: isLeftToNext ? '前の本へ' : '次の本へ',
              icon: _bookNavIcon(isNext: !isLeftToNext),
              onPressed: () => notifier.switchBook(!isLeftToNext)),
        ]),
      ]),
    );
  }

  // 本の切り替えは矢印キーの↓(次の本)/↑(前の本)に対応しているため、
  // アイコンもそれに合わせて下向き/上向き矢印にする
  Widget _bookNavIcon({required bool isNext}) {
    return Icon(
      isNext ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
      color: Colors.white,
      size: 32,
    );
  }
}
