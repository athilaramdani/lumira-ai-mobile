import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import '../../domain/models/drawing_stroke.dart';
import 'drawing_painter.dart';

// ─── Colour palette (matches spec) ────────────────────────────────────────────
const _kColorLow = Color(0xFF00FF00); // Low      / normal     – Green
const _kColorMedium = Color(0xFFFFC107); // Medium   / benign     – Amber
const _kColorHigh = Color(0xFFFF0000); // High     / malignant  – Red
const _kColorNormal = Color(0xFF0099FF); // Normal   / nocancer   – Light Blue
const _kColorWhite = Color(0xFFFFFFFF); // White    / white      – White

class AnnotationPopup extends StatefulWidget {
  final String imagePath; // gradcam URL or fallback asset
  final String? rawImagePath; // raw backend image (used for normalized view)
  final bool isNetwork;
  final bool isRawNetwork; // whether rawImagePath is a network URL
  final bool isReadOnly;
  final List<DrawingStroke> initialStrokes;
  final ValueChanged<List<DrawingStroke>> onSave;
  final ValueChanged<List<DrawingStroke>> onSaveAndNavigate;

  const AnnotationPopup({
    super.key,
    required this.imagePath,
    this.rawImagePath,
    this.isNetwork = false,
    this.isRawNetwork = false,
    this.isReadOnly = false,
    required this.initialStrokes,
    required this.onSave,
    required this.onSaveAndNavigate,
  });

  @override
  State<AnnotationPopup> createState() => _AnnotationPopupState();
}

class _AnnotationPopupState extends State<AnnotationPopup> {
  late List<DrawingStroke> _strokes;
  DrawingStroke? _currentStroke;

  // Drawing options
  Color _activeColor = _kColorLow;
  double _brushSize = 5.0;
  double _brushOpacity = 1.0;
  bool _isEraser = false;
  bool _isNormalized = false;

  // Zoom / pan
  final TransformationController _transformationController =
      TransformationController();
  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;

