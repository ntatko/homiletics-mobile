import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hint;
  final Function(String) onQueryChanged;
  final Widget Function(String query) searchResultsBuilder;
  final double? width;
  final bool isPortrait;

  const CustomSearchBar({
    Key? key,
    this.hint = "Search...",
    required this.onQueryChanged,
    required this.searchResultsBuilder,
    this.width,
    this.isPortrait = true,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  String _currentQuery = '';
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    ));

    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isExpanded) {
      _expandSearch();
    } else if (!_focusNode.hasFocus && _isExpanded && _currentQuery.isEmpty) {
      _collapseSearch();
    }
  }

  void _expandSearch() {
    setState(() {
      _isExpanded = true;
    });
    _animationController.forward();
  }

  void _collapseSearch() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  void _onQueryChanged(String query) {
    setState(() {
      _currentQuery = query;
    });
    widget.onQueryChanged(query);
  }

  void _clearSearch() {
    _controller.clear();
    _onQueryChanged('');
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final searchWidth = widget.width ??
        (widget.isPortrait ? screenWidth * 0.8 : screenWidth * 0.6);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            // Search Input Bar
            Container(
              width: searchWidth,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_currentQuery.isNotEmpty)
                    IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Search Results Area
            if (_isExpanded)
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: searchWidth,
                    margin: const EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _currentQuery.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Type to search...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : widget.searchResultsBuilder(_currentQuery),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


