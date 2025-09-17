// lib/features/notes/screens/note_viewer_screen.dart

import 'dart:async'; // Listener के लिए ज़रूरी
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:history_metallum/helpers/database_helper.dart';

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
  Map<int, List<Highlight>> _highlights = {};
  bool _isBookmarked = false;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isNightMode = false;
  
  // FIX: नए स्टेट वेरिएबल्स
  bool _isHighlightMode = false;
  Color _selectedColor = Colors.yellow;
  StreamSubscription<PdfTextSelection?>? _selectionSubscription;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.topicData['filePath']),
      initialPage: widget.initialPage ?? 1,
    );
    _loadAllDataForPage(widget.initialPage ?? 1);

    // FIX: टेक्स्ट सिलेक्शन को सुनने के लिए Listener
    _selectionSubscription = _pdfController.selectionChanges.listen((selection) {
      if (selection != null && _isHighlightMode) {
        _onHighlight(selection, _selectedColor);
        _pdfController.clearSelection(); // हाईलाइट करने के बाद सिलेक्शन हटा दें
      }
    });
  }

  Future<void> _loadAllDataForPage(int page) async {
    final highlightsFromDB = await dbHelper.getHighlightsForPage(widget.topicData['filePath'], page);
    final isBookmarkedFromDB = await dbHelper.isPageBookmarked(widget.topicData['filePath'], page);
    if (mounted) {
      setState(() {
        _highlights[page] = highlightsFromDB;
        _isBookmarked = isBookmarkedFromDB;
        _currentPage = page;
      });
    }
  }
  
  void _onToggleBookmark() async {
    await dbHelper.toggleBookmark(widget.topicData['filePath'], widget.topicData['topicName'], _currentPage);
    _loadAllDataForPage(_currentPage);
  }

  void _clearHighlights() async {
    await dbHelper.clearHighlightsOnPage(widget.topicData['filePath'], _currentPage);
    _loadAllDataForPage(_currentPage);
  }

  void _onHighlight(PdfTextSelection selection, Color color) async {
    if (selection.selectionRects == null || selection.selectedText == null) return;
    for (final rect in selection.selectionRects!) {
      await dbHelper.addHighlight(widget.topicData['filePath'], _currentPage, rect, color.value.toRadixString(16), selection.selectedText!);
    }
    _loadAllDataForPage(_currentPage);
  }
  
  void _showAllHighlights() async {
    final allHighlights = await dbHelper.getAllHighlightsForNote(widget.topicData['filePath']);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('All Highlights', style: Theme.of(context).textTheme.headlineSmall),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: allHighlights.length,
                itemBuilder: (context, index) {
                  final highlight = allHighlights[index];
                  return ListTile(
                    leading: Text('Pg ${highlight.pageNumber}'),
                    title: Text(highlight.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                    tileColor: Color(int.parse(highlight.color, radix: 16)).withOpacity(0.2),
                    onTap: () {
                      _pdfController.jumpToPage(highlight.pageNumber);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _selectionSubscription?.cancel(); // Listener को हटाना ज़रूरी
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
        onPageChanged: (page) => _loadAllDataForPage(page),
        onDocumentLoaded: (doc) => setState(() => _totalPages = doc.pagesCount),
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          builder: (context, pinchBuilders, state) {
            return Stack(
              children: [
                pinchBuilders.pageBuilder(context, state),
                ...(_highlights[_currentPage] ?? []).map((highlight) {
                    return Positioned.fromRect(
                      rect: highlight.rect,
                      child: Container(color: Color(int.parse(highlight.color, radix: 16)).withOpacity(0.4)),
                    );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicData['topicName']),
        actions: [
          // FIX: नया एडिट/हाईलाइट बटन
          IconButton(
            icon: Icon(Icons.edit_note, color: _isHighlightMode ? Colors.blue : null),
            tooltip: 'Highlight Mode',
            onPressed: () => setState(() => _isHighlightMode = !_isHighlightMode),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View All Highlights',
            onPressed: _showAllHighlights,
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
          
          // FIX: कलर चुनने वाला पैलेट
          _buildColorPalette(),
        ],
      ),
    );
  }

  // FIX: कलर पैलेट बनाने वाला नया विजेट
  Widget _buildColorPalette() {
    final colors = [
      Colors.yellow,
      Colors.lightGreenAccent,
      Colors.lightBlueAccent,
      Colors.pinkAccent,
    ];

    return Visibility(
      visible: _isHighlightMode,
      child: Positioned(
        bottom: 70,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.blue, width: 3)
                          : null,
                    ),
                    width: 32,
                    height: 32,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