  // GradCAM opacity slider (0 = hide heatmap, 1 = full heatmap)
  double _gradcamOpacity = 0.6;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // ─── Zoom helpers ─────────────────────────────────────────────────────────
  void _zoomIn() {
    final current = _transformationController.value.getMaxScaleOnAxis();
    final next = (current * 1.3).clamp(_minScale, _maxScale);
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      300 / 2,
    );
    _transformationController.value = Matrix4.identity()
      ..translate(center.dx * (1 - next), center.dy * (1 - next))
      ..scale(next);
  }

  void _zoomOut() {
    final current = _transformationController.value.getMaxScaleOnAxis();
    final next = (current / 1.3).clamp(_minScale, _maxScale);
    if (next <= _minScale) {
      _transformationController.value = Matrix4.identity();
    } else {
      final center = Offset(
        MediaQuery.of(context).size.width / 2,
        300 / 2,
      );
      _transformationController.value = Matrix4.identity()
        ..translate(center.dx * (1 - next), center.dy * (1 - next))
        ..scale(next);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.93,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.biotech, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Image Viewer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Zoom buttons
              _zoomIconBtn(Icons.zoom_in, _zoomIn, 'Zoom In'),
              const SizedBox(width: 4),
              _zoomIconBtn(Icons.zoom_out, _zoomOut, 'Zoom Out'),
              const SizedBox(width: 4),
              _zoomIconBtn(Icons.fit_screen, _resetZoom, 'Reset'),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  widget.onSave(_strokes);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Image area ────────────────────────────────────────────────────
          Expanded(child: _buildImageArea()),

          const SizedBox(height: 12),

          // ── GradCAM opacity slider (both modes) ───────────────────────────
          if (widget.isReadOnly) ...[
            _buildGradcamSlider(),
            const SizedBox(height: 12),
          ],

          // ── Drawing tools (write mode only) ───────────────────────────────
          if (!widget.isReadOnly) ...[
            _buildFocusArea(),
            const SizedBox(height: 12),
            _buildSliderControl(
              context,
              'Brush Size:',
              _getBrushSizeLabel(_brushSize),
              _brushSize,
              (val) => setState(() => _brushSize = val),
              min: 1.0,
              max: 20.0,
            ),
            const SizedBox(height: 8),
            _buildSliderControl(
              context,
              'Opacity:',
              '${(_brushOpacity * 100).toInt()}%',
              _brushOpacity,
              (val) => setState(() => _brushOpacity = val),
              min: 0.1,
              max: 1.0,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => widget.onSaveAndNavigate(_strokes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Annotations',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Image area with InteractiveViewer ────────────────────────────────────
  Widget _buildImageArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black, // Dark background for medical images
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: _minScale,
          maxScale: _maxScale,
          // Allow pan only when zoomed in; drawing gestures take priority when at base scale
          panEnabled: true,
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (widget.isReadOnly) {
      // GradCAM view: apply CSS-equivalent filters via ImageFiltered + ColorFiltered
      return _buildGradcamView();
    }

    // Drawing canvas view
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 400,
          height: 400,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentStroke = DrawingStroke(
                  points: [details.localPosition],
                  color: _activeColor,
                  strokeWidth: _brushSize,
                  opacity: _brushOpacity,
                  isEraser: _isEraser,
                );
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _currentStroke?.points.add(details.localPosition);
              });
            },
            onPanEnd: (_) {
              setState(() {
                if (_currentStroke != null) {
                  _strokes.add(_currentStroke!);
                  _currentStroke = null;
                }
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base image (raw or normalized)
                _buildBaseImage(),
                // Drawing layer
                CustomPaint(
                  size: Size.infinite,
                  painter: DrawingPainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradcamView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Raw image beneath heatmap
        if (widget.isNetwork)
          Image.network(widget.imagePath, fit: BoxFit.cover)
        else
          Image.asset(widget.imagePath, fit: BoxFit.cover),

        // GradCAM heatmap overlay with simulated CSS effects:
        // blur(8px) → ImageFiltered with sigma=8
        // contrast(1.2) → ColorFiltered with contrast matrix
        // blend-mode hard-light → BlendMode.hardLight
        Opacity(
          opacity: _gradcamOpacity,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                // contrast(1.2) matrix
                1.2, 0, 0, 0, -0.1 * 255,
                0, 1.2, 0, 0, -0.1 * 255,
                0, 0, 1.2, 0, -0.1 * 255,
                0, 0, 0, 1, 0,
              ]),
              child: widget.isNetwork
                  ? Image.network(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      color: Colors.transparent,
                      colorBlendMode: BlendMode.hardLight,
                    )
                  : Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      color: Colors.transparent,
                      colorBlendMode: BlendMode.hardLight,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseImage() {
    if (!_isNormalized) {
      // Apply normalized effect to the actual raw backend image
      final hasRaw =
          widget.rawImagePath != null && widget.rawImagePath!.isNotEmpty;
      final isNet = widget.isRawNetwork;
      return ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: hasRaw
            ? (isNet
                ? Image.network(widget.rawImagePath!, fit: BoxFit.cover)
                : Image.asset(widget.rawImagePath!, fit: BoxFit.cover))
            : (widget.isNetwork
                ? Image.network(widget.imagePath, fit: BoxFit.cover)
                : Image.asset(widget.imagePath, fit: BoxFit.cover)),
      );
    }

    if (widget.isNetwork) {
      return Image.network(widget.imagePath, fit: BoxFit.cover);
    }
    return Image.asset(widget.imagePath, fit: BoxFit.cover);
  }

  // ─── GradCAM opacity slider ───────────────────────────────────────────────
  Widget _buildGradcamSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GradCAM Intensity:',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            Text(
              '${(_gradcamOpacity * 100).toInt()}%',
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            activeTrackColor: AppColors.primary.withOpacity(0.8),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: AppColors.primary,
          ),
          child: Slider(
            value: _gradcamOpacity,
            min: 0.0,
            max: 1.0,
            onChanged: (val) => setState(() => _gradcamOpacity = val),
          ),
        ),
      ],
    );
  }

  // ─── Focus area (colour picker + normalized toggle) ───────────────────────
  Widget _buildFocusArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Focus Area:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isNormalized = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !_isNormalized ? AppColors.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Raw Pixels',
                      style: TextStyle(
                        fontSize: 12, 
                        color: !_isNormalized ? Colors.white : Colors.grey.shade700, 
                        fontWeight: !_isNormalized ? FontWeight.w600 : FontWeight.w500
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _isNormalized = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isNormalized ? AppColors.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Normalized',
                      style: TextStyle(
                        fontSize: 12, 
                        color: _isNormalized ? Colors.white : Colors.grey.shade700, 
                        fontWeight: _isNormalized ? FontWeight.w600 : FontWeight.w500
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFocusChip('Low', _kColorLow, label2: 'normal'),
            _buildFocusChip('Medium', _kColorMedium, label2: 'benign'),
            _buildFocusChip('High', _kColorHigh, label2: 'malignant'),
            _buildFocusChip('Normal', _kColorNormal, label2: 'nocancer'),
            _buildFocusChip('White', _kColorWhite,
                label2: 'white', displayColor: _kColorWhite, withBorder: true),
            // Eraser
            GestureDetector(
              onTap: () => setState(() => _isEraser = true),
              child: _toolChip(
                icon: Icons.layers_clear,
                label: 'Erase',
                active: _isEraser,
              ),
            ),
            // Undo
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_strokes.isNotEmpty) _strokes.removeLast();
                });
              },
              child: _toolChip(icon: Icons.undo, label: 'Undo', active: false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFocusChip(
    String label,
    Color color, {
    String? label2,
    Color? displayColor,
    bool withBorder = false,
  }) {
    final isSelected = !_isEraser && _activeColor.value == color.value;
    return GestureDetector(
      onTap: () => setState(() {
        _isEraser = false;
        _activeColor = color;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: displayColor ?? color,
                shape: BoxShape.circle,
                border:
                    withBorder ? Border.all(color: Colors.grey.shade400) : null,
              ),
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : Colors.black87,
                  ),
                ),
                if (label2 != null)
                  Text(
                    label2,
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolChip(
      {required IconData icon, required String label, required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.grey.shade200 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: active ? Colors.grey.shade400 : Colors.grey.shade300,
            width: active ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  // ─── Generic slider ───────────────────────────────────────────────────────
  Widget _buildSliderControl(
    BuildContext context,
    String title,
    String valueText,
    double value,
    ValueChanged<double> onChanged, {
    required double min,
    required double max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            Text(valueText,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            activeTrackColor: AppColors.primary.withOpacity(0.7),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: AppColors.primary,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  // ─── Zoom icon button ─────────────────────────────────────────────────────
  Widget _zoomIconBtn(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }

  String _getBrushSizeLabel(double size) {
    if (size < 5) return 'Small';
    if (size < 12) return 'Medium';
    return 'Large';
  }
}
