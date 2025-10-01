import 'package:flutter/material.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class VerseContainer extends StatefulWidget {
  String passage;
  Translation? translation;

  VerseContainer({Key? key, required this.passage, this.translation})
      : super(key: key);

  @override
  VerseContainerState createState() => VerseContainerState();
}

/// Maps translation codes to Bible Gateway version codes
String _getBibleGatewayVersion(Translation translation) {
  switch (translation.code) {
    // Popular modern translations
    case 'niv':
      return 'NIV';
    case 'esv':
      return 'ESV';
    case 'nasb':
      return 'NASB';
    case 'nlt':
      return 'NLT';
    case 'nkjv':
      return 'NKJV';
    case 'csb':
      return 'CSB';
    case 'nrsv':
      return 'NRSV';
    case 'kjv':
      return 'KJV';
    case 'msg':
      return 'MSG';
    case 'amp':
      return 'AMP';
    case 'cev':
      return 'CEV';
    case 'ncv':
      return 'NCV';
    // Other translations
    case 'web':
      return 'WEB';
    case 'bbe':
      return 'BBE';
    case 'oeb-cw':
    case 'oeb-us':
      return 'OEB';
    case 'net':
      return 'NET';
    case 'asv':
      return 'ASV';
    default:
      return 'NIV'; // Default fallback
  }
}

/// Creates a Bible Gateway URL for the given passage and translation
String _createBibleGatewayUrl(String passage, Translation translation) {
  final encodedPassage = Uri.encodeComponent(passage);
  final version = _getBibleGatewayVersion(translation);
  return 'https://www.biblegateway.com/passage/?search=$encodedPassage&version=$version&interface=print';
}

class VerseContainerState extends State<VerseContainer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(covariant VerseContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passage != widget.passage ||
        oldWidget.translation != widget.translation) {
      _loadPassage();
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Apply dark mode styling if needed
            _applyDarkModeStyling();
          },
        ),
      );
    _loadPassage();
  }

  void _applyDarkModeStyling() {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (isDarkMode) {
      _controller.runJavaScript('''
        // Create a style element for dark mode
        var style = document.createElement('style');
        style.innerHTML = `
          body {
            background-color: #1a1a1a !important;
            color: #e0e0e0 !important;
          }
          /* Target all text elements */
          p, div, span, td, th, li {
            color: #e0e0e0 !important;
            background-color: transparent !important;
          }
          /* Target all heading elements more aggressively */
          h1, h2, h3, h4, h5, h6, 
          h1 *, h2 *, h3 *, h4 *, h5 *, h6 *,
          .passage-title, .passage-title *,
          .reference, .passage-reference,
          .reference *, .passage-reference * {
            color: #ffffff !important;
            background-color: transparent !important;
          }
          /* Target Bible Gateway specific elements */
          .passage-text, .passage, .text, .verse, .chapter,
          .passage-text *, .passage *, .text *, .verse *, .chapter * {
            color: #e0e0e0 !important;
            background-color: transparent !important;
          }
          /* Style verse numbers */
          .verse-num, .verse-number, .verse-num *, .verse-number * {
            color: #b0b0b0 !important;
          }
          /* Remove any white backgrounds from all elements */
          *, *::before, *::after {
            background-color: transparent !important;
          }
          /* Override any existing color styles */
          [style*="color"] {
            color: #e0e0e0 !important;
          }
          /* Style links */
          a, a * {
            color: #4a9eff !important;
          }
          a:visited, a:visited * {
            color: #8a4aff !important;
          }
        `;
        document.head.appendChild(style);
      ''');
    }
  }

  void _loadPassage() {
    final translation = widget.translation ?? Preferences.translation;
    final url = _createBibleGatewayUrl(widget.passage, translation);
    _controller.loadRequest(Uri.parse(url));
    // Apply dark mode styling after a short delay to ensure page is loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      _applyDarkModeStyling();
    });
  }

  /// Public method to reload the passage with current preferences
  void reloadPassage() {
    _loadPassage();
  }

  /// Public method to apply dark mode styling
  void applyDarkMode() {
    _applyDarkModeStyling();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
