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

  List<Highlight> _pageHighlights = [];
  
  String? _selectedText;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.topicData['filePath']),
      initialPage: widget.initialPage ?? 1,
    );
    _loadDataForPage(widget.initialPage ?? 1);

    // Listener to update the save button's state
    _pdfController.addListener(() {
      if (mounted) {
        // We use try-catch because accessing selection can sometimes throw an error
        // if no selection exists.
        try {
           if (_pdfController.selection.text != _selectedText) {
              setState(() {
                _selectedText = _pdfController.selection.text;
              });
           }
        } catch (e) {
          if (_selectedText != null) {
            setState(() {
              _selectedText = null;
            });
          }
        }
      }
    });
  }

  Future<void> _loadDataForPage(int page) async {
    final isBookmarkedFromDB = await dbHelper.isPageBookmarked(widget.topicData['filePath'], page);
    final highlightsFromDB = await dbHelper.getHighlightsForPage(widget.topicData['filePath'], page);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarkedFromDB;
        _pageHighlights = highlightsFromDB;
        _currentPage = page;
      });
    }
  }
  
  void _onToggleBookmark() async {
    await dbHelper.toggleBookmark(widget.topicData['filePath'], widget.topicData['topicName'], _currentPage);
    _loadDataForPage(_currentPage);
  }

  void _saveCurrentSelection() async {
    if (_selectedText == null || _selectedText!.trim().isEmpty) return;
    
    await dbHelper.addHighlight(widget.topicData['filePath'], _currentPage, _selectedText!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved for revision!')),
    );
    // The selection will clear automatically when the user taps elsewhere
    _loadDataForPage(_currentPage); // Refresh the list of highlights
  }
  
  void _showPageHighlights() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Saved Notes (Page $_currentPage)', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _pageHighlights.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(_pageHighlights[index].text, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicData['topicName']),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save Selection',
            onPressed: (_selectedText != null && _selectedText!.isNotEmpty)
              ? _saveCurrentSelection
              : null,
          ),

          if (_pageHighlights.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.note_alt),
              tooltip: 'View Saved Notes',
              onPressed: _showPageHighlights,
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
          PdfViewPinch(
            controller: _pdfController,
            onPageChanged: (page) => _loadDataForPage(page),
            onDocumentLoaded: (doc) => setState(() => _totalPages = doc.pagesCount),
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
        ],
      ),
    );
  }
}

