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

  void _saveForRevision(String selection) async {
    if (selection.trim().isEmpty) return;
    await dbHelper.addHighlight(widget.topicData['filePath'], _currentPage, selection);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved for revision!')),
    );
    _loadDataForPage(_currentPage);
  }
  
  void _showPageHighlights() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Saved Notes (Page $_currentPage)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
          // FIX: सेव किए गए नोट्स देखने के लिए नया बटन
          // यह बटन तभी दिखेगा जब इस पेज पर कोई नोट सेव होगा
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
            contextMenuBuilder: (context, selectableRegionState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: [
                  ...selectableRegionState.contextMenuButtonItems,
                  ContextMenuButtonItem(
                    onPressed: () {
                      final selection = selectableRegionState.currentTextSelection!;
                      final selectedText = selection.textInside(selectableRegionState.richTextEditingValue.text);
                      _saveForRevision(selectedText);
                      selectableRegionState.hideToolbar();
                    },
                    label: 'Save for Revision',
                  ),
                ],
                anchors: selectableRegionState.contextMenuAnchors,
              );
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
          
          // FIX: FloatingActionButton को यहाँ से हटा दिया गया है
        ],
      ),
    );
  }
}
