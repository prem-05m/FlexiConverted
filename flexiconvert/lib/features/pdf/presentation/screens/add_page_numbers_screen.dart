import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/engines/pdf_engine.dart';
import '../../../../core/theme/app_spacing.dart';

class AddPageNumbersOptionsWidget extends StatefulWidget {
  final PageNumberOptions initialOptions;
  final ValueChanged<PageNumberOptions> onChanged;
  final List<String> selectedFiles;
  final List<Uint8List> pageImages;
  final void Function(String) onRemoveFile;
  final int totalPages;

  const AddPageNumbersOptionsWidget({
    super.key,
    required this.initialOptions,
    required this.onChanged,
    required this.selectedFiles,
    required this.pageImages,
    required this.onRemoveFile,
    required this.totalPages,
  });

  @override
  State<AddPageNumbersOptionsWidget> createState() => _AddPageNumbersOptionsWidgetState();
}

class _AddPageNumbersOptionsWidgetState extends State<AddPageNumbersOptionsWidget> {
  late String _pnPageMode;
  late String _pnFacingOrientation;
  late bool _pnFirstPageCover;
  late int _pnPosition;
  late String _pnMargin;
  late int _pnFirstNumber;
  late int _pnFromPage;
  late int _pnToPage;
  late String _pnTextFormat;
  late String _pnFontFamily;
  late double _pnFontSize;
  late bool _pnBold;
  late bool _pnItalic;
  late bool _pnUnderline;
  late Color _pnColor;

  late TextEditingController _pnFirstNumberCtrl;
  late TextEditingController _pnFromPageCtrl;
  late TextEditingController _pnToPageCtrl;
  late TextEditingController _pnCustomTextCtrl;

  final _fontFamilies = ['Arial', 'Helvetica', 'Times New Roman', 'Courier', 'Roboto'];
  final _colorPalette = const [
    Colors.black, Colors.white, Colors.red, Colors.green, Colors.blue,
    Colors.orange, Colors.purple, Colors.teal, Colors.brown, Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    final opt = widget.initialOptions;
    _pnPageMode = opt.pageMode;
    _pnFacingOrientation = opt.facingOrientation;
    _pnFirstPageCover = opt.firstPageIsCover;
    _pnPosition = opt.position;
    _pnMargin = opt.margin;
    _pnFirstNumber = opt.firstNumber;
    _pnFromPage = opt.fromPage;
    _pnToPage = opt.toPage == -1 || opt.toPage == 0 || opt.toPage > widget.totalPages 
      ? (widget.totalPages > 0 ? widget.totalPages : 1) 
      : opt.toPage;
    _pnTextFormat = opt.textFormat;
    _pnFontFamily = opt.fontFamily;
    _pnFontSize = opt.fontSize;
    _pnBold = opt.bold;
    _pnItalic = opt.italic;
    _pnUnderline = opt.underline;
    
    // Parse color string '#RRGGBB' -> Color(0xFFRRGGBB)
    try {
      final hex = opt.colorHex.replaceAll('#', '');
      _pnColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      _pnColor = Colors.black;
    }

    _pnFirstNumberCtrl = TextEditingController(text: '$_pnFirstNumber');
    _pnFromPageCtrl = TextEditingController(text: '$_pnFromPage');
    _pnToPageCtrl = TextEditingController(text: '$_pnToPage');
    _pnCustomTextCtrl = TextEditingController(text: opt.customFormat);
  }

