import 'package:flutter/material.dart';
import 'package:homiletics/classes/application.dart';
import 'package:homiletics/pages/homeletic_editor.dart';
import 'package:homiletics/storage/homiletic_storage.dart';

/// [carousel] — home horizontal strip (consistent height, width follows text).
/// [list] — full “show more” screen (wraps text, no wasted vertical space).
enum ApplicationQuestionDisplay { carousel, list }

class ApplicationListItem extends StatelessWidget {
  final Application application;
  final ApplicationQuestionDisplay displayStyle;

  /// Fixed height for carousel row items (matches [ApplicationList] strip).
  final double? carouselStripHeight;

  const ApplicationListItem({
    Key? key,
    required this.application,
    this.displayStyle = ApplicationQuestionDisplay.carousel,
    this.carouselStripHeight,
  }) : super(key: key);

  Future<void> _openHomiletic(BuildContext context) async {
    final homiletic = await getHomileticById(application.homileticsId);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomileticEditor(homiletic: homiletic),
      ),
    );
  }

  Color _cardColor(BuildContext context) {
    final isLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return isLight ? Colors.green.shade300 : Colors.green.shade800;
  }

  @override
  Widget build(BuildContext context) {
    if (displayStyle == ApplicationQuestionDisplay.list) {
      return _ListApplicationTile(
        application: application,
        cardColor: _cardColor(context),
        onOpen: () => _openHomiletic(context),
      );
    }

    return _CarouselApplicationCard(
      application: application,
      cardColor: _cardColor(context),
      onOpen: () => _openHomiletic(context),
      stripHeight: carouselStripHeight ?? 124,
    );
  }
}

class _CarouselApplicationCard extends StatelessWidget {
  final Application application;
  final Color cardColor;
  final VoidCallback onOpen;
  final double stripHeight;

  static const double _minCardWidth = 152;
  static const double _maxCardWidth = 292;

  const _CarouselApplicationCard({
    required this.application,
    required this.cardColor,
    required this.onOpen,
    required this.stripHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passage = application.homileticPassage;
    final onCard = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final passageColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.55);

    return SizedBox(
      height: stripHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 2),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _minCardWidth,
              maxWidth: _maxCardWidth,
            ),
            child: SizedBox(
              height: stripHeight - 2,
              child: Material(
                color: cardColor,
                elevation: 1,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onOpen,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            application.text,
                            maxLines: passage != null && passage.isNotEmpty
                                ? 3
                                : 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
                                  color: onCard,
                                ) ??
                                TextStyle(
                                  fontSize: 14.5,
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
                                  color: onCard,
                                ),
                          ),
                        ),
                        if (passage != null && passage.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            passage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                                  height: 1.2,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: passageColor,
                                ) ??
                                TextStyle(
                                  fontSize: 11.5,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                  color: passageColor,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListApplicationTile extends StatelessWidget {
  final Application application;
  final Color cardColor;
  final VoidCallback onOpen;

  const _ListApplicationTile({
    required this.application,
    required this.cardColor,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passage = application.homileticPassage;
    final onCard = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.92)
        : Colors.black87;
    final passageColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.5);

    return Material(
      color: cardColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 22,
                color: onCard.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      application.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.35,
                            color: onCard,
                          ) ??
                          TextStyle(
                            fontSize: 16,
                            height: 1.35,
                            color: onCard,
                          ),
                    ),
                    if (passage != null && passage.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        passage,
                        style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.3,
                              fontSize: 13,
                              color: passageColor,
                            ) ??
                            TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: passageColor,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: onCard.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
