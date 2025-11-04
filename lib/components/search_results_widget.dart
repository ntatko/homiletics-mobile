import 'package:flutter/material.dart';

class SearchResultsWidget extends StatelessWidget {
  final String searchString;

  const SearchResultsWidget({
    Key? key,
    required this.searchString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 8),
          _buildSearchSection(
            title: "Content",
            icon: Icons.description,
            color: Colors.blue,
            child: _buildPlaceholderResults("Content searches"),
          ),
          const SizedBox(height: 16),
          _buildSearchSection(
            title: "Divisions",
            icon: Icons.category,
            color: Colors.green,
            child: _buildPlaceholderResults("Division searches"),
          ),
          const SizedBox(height: 16),
          _buildSearchSection(
            title: "Applications",
            icon: Icons.apps,
            color: Colors.orange,
            child: _buildPlaceholderResults("Application searches"),
          ),
          const SizedBox(height: 16),
          _buildSearchSection(
            title: "Aims",
            icon: Icons.flag,
            color: Colors.purple,
            child: _buildPlaceholderResults("Aim searches"),
          ),
          const SizedBox(height: 16),
          _buildSearchSection(
            title: "Summary Sentences",
            icon: Icons.summarize,
            color: Colors.teal,
            child: _buildPlaceholderResults("Summary sentence searches"),
          ),
          const SizedBox(height: 16),
          _buildSearchSection(
            title: "Passages",
            icon: Icons.book,
            color: Colors.red,
            child: _buildPlaceholderResults("Passage searches"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPlaceholderResults(String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        placeholder,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}


