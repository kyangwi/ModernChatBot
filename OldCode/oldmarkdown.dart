
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class MarkdownFormattedText extends StatelessWidget {
  final String text;
  MarkdownFormattedText({super.key, required this.text});

  // Updated regex to capture inline code, bold, italic, subscript, and superscript.
  final RegExp _inlineRegex = RegExp(
    r'(`([^`]+)`)|(\*\*([^*]+)\*\*)|((?<!\*)\*([^*]+)\*(?!\*))|(<sub>(.*?)<\/sub>)|(<sup>(.*?)<\/sup>)',
  );

  /// Converts inline markdown syntax into InlineSpans.
  List<InlineSpan> _parseInlineSpans(String line) {
    // Pre-process the line to avoid extra markdown artifacts.
    if (line.startsWith('* ') && line.substring(2).startsWith('**')) {
      line = line.substring(2);
    }

    final spans = <InlineSpan>[];
    int start = 0;
    for (final match in _inlineRegex.allMatches(line)) {
      // Add plain text before the match.
      if (match.start > start) {
        spans.add(TextSpan(text: line.substring(start, match.start)));
      }
      // Inline code: `code`
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: Color.fromARGB(255, 227, 175, 62),
            ),
          ),
        );
      }
      // Bold: **bold**
      else if (match.group(3) != null) {
        spans.add(
          TextSpan(
            text: match.group(4),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }
      // Italic: *italic*
      else if (match.group(5) != null) {
        spans.add(
          TextSpan(
            text: match.group(6),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      // Subscript: <sub>...</sub>
      else if (match.group(7) != null) {
        spans.add(
          WidgetSpan(
            child: Builder(builder: (context) {
              // Inherit the current style (which may be bold) from the surrounding context.
              final inheritedStyle = DefaultTextStyle.of(context).style;
              return Transform.translate(
                offset: const Offset(0, 4), // Shift downward for subscript.
                child: Text(
                  match.group(8)!,
                  style: inheritedStyle.copyWith(
                    fontSize: (inheritedStyle.fontSize ?? 16) * 0.75,
                  ),
                ),
              );
            }),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        );
      }
      // Superscript: <sup>...</sup>
      else if (match.group(9) != null) {
        spans.add(
          WidgetSpan(
            child: Builder(builder: (context) {
              final inheritedStyle = DefaultTextStyle.of(context).style;
              return Transform.translate(
                offset: const Offset(0, -4), // Shift upward for superscript.
                child: Text(
                  match.group(10)!,
                  style: inheritedStyle.copyWith(
                    fontSize: (inheritedStyle.fontSize ?? 16) * 0.75,
                  ),
                ),
              );
            }),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        );
      }
      start = match.end;
    }
    // Append any remaining text.
    if (start < line.length) {
      spans.add(TextSpan(text: line.substring(start)));
    }
    return spans;
  }

  /// Builds RichText widgets for a block of text.
  List<Widget> _buildRichTextWidgets(String textBlock) {
    final widgets = <Widget>[];
    final lines = textBlock.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Headings: lines starting with "## ".
      if (trimmedLine.startsWith('## ')) {
        final headingText = trimmedLine.substring(3);
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black,
                ),
                children: _parseInlineSpans(headingText),
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet points: lines starting with "* ".
      if (trimmedLine.startsWith('* ')) {
        final bulletText = trimmedLine.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16.0)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      children: _parseInlineSpans(bulletText),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Regular text.
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color.fromARGB(255, 40, 34, 34),
                fontSize: 16.0,
              ),
              children: _parseInlineSpans(trimmedLine),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  /// Renders code blocks using HighlightView.
  Widget _buildHighlightedCodeBlock(String code, String language) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 8, 32, 55),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: HighlightView(
        code,
        language: language.isNotEmpty ? language : 'dart',
        theme: monokaiSublimeTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 15.0),
      ),
    );
  }

  /// Builds a table widget from Markdown table syntax.
  Widget _buildTable(List<String> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();

    // Process the header row.
    String headerRow = rows.first;
    if (headerRow.startsWith('##')) {
      headerRow = headerRow.replaceFirst('##', '').trim();
    }
    final headers = _splitRow(headerRow);
    if (headers.isEmpty) return const SizedBox.shrink();

    // Determine the start of data rows.
    int dataStartIndex = 1;
    if (rows.length > 1 && _isSeparatorRow(rows[1])) {
      dataStartIndex = 2;
    }
    final dataRows = rows.skip(dataStartIndex).map(_splitRow).toList();
    final tableRows = <TableRow>[];

    // Build the header row.
    tableRows.add(
      TableRow(
        children: headers.map((headerText) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                children: _parseInlineSpans(headerText),
              ),
            ),
          );
        }).toList(),
      ),
    );

    // Build data rows.
    for (final rowCells in dataRows) {
      if (rowCells.isEmpty) continue;
      if (rowCells.length < headers.length) {
        rowCells.addAll(List.filled(headers.length - rowCells.length, ''));
      } else if (rowCells.length > headers.length) {
        rowCells.removeRange(headers.length, rowCells.length);
      }
      tableRows.add(
        TableRow(
          children: rowCells.map((cellText) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  children: _parseInlineSpans(cellText),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: Colors.black54),
      columnWidths: {
        for (int i = 0; i < headers.length; i++) i: const FlexColumnWidth(),
      },
      children: tableRows,
    );
  }

  /// Splits a Markdown table row into cells.
  List<String> _splitRow(String line) {
    return line.split('|').map((e) => e.trim()).where((cell) => cell.isNotEmpty).toList();
  }

  /// Checks if a line is a Markdown separator row.
  bool _isSeparatorRow(String line) {
    final cells = line.split('|').map((e) => e.trim()).where((cell) => cell.isNotEmpty).toList();
    if (cells.isEmpty) return false;
    return cells.every((cell) => RegExp(r'^-+$').hasMatch(cell));
  }

  /// Parses the complete markdown text into widgets.
  List<Widget> _parseMarkdownContent(String text) {
    final widgets = <Widget>[];
    final buffer = <String>[];
    bool inCodeBlock = false;
    String codeLanguage = '';
    bool inTable = false;

    void flushBufferAsRichText() {
      if (buffer.isNotEmpty) {
        widgets.addAll(_buildRichTextWidgets(buffer.join('\n')));
        buffer.clear();
      }
    }

    void flushBufferAsTable() {
      if (buffer.isNotEmpty) {
        widgets.add(_buildTable(buffer));
        buffer.clear();
      }
    }

    final lines = text.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();

      // Toggle code blocks.
      if (trimmedLine.startsWith('```')) {
        if (inCodeBlock) {
          widgets.add(_buildHighlightedCodeBlock(buffer.join('\n'), codeLanguage));
          buffer.clear();
          inCodeBlock = false;
          codeLanguage = '';
        } else {
          flushBufferAsRichText();
          final possibleLang = trimmedLine.substring(3).trim();
          codeLanguage = possibleLang.isNotEmpty ? possibleLang : 'dart';
          inCodeBlock = true;
        }
      }
      // Code block content.
      else if (inCodeBlock) {
        buffer.add(line);
      }
      // Table rows.
      else if (trimmedLine.startsWith('|') && trimmedLine.contains('|')) {
        if (!inTable) {
          flushBufferAsRichText();
          inTable = true;
        }
        buffer.add(trimmedLine);
      }
      // Normal text.
      else {
        if (inTable) {
          flushBufferAsTable();
          inTable = false;
        }
        buffer.add(line);
      }
    }

    // Flush any remaining buffered content.
    if (inCodeBlock) {
      widgets.add(_buildHighlightedCodeBlock(buffer.join('\n'), codeLanguage));
    } else if (inTable) {
      flushBufferAsTable();
    } else if (buffer.isNotEmpty) {
      flushBufferAsRichText();
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseMarkdownContent(text),
    );
  }
}
