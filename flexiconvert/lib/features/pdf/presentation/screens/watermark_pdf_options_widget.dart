import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/engines/pdf_engine.dart';

class WatermarkPdfOptionsWidget extends StatefulWidget {
  final WatermarkOptions initialOptions;
  final ValueChanged<WatermarkOptions> onOptionsChanged;

  const WatermarkPdfOptionsWidget({
    super.key,
    required this.initialOptions,
    required this.onOptionsChanged,
  });

  @override
  State<WatermarkPdfOptionsWidget> createState() => _WatermarkPdfOptionsWidgetState();
}

class _WatermarkPdfOptionsWidgetState extends State<WatermarkPdfOptionsWidget> {
  late WatermarkOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions;
  }

  void _update(WatermarkOptions newOptions) {
    setState(() => _options = newOptions);
    widget.onOptionsChanged(_options);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid Position
        Text('Position', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildGridPositioner(),
        const SizedBox(height: 16),

        // Text / Image Segment
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Text')),
            ButtonSegment(value: false, label: Text('Image')),
          ],
          selected: {_options.isText},
          onSelectionChanged: (val) {
            _update(WatermarkOptions(
              isText: val.first,
              text: _options.text,
              imageBytes: _options.imageBytes,
              position: _options.position,
              transparency: _options.transparency,
              isOver: _options.isOver,
              rotation: _options.rotation,
            ));
          },
        ),
        const SizedBox(height: 16),

        // Content
        if (_options.isText)
          TextField(
            decoration: const InputDecoration(
              labelText: 'Watermark Text',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              _update(WatermarkOptions(
                isText: _options.isText,
                text: val,
                imageBytes: _options.imageBytes,
                position: _options.position,
                transparency: _options.transparency,
                isOver: _options.isOver,
                rotation: _options.rotation,
              ));
            },
            controller: TextEditingController(text: _options.text)..selection = TextSelection.collapsed(offset: _options.text.length),
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.image),
            label: Text(_options.imageBytes == null ? 'Select Image' : 'Change Image'),
            onPressed: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final bytes = await image.readAsBytes();
                _update(WatermarkOptions(
                  isText: _options.isText,
                  text: _options.text,
                  imageBytes: bytes,
                  position: _options.position,
                  transparency: _options.transparency,
                  isOver: _options.isOver,
                  rotation: _options.rotation,
                ));
              }
            },
          ),

        const SizedBox(height: 16),
        
        // Transparency
        Text('Transparency: ${(_options.transparency * 100).toInt()}%', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: _options.transparency,
          min: 0.1,
          max: 1.0,
          onChanged: (val) {
            _update(WatermarkOptions(
              isText: _options.isText,
              text: _options.text,
              imageBytes: _options.imageBytes,
              position: _options.position,
              transparency: val,
              isOver: _options.isOver,
              rotation: _options.rotation,
            ));
          },
        ),

        // Rotation
        Text('Rotation: ${_options.rotation}°', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: _options.rotation.toDouble(),
          min: 0,
          max: 360,
          divisions: 8,
          onChanged: (val) {
            _update(WatermarkOptions(
              isText: _options.isText,
              text: _options.text,
              imageBytes: _options.imageBytes,
              position: _options.position,
              transparency: _options.transparency,
              isOver: _options.isOver,
              rotation: val.toInt(),
            ));
          },
        ),

        // Layer Over/Under
        SwitchListTile(
          title: const Text('Place over content'),
          value: _options.isOver,
          onChanged: (val) {
            _update(WatermarkOptions(
              isText: _options.isText,
              text: _options.text,
              imageBytes: _options.imageBytes,
              position: _options.position,
              transparency: _options.transparency,
              isOver: val,
              rotation: _options.rotation,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildGridPositioner() {
    return AspectRatio(
      aspectRatio: 1.5,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5, mainAxisSpacing: 4, crossAxisSpacing: 4),
        itemCount: 9,
        itemBuilder: (context, index) {
          final pos = index + 1;
          final isSelected = _options.position == pos;
          return InkWell(
            onTap: () {
              _update(WatermarkOptions(
                isText: _options.isText,
                text: _options.text,
                imageBytes: _options.imageBytes,
                position: pos,
                transparency: _options.transparency,
                isOver: _options.isOver,
                rotation: _options.rotation,
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
              ),
              child: Center(
                child: Icon(Icons.circle, size: 12, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