  @override
  void dispose() {
    _pnFirstNumberCtrl.dispose();
    _pnFromPageCtrl.dispose();
    _pnToPageCtrl.dispose();
    _pnCustomTextCtrl.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(PageNumberOptions(
      pageMode: _pnPageMode,
      facingOrientation: _pnFacingOrientation,
      firstPageIsCover: _pnFirstPageCover,
      position: _pnPosition,
      margin: _pnMargin,
      firstNumber: _pnFirstNumber,
      fromPage: _pnFromPage,
      toPage: _pnToPage,
      textFormat: _pnTextFormat,
      customFormat: _pnCustomTextCtrl.text,
      fontFamily: _pnFontFamily,
      fontSize: _pnFontSize,
      bold: _pnBold,
      italic: _pnItalic,
      underline: _pnUnderline,
      colorHex: '#${(_pnColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selectedFiles.isNotEmpty) ...[
          Text('PDF Pages (${widget.pageImages.length})',
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: widget.pageImages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.pageImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final preview = widget.pageImages[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      InteractiveViewer(
                                        child: Image.memory(preview),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.memory(preview, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${index + 1}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],



        const SizedBox(height: 20),
        _sectionTitle(context, 'Position'),
        const SizedBox(height: 8),
        _buildPositionGrid(context),

        const SizedBox(height: 20),
        _sectionTitle(context, 'Margin'),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'small', label: Text('Small (5%)')),
            ButtonSegment(value: 'normal', label: Text('Normal (10%)')),
            ButtonSegment(value: 'big', label: Text('Big (15%)')),
          ],
          selected: {_pnMargin},
          onSelectionChanged: (s) {
            setState(() => _pnMargin = s.first);
            _notifyChanged();
          },
        ),

        const SizedBox(height: 20),
        _sectionTitle(context, 'Pages'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'First number',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _pnFirstNumberCtrl,
                onChanged: (v) {
                  _pnFirstNumber = int.tryParse(v) ?? 1;
                  setState(() {});
                  _notifyChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'From page',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _pnFromPageCtrl,
                onChanged: (v) {
                  _pnFromPage = int.tryParse(v) ?? 1;
                  setState(() {});
                  _notifyChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'To page (0=all)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _pnToPageCtrl,
                onChanged: (v) {
                  _pnToPage = int.tryParse(v) ?? 0;
                  setState(() {});
                  _notifyChanged();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        _sectionTitle(context, 'Text format'),
        const SizedBox(height: 8),
        ...[
          ('option1', '1, 2, 3 …'),
          ('option2', 'Page 1, Page 2, Page 3 …'),
          ('option3', 'Page 1 of n, Page 2 of n …'),
          ('option4', 'Custom'),
        ].map((opt) => _buildRadioTile(opt.$1, opt.$2)),
        if (_pnTextFormat == 'option4') ...[
          const SizedBox(height: 8),
          TextField(
            controller: _pnCustomTextCtrl,
            onChanged: (_) {
              setState(() {});
              _notifyChanged();
            },
            decoration: const InputDecoration(
              labelText: 'Custom format',
              hintText: 'e.g. {n} / {p}  →  use {n} for page, {p} for total',
              border: OutlineInputBorder(),
            ),
          ),
        ],

        const SizedBox(height: 20),
        _sectionTitle(context, 'Text style'),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Font family',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          initialValue: _fontFamilies.contains(_pnFontFamily) ? _pnFontFamily : _fontFamilies.first,
          items: _fontFamilies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (v) {
            setState(() => _pnFontFamily = v ?? 'Arial');
            _notifyChanged();
          },
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            const Text('Font size:', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Text('${_pnFontSize.round()}pt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Expanded(
              child: Slider(
                value: _pnFontSize,
                min: 5,
                max: 50,
                divisions: 22,
                label: '${_pnFontSize.round()}',
                onChanged: (v) {
                  setState(() => _pnFontSize = (v / 2).round() * 2.0);
                  _notifyChanged();
                },
              ),
            ),
          ],
        ),

        Row(
          children: [
            _styleToggle(
              label: 'B',
              active: _pnBold,
              bold: true,
              onTap: () {
                setState(() => _pnBold = !_pnBold);
                _notifyChanged();
              },
            ),
            const SizedBox(width: 8),
            _styleToggle(
              label: 'I',
              active: _pnItalic,
              italic: true,
              onTap: () {
                setState(() => _pnItalic = !_pnItalic);
                _notifyChanged();
              },
            ),
            const SizedBox(width: 8),
            _styleToggle(
              label: 'U',
              active: _pnUnderline,
              underline: true,
              onTap: () {
                setState(() => _pnUnderline = !_pnUnderline);
                _notifyChanged();
              },
            ),
          ],
        ),

        const SizedBox(height: 12),
        Text('Color', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorPalette.map((color) {
            final isSelected = _pnColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () {
                setState(() => _pnColor = color);
                _notifyChanged();
              },
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1)]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text.rich(
            TextSpan(
              text: 'Preview: ',
              children: [
                TextSpan(
                  text: _pnTextFormat == 'option1'
                      ? '$_pnFirstNumber'
                      : _pnTextFormat == 'option2'
                          ? 'Page $_pnFirstNumber'
                          : _pnTextFormat == 'option3'
                              ? 'Page $_pnFirstNumber of n'
                              : _pnCustomTextCtrl.text
                                  .replaceAll('{n}', '$_pnFirstNumber')
                                  .replaceAll('{p}', 'n'),
                  style: TextStyle(
                    fontWeight: _pnBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: _pnItalic ? FontStyle.italic : FontStyle.normal,
                    decoration: _pnUnderline ? TextDecoration.underline : TextDecoration.none,
                    color: _pnColor,
                    fontSize: _pnFontSize.clamp(10, 24),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildRadioTile(String value, String label) {
    final isSelected = _pnTextFormat == value;
    return InkWell(
      onTap: () {
        setState(() => _pnTextFormat = value);
        _notifyChanged();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _pnTextFormat,
              onChanged: (v) {
                setState(() => _pnTextFormat = v!);
                _notifyChanged();
              },
            ),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildPositionGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Stack(
              children: [
                ...[1, 2, 3, 4, 5, 6].map((pos) {
                  final isSelected = _pnPosition == pos;
                  double? left, right, top, bottom;
                  final isLeft = pos == 1 || pos == 4;
                  final isCenter = pos == 2 || pos == 5;
                  final isRight = pos == 3 || pos == 6;
                  final isTop = pos <= 3;

                  if (isLeft) left = 8;
                  if (isCenter) { left = 0; right = 0; }
                  if (isRight) right = 8;
                  if (isTop) {
                    top = 8;
                  } else {
                    bottom = 8;
                  }

                  return Positioned(
                    left: left,
                    right: right,
                    top: top,
                    bottom: bottom,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _pnPosition = pos);
                        _notifyChanged();
                      },
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4), blurRadius: 4)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.circle, color: Colors.white, size: 10)
                            : null,
                      ),
                    ),
                  );
                }),
                const Center(child: Text('Page', style: TextStyle(color: Colors.grey, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _positionLabel(_pnPosition),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _positionLabel(int pos) {
    switch (pos) {
      case 1: return 'Top Left';
      case 2: return 'Top Center';
      case 3: return 'Top Right';
      case 4: return 'Bottom Left';
      case 5: return 'Bottom Center';
      case 6: return 'Bottom Right';
      default: return '';
    }
  }

  Widget _styleToggle({
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool bold = false,
    bool italic = false,
    bool underline = false,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              decoration: underline ? TextDecoration.underline : TextDecoration.none,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
