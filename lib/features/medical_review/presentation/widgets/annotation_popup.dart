import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import '../../domain/models/drawing_stroke.dart';
import 'drawing_painter.dart';

class AnnotationPopup extends StatefulWidget {
  final String imagePath;
  final bool isNetwork;
  final bool isReadOnly;
  final List<DrawingStroke> initialStrokes;
  final ValueChanged<List<DrawingStroke>> onSave;
  final ValueChanged<List<DrawingStroke>> onSaveAndNavigate;

  const AnnotationPopup({
    super.key,
    required this.imagePath,
    this.isNetwork = false,
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
  
  Color _activeColor = Colors.green; // Default to Low (Green)
  double _brushSize = 5.0;
  double _brushOpacity = 1.0;
  bool _isEraser = false;
  bool _isNormalized = false;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Image Viewer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  widget.onSave(_strokes);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildDrawingArea(),
          ),
          if (!widget.isReadOnly) ...[
            const SizedBox(height: 16),
            _buildFocusArea(),
            const SizedBox(height: 16),
            _buildSliderControl(
              context,
              'Brush Size:',
              _getBrushSizeLabel(_brushSize),
              _brushSize,
              (val) => setState(() => _brushSize = val),
              min: 1.0,
              max: 20.0,
            ),
            const SizedBox(height: 16),
            _buildSliderControl(
              context,
              'Opacity:',
              '${(_brushOpacity * 100).toInt()}%',
              _brushOpacity,
              (val) => setState(() => _brushOpacity = val),
              min: 0.1,
              max: 1.0,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSaveAndNavigate(_strokes);
                },
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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawingArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black, // Fallback background
      ),
      clipBehavior: Clip.hardEdge,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 500,
          height: 500,
          child: GestureDetector(
            onPanStart: widget.isReadOnly ? null : (details) {
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
                if (_currentStroke != null) {
                  _currentStroke!.points.add(details.localPosition);
                }
              });
            },
            onPanEnd: (details) {
              setState(() {
                if (_currentStroke != null) {
                  _strokes.add(_currentStroke!);
                  _currentStroke = null;
                }
              });
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.isNetwork && !_isNormalized
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          _isNormalized ? 'assets/images/normalized_view.png' : widget.imagePath,
                          fit: BoxFit.cover, 
                        ),
                ),
                if (!widget.isReadOnly)
                  Positioned.fill(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: DrawingPainter(
                        strokes: _strokes,
                        currentStroke: _currentStroke,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getBrushSizeLabel(double size) {
    if (size < 5) return 'Small';
    if (size < 12) return 'Medium';
    return 'Large';
  }

  Widget _buildFocusArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Focus Area:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Row(
              children: [
                const Text('Raw', style: TextStyle(fontSize: 12)),
                Switch(
                  value: _isNormalized,
                  onChanged: (val) => setState(() => _isNormalized = val),
                  activeColor: AppColors.primary,
                ),
                const Text('Normalized', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFocusChip('Low', Colors.green),
            _buildFocusChip('Medium', Colors.orange),
            _buildFocusChip('High', Colors.red),
            _buildFocusChip('Normal', Colors.blue),
            _buildFocusChip('White', Colors.grey.shade400, displayColor: Colors.white),
            GestureDetector(
              onTap: () {
                setState(() => _isEraser = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isEraser ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isEraser ? Colors.grey.shade400 : Colors.grey.shade300, width: _isEraser ? 2 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.layers_clear, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Erase',
                      style: TextStyle(fontSize: 12, fontWeight: _isEraser ? FontWeight.bold : FontWeight.normal, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_strokes.isNotEmpty) {
                    _strokes.removeLast(); // Undo logic
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.undo, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Undo',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFocusChip(String label, Color color, {Color? displayColor}) {
    bool isSelected = !_isEraser && _activeColor.value == color.value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEraser = false;
          _activeColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
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
                border: displayColor == Colors.white ? Border.all(color: Colors.grey.shade400) : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl(BuildContext context, String title, String valueText, double value, ValueChanged<double> onChanged, {required double min, required double max}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              valueText,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            activeTrackColor: AppColors.primary.withOpacity(0.5),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: AppColors.primary,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
