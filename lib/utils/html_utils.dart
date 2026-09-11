/// Helpers for cleaning HTML text that comes from the API,
/// so it is safe to show in the app UI.
class HtmlUtils {
  HtmlUtils._(); // static-only class

  /// Removes HTML tags and converts common HTML entities
  /// into normal readable text.
  static String stripTags(String html) {
    if (html.isEmpty) return '';

    var text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n') // keep line breaks
        .replaceAll('</p>', '\n')
        .replaceAll('</li>', '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ''); // remove all other tags

    // Named entities (like &amp;).
    const entities = {
      '&quot;': '"',
      '&apos;': "'",
      '&nbsp;': ' ',
      '&ndash;': '\u2013',
      '&mdash;': '\u2014',
      '&lsquo;': '\u2018',
      '&rsquo;': '\u2019',
      '&ldquo;': '\u201C',
      '&rdquo;': '\u201D',
      '&bull;': '\u2022',
      '&hellip;': '\u2026',
      '&amp;': '&',
    };
    entities.forEach((key, value) {
      text = text.replaceAll(key, value);
    });

    // Numeric entities, e.g. &#39; (decimal) and &#x2013; (hex).
    text = text.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });
    text = text.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    // Collapse 3+ blank lines into one blank line.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }
}
