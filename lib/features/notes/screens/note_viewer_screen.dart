// lib/features/notes/screens/note_viewer_screen.dart

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
  bool _isBookmarked = false;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isNightMode = false;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.topicData['filePath']),
      initialPage: widget.initialPage ?? 1,
    );
    _loadBookmarkDataForPage(widget.initialPage ?? 1);
  }

  Future<void> _loadBookmarkDataForPage(int page) async {
    final isBookmarkedFromDB = await dbHelper.isPageBookmarked(widget.topicData['filePath'], page);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarkedFromDB;
        _currentPage = page;
      });
    }
  }
  
  void _onToggleBookmark() async {
    await dbHelper.toggleBookmark(widget.topicData['filePath'], widget.topicData['topicName'], _currentPage);
    _loadBookmarkDataForPage(_currentPage);
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
        ? const ColorFilter.matrix([
            -1, 0, 0, 0, 255,
             0,-1, 0, 0, 255,
             0, 0,-1, 0, 255,
             0, 0, 0, 1, 0,
          ])
        : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      child: PdfViewPinch(
        controller: _pdfController,
        onPageChanged: (page) => _loadBookmarkDataForPage(page),
        onDocumentLoaded: (doc) => setState(() => _totalPages = doc.pagesCount),
        // FIX: onTextSelected और builders को हटा दिया गया है क्योंकि वे एरर दे रहे थे
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicData['topicName']),
        actions: [
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
        ],
      ),
    );
  }
}
