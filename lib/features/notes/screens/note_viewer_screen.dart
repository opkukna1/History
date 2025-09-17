// lib/features/notes/screens/note_viewer_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:history_metallum/helpers/database_helper.dart';

// ड्रॉइंग कैनवास बनाने के लिए कस्टम पेंटर
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NoteViewerScreen extends StatefulWidget {
  final Map<String, dynamic> topicData;
  final int? initialPage;
  const NoteViewerScreen({super.key, required this.topicData, this.initialPage});

  @override
  _NoteViewerScreenState createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends State<NoteViewerScreen> {
  late PdfControllerPinch _pdfController;
  final dbHelper = DatabaseHelper.instance;
  bool _isBookmarked = false;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isNightMode = false;
  
  bool _isDrawMode = false;
  List<DrawingPoint?> _currentDrawingPoints = [];
  Color _selectedPenColor = Colors.red;
  double _selectedStrokeWidth = 4.0;
  
  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.topicData['filePath']),
      initialPage: widget.initialPage ?? 1,
    );
    _loadDataForPage(widget.initialPage ?? 1);
  }

  Future<void> _loadDataForPage(int page) async {
    final isBookmarkedFromDB = await dbHelper.isPageBookmarked(widget.topicData['filePath'], page);
    final drawingsFromDB = await dbHelper.getDrawingsForPage(widget.topicData['filePath'], page);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarkedFromDB;
        _currentPage = page;
        _currentDrawingPoints = drawingsFromDB;
      });
    }
  }
  
  void _onToggleBookmark() async {
    await dbHelper.toggleBookmark(widget.topicData['filePath'], widget.topicData['topicName'], _currentPage);
    _loadDataForPage(_currentPage);
  }

  void _clearAllDrawingsOnPage() async {
    await dbHelper.clearDrawingsOnPage(widget.topicData['filePath'], _currentPage);
    _loadDataForPage(_currentPage);
  }

  void _undoLastDrawing() async {
    if (_currentDrawingPoints.isEmpty) return;

    final lastNullIndex = _currentDrawingPoints.lastIndexOf(null);
    if (lastNullIndex == -1) {
      _currentDrawingPoints.clear();
    } else {
      int startIndex = _currentDrawingPoints.sublist(0, lastNullIndex).lastIndexOf(null);
      startIndex = (startIndex == -1) ? 0 : startIndex + 1;
      
      _currentDrawingPoints.removeRange(startIndex, _currentDrawingPoints.length);
    }

    await dbHelper.clearDrawingsOnPage(widget.topicData['filePath'], _currentPage);
    if(_currentDrawingPoints.isNotEmpty) {
      await dbHelper.addDrawing(widget.topicData['filePath'], _currentPage, _currentDrawingPoints);
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget pdfView = ColorFiltered(
      colorFilter: _isNightMode 
        ? const ColorFilter.matrix([-1, 0, 0, 0, 255, 0,-1, 0, 0, 255, 0, 0,-1, 0, 255, 0, 0, 0, 1, 0])
        : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      child: PdfViewPinch(
        controller: _pdfController,
        onPageChanged: (page) => _loadDataForPage(page),
        onDocumentLoaded: (doc) => setState(() => _totalPages = doc.pagesCount),
        // FIX: physics वाली लाइन यहाँ से हटा दी गई है
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicData['topicName']),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: _isDrawMode ? Colors.blue : null),
            tooltip: 'Draw Mode',
            onPressed: () => setState(() => _isDrawMode = !_isDrawMode),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: 'Clear All Drawings on this Page',
            onPressed: _clearAllDrawingsOnPage,
          ),
          IconButton(
            icon: Icon(_isNightMode ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: 'Toggle Night Mode',
            onPressed: () => setState(() => _isNightMode = !_isNightMode),
          ),
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'Bookmark this Page',
            onPressed: _onToggleBookmark,
          ),
        ],
      ),
      body: Stack(
        children: [
          pdfView,
          CustomPaint(
            painter: DrawingPainter(_currentDrawingPoints),
            child: SizedBox.expand(),
          ),
          if (_isDrawMode)
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentDrawingPoints.add(DrawingPoint(
                    offset: details.localPosition,
                    paint: Paint()
                      ..color = _selectedPenColor.withOpacity(0.6)
                      ..strokeWidth = _selectedStrokeWidth
                      ..strokeCap = StrokeCap.round,
                  ));
                });
              },
              onPanUpdate: (details) {
                 setState(() {
                  _currentDrawingPoints.add(DrawingPoint(
                    offset: details.localPosition,
                    paint: Paint()
                      ..color = _selectedPenColor.withOpacity(0.6)
                      ..strokeWidth = _selectedStrokeWidth
                      ..strokeCap = StrokeCap.round,
                  ));
                });
              },
              onPanEnd: (details) async {
                _currentDrawingPoints.add(null);
                await dbHelper.addDrawing(widget.topicData['filePath'], _currentPage, _currentDrawingPoints);
              },
            ),
          
          if (_totalPages > 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_currentPage / $_totalPages', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          
          _buildDrawingPalette(),
        ],
      ),
    );
  }

  Widget _buildDrawingPalette() {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.black];
    final strokeWidths = [4.0, 8.0, 12.0];

    return Visibility(
      visible: _isDrawMode,
      child: Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _undoLastDrawing,
                  tooltip: 'Undo Last Stroke',
                ),
                const VerticalDivider(width: 12, thickness: 1, indent: 8, endIndent: 8),
                ...colors.map((color) => GestureDetector(
                  onTap: () => setState(() => _selectedPenColor = color),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedPenColor == color ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                    width: 32,
                    height: 32,
                  ),
                )).toList(),
                const VerticalDivider(width: 24, thickness: 1, indent: 8, endIndent: 8),
                ...strokeWidths.map((width) => GestureDetector(
                  onTap: () => setState(() => _selectedStrokeWidth = width),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: _selectedStrokeWidth == width ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    width: 32,
                    height: 32,
                    child: Center(child: Icon(Icons.circle, size: width * 1.5)),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
