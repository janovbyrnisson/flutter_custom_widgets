import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CurvedSlider extends LeafRenderObjectWidget {
  const CurvedSlider({
    Key? key,
    required this.barColor,
    required this.thumbColor,
    this.thumbSize = 20.0,
  }) : super(key: key);

  final Color barColor;
  final Color thumbColor;
  final double thumbSize;

  @override
  RenderCurvedSlider createRenderObject(BuildContext context) {
    return RenderCurvedSlider(
      barColor: barColor,
      thumbColor: thumbColor,
      thumbSize: thumbSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCurvedSlider renderObject) {
    renderObject
      ..barColor = barColor
      ..thumbColor = thumbColor
      ..thumbSize = thumbSize;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('barColor', barColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DoubleProperty('thumbSize', thumbSize));
  }
}

// RENDER OBJECT
class RenderCurvedSlider extends RenderBox {
  static const _minDesiredWidth = 100.0;
  static const _minDesiredHeight = 100.0;

  RenderCurvedSlider({
    required Color barColor,
    required Color thumbColor,
    required double thumbSize,
  })  : _barColor = barColor,
        _thumbColor = thumbColor,
        _thumbSize = thumbSize {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      };
  }

  //--------------------------------------------------------------------------------------------------------------------
  //
  //  PROPERTIES
  //
  //--------------------------------------------------------------------------------------------------------------------

  Color get barColor => _barColor;
  Color _barColor;
  set barColor(Color value) {
    if (_barColor == value) return;
    _barColor = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbColor;
  Color _thumbColor;
  set thumbColor(Color value) {
    if (_thumbColor == value) return;
    _thumbColor = value;
    markNeedsPaint();
  }

  double get thumbSize => _thumbSize;
  double _thumbSize;
  set thumbSize(double value) {
    if (_thumbSize == value) return;
    _thumbSize = value;
    markNeedsLayout();
  }

  //--------------------------------------------------------------------------------------------------------------------
  //
  //  LAYOUT
  //
  //--------------------------------------------------------------------------------------------------------------------

  @override
  double computeMinIntrinsicWidth(double height) => _minDesiredWidth;
  @override
  double computeMaxIntrinsicWidth(double height) => _minDesiredWidth;
  @override
  double computeMinIntrinsicHeight(double width) => _minDesiredHeight;
  @override
  double computeMaxIntrinsicHeight(double width) => _minDesiredHeight;

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final desiredWidth = constraints.maxWidth;
    final desiredHeight = constraints.maxHeight;
    final desiredSize = Size(desiredWidth, desiredHeight);
    return constraints.constrain(desiredSize);
  }

  //--------------------------------------------------------------------------------------------------------------------
  //
  //  HIT TESTING
  //
  //--------------------------------------------------------------------------------------------------------------------

  late HorizontalDragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  //
  //  GESTURES
  //
  //--------------------------------------------------------------------------------------------------------------------

  void _updateThumbPosition(Offset localPosition) {
    var dx = localPosition.dx.clamp(0, size.width);
    _currentThumbValue = dx / size.width;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  //--------------------------------------------------------------------------------------------------------------------
  //
  //  PAINTING
  //
  //--------------------------------------------------------------------------------------------------------------------

  @override
  bool get isRepaintBoundary => true;

  double _currentThumbValue = 0.5;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _paintCurve(canvas);
    _paintThumb(canvas);

    canvas.restore();
  }

  void _paintCurve(Canvas canvas) {
    final barPaint = Paint()
      ..color = barColor
      ..strokeWidth = 5;
    final curve = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height / 2)
      ..cubicTo(
        size.width * _currentThumbValue - 100,
        size.height / 2 - 200,
        size.width * _currentThumbValue + 100,
        size.height / 2 + 200,
        size.width,
        size.height / 2,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(curve, barPaint);
  }

  void _paintThumb(Canvas canvas) {
    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _currentThumbValue * size.width;
    final center = Offset(thumbDx, size.height / 2);
    canvas.drawCircle(center, thumbSize / 2, thumbPaint);
  }
}
