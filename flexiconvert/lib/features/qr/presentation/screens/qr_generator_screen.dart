import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../providers/qr_config_provider.dart';
import '../../domain/models/qr_config_model.dart';
import '../widgets/qr_preview_card.dart';
import '../widgets/qr_frame_widget.dart';

class QrGeneratorScreen extends ConsumerStatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  ConsumerState<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends ConsumerState<QrGeneratorScreen> {
  final TextEditingController _dataController = TextEditingController(text: 'https://');
  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  
  final TextEditingController _vcardFirstController = TextEditingController();
  final TextEditingController _vcardLastController = TextEditingController();
  final TextEditingController _vcardPhoneController = TextEditingController();
  final TextEditingController _vcardEmailController = TextEditingController();
  final TextEditingController _vcardCompanyController = TextEditingController();
  final TextEditingController _vcardJobController = TextEditingController();
  
  final TextEditingController _mapLatController = TextEditingController();
  final TextEditingController _mapLngController = TextEditingController();
  
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailBodyController = TextEditingController();
  
  final TextEditingController _whatsappPhoneController = TextEditingController();
  final TextEditingController _whatsappMessageController = TextEditingController();

  final GlobalKey _qrKey = GlobalKey();
  
  // File Upload State
  bool _isUploading = false;

  @override
  void dispose() {
    _dataController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _vcardFirstController.dispose();
    _vcardLastController.dispose();
    _vcardPhoneController.dispose();
    _vcardEmailController.dispose();
    _vcardCompanyController.dispose();
    _vcardJobController.dispose();
    _mapLatController.dispose();
    _mapLngController.dispose();
    _emailAddressController.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
    _whatsappPhoneController.dispose();
    _whatsappMessageController.dispose();
    super.dispose();
  }

  void _onPayloadTypeChanged(QrPayloadType type) {
    ref.read(qrConfigProvider.notifier).updatePayloadType(type);
      switch (type) {
      case QrPayloadType.weblink:
      case QrPayloadType.youtube:
      case QrPayloadType.facebook:
      case QrPayloadType.twitter:
      case QrPayloadType.instagram:
      case QrPayloadType.googleForms:
      case QrPayloadType.appMarkets:
      case QrPayloadType.image:
      case QrPayloadType.audio:
      case QrPayloadType.pdf:
      case QrPayloadType.excel:
        _dataController.text = 'https://';
        break;
      default:
        _dataController.text = '';
        break;
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(qrConfigProvider.notifier).updateLogo(image.path);
    }
  }

  void _showColorPicker(BuildContext context, Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => tempColor = color,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<ui.Image?> _captureQrImage() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      return await boundary.toImage(pixelRatio: 5.0); // High quality export
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAsPng() async {
    final image = await _captureQrImage();
    if (image == null) return;
    
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    
    final buffer = byteData.buffer;
    final bytes = buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        await Gal.putImage(file.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Gallery in High Quality!')));
        }
      } else {
        // Desktop platforms: prompt user to choose where to save
        var outputFile = await fp.FilePicker.saveFile(
          dialogTitle: 'Save QR Code',
          fileName: 'qr_${DateTime.now().millisecondsSinceEpoch}.png',
          type: fp.FileType.image,
          bytes: bytes,
        );

        if (outputFile != null) {
          final filePath = outputFile is String ? outputFile : (outputFile as dynamic).path;
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to $filePath')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Future<void> _copyAsPng() async {
    final image = await _captureQrImage();
    if (image == null) return;
    
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    
    final buffer = byteData.buffer;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_copy.png');
    await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    
    await Share.shareXFiles([XFile(file.path)], text: 'Copied QR Code');
  }

  Future<void> _pickAndUploadFile(QrConfig notifier, QrPayloadType payloadType, {fp.FileType type = fp.FileType.any}) async {
    try {
      var result;
      if (type == fp.FileType.custom) {
        result = await fp.FilePicker.pickFiles(
          type: type,
          allowedExtensions: payloadType == QrPayloadType.pdf ? ['pdf'] : ['xls', 'xlsx'],
        );
      } else {
        result = await fp.FilePicker.pickFiles(type: type);
      }
      
      if (result != null && result.isNotEmpty && result.first.path != null) {
        setState(() => _isUploading = true);
        try {
          final dio = Dio();
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(result.first.path!),
          });
          final response = await dio.post('https://flexi-converted.vercel.app/api/v1/uploads', data: formData);
          if (response.data['success']) {
            notifier.updateData(response.data['url']);
          }
        } catch (e) {
          debugPrint('Upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed')));
          }
        } finally {
          if (mounted) setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  Widget _buildTypeSelector(QrConfigModel config) {
    const types = [
      {'type': QrPayloadType.weblink, 'icon': Icons.link, 'label': 'Web Link'},
      {'type': QrPayloadType.wifi, 'icon': Icons.wifi, 'label': 'Wi-Fi'},
      {'type': QrPayloadType.text, 'icon': Icons.text_fields, 'label': 'Text'},
      {'type': QrPayloadType.barcode, 'icon': Icons.barcode_reader, 'label': 'Barcode'},
      {'type': QrPayloadType.whatsapp, 'icon': Icons.message, 'label': 'WhatsApp'},
      {'type': QrPayloadType.email, 'icon': Icons.email, 'label': 'Email'},
      {'type': QrPayloadType.vcard, 'icon': Icons.contact_mail, 'label': 'vCard'},
      {'type': QrPayloadType.maps, 'icon': Icons.map, 'label': 'Maps'},
      {'type': QrPayloadType.youtube, 'icon': Icons.video_library, 'label': 'YouTube'},
      {'type': QrPayloadType.facebook, 'icon': Icons.facebook, 'label': 'Facebook'},
      {'type': QrPayloadType.twitter, 'icon': Icons.chat, 'label': 'Twitter'},
      {'type': QrPayloadType.instagram, 'icon': Icons.photo_camera, 'label': 'Instagram'},
      {'type': QrPayloadType.googleForms, 'icon': Icons.list_alt, 'label': 'Google Form'},
      {'type': QrPayloadType.appMarkets, 'icon': Icons.shop, 'label': 'App Market'},
      {'type': QrPayloadType.image, 'icon': Icons.image, 'label': 'Image'},
      {'type': QrPayloadType.audio, 'icon': Icons.audiotrack, 'label': 'Audio'},
      {'type': QrPayloadType.pdf, 'icon': Icons.picture_as_pdf, 'label': 'PDF'},
      {'type': QrPayloadType.excel, 'icon': Icons.table_chart, 'label': 'Excel'},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (context, index) {
          final t = types[index];
          final isSelected = config.payloadType == t['type'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              showCheckmark: false,
              label: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t['icon'] as IconData, size: 24, color: isSelected ? Colors.white : Theme.of(context).iconTheme.color),
                  const SizedBox(height: 4),
                  Text(t['label'] as String, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _onPayloadTypeChanged(t['type'] as QrPayloadType);
              },
              selectedColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(qrConfigProvider);
    final notifier = ref.read(qrConfigProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code')),
      body: WebConstrainedBox(
        maxWidth: 1000,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Section: Preview
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: _qrKey,
                      child: const QrPreviewCard(),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveAsPng,
                          icon: const Icon(Icons.save),
                          label: const Text('Save HQ PNG'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _copyAsPng,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy PNG'),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Bottom Section: Configuration
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTypeSelector(config),
                    const SizedBox(height: 24),

                    // Dynamic Data Inputs
                    if ([QrPayloadType.weblink, QrPayloadType.text, QrPayloadType.barcode, QrPayloadType.youtube, QrPayloadType.facebook, QrPayloadType.twitter, QrPayloadType.instagram, QrPayloadType.googleForms, QrPayloadType.appMarkets].contains(config.payloadType))
                      TextField(
                        controller: _dataController,
                        decoration: const InputDecoration(labelText: 'Data / URL', border: OutlineInputBorder()),
                        onChanged: notifier.updateData,
                      ),
                    
                    if (config.payloadType == QrPayloadType.wifi) ...[
                      TextField(controller: _wifiSsidController, decoration: const InputDecoration(labelText: 'Network Name (SSID)', border: OutlineInputBorder()), onChanged: (val) => notifier.updateWifi(ssid: val)),
                      const SizedBox(height: 16),
                      TextField(controller: _wifiPasswordController, decoration: const InputDecoration(labelText: 'Password (Optional)', border: OutlineInputBorder()), onChanged: (val) => notifier.updateWifi(password: val)),
                    ],

                    if (config.payloadType == QrPayloadType.vcard) ...[
                      Row(children: [
                        Expanded(child: TextField(controller: _vcardFirstController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), onChanged: (val) => notifier.updateVcard(first: val))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: _vcardLastController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()), onChanged: (val) => notifier.updateVcard(last: val))),
                      ]),
                      const SizedBox(height: 16),
                      TextField(controller: _vcardPhoneController, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()), onChanged: (val) => notifier.updateVcard(phone: val)),
                      const SizedBox(height: 16),
                      TextField(controller: _vcardEmailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), onChanged: (val) => notifier.updateVcard(email: val)),
                    ],

                    if (config.payloadType == QrPayloadType.maps) ...[
                      Row(children: [
                        Expanded(child: TextField(controller: _mapLatController, decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()), onChanged: (val) => notifier.updateMap(lat: val))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: _mapLngController, decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()), onChanged: (val) => notifier.updateMap(lng: val))),
                      ]),
                    ],

                    if (config.payloadType == QrPayloadType.email) ...[
                      TextField(controller: _emailAddressController, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()), onChanged: (val) => notifier.updateEmail(address: val)),
                      const SizedBox(height: 16),
                      TextField(controller: _emailSubjectController, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()), onChanged: (val) => notifier.updateEmail(subject: val)),
                      const SizedBox(height: 16),
                      TextField(controller: _emailBodyController, decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()), maxLines: 3, onChanged: (val) => notifier.updateEmail(body: val)),
                    ],

                    if (config.payloadType == QrPayloadType.whatsapp) ...[
                      TextField(controller: _whatsappPhoneController, decoration: const InputDecoration(labelText: 'Phone Number (with country code)', border: OutlineInputBorder()), onChanged: (val) => notifier.updateWhatsapp(phone: val)),
                      const SizedBox(height: 16),
                      TextField(controller: _whatsappMessageController, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()), onChanged: (val) => notifier.updateWhatsapp(message: val)),
                    ],

                    if (config.payloadType == QrPayloadType.image || config.payloadType == QrPayloadType.audio || config.payloadType == QrPayloadType.pdf || config.payloadType == QrPayloadType.excel) ...[
                      ElevatedButton.icon(
                        icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file),
                        label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
                        onPressed: _isUploading ? null : () {
                          fp.FileType fType = fp.FileType.any;
                          if (config.payloadType == QrPayloadType.image) fType = fp.FileType.image;
                          if (config.payloadType == QrPayloadType.audio) fType = fp.FileType.audio;
                          if (config.payloadType == QrPayloadType.pdf || config.payloadType == QrPayloadType.excel) fType = fp.FileType.custom;
                          _pickAndUploadFile(notifier, config.payloadType, type: fType);
                        },
                      ),
                      if (config.data.startsWith('http'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Uploaded File URL:\n${config.data}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                        ),
                    ],

                    const SizedBox(height: 24),
                    
                    if (config.payloadType != QrPayloadType.barcode) ...[
                      // Frames
                      ExpansionTile(
                        title: const Text('Frames & Texts'),
                        leading: const Icon(Icons.crop_free),
                        children: [
                          ListTile(
                            title: const Text('Select Frame'),
                            subtitle: Text(config.frameStyle.name.toUpperCase()),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _showFrameSelectionDialog(context, config, notifier),
                          ),
                          const SizedBox(height: 16),
                          if (config.frameStyle != QrFrameStyle.none) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                initialValue: config.frameText,
                                decoration: const InputDecoration(labelText: 'Frame Text'),
                                onChanged: (v) => notifier.updateFrameStyle(text: v),
                              ),
                            ),
                            ListTile(
                              title: const Text('Frame Color'),
                              trailing: Container(width: 32, height: 32, color: config.frameColor.color),
                              onTap: () => _showColorPicker(context, config.frameColor.color, (c) => notifier.updateFrameStyle(color: config.frameColor.copyWith(color: c))),
                            ),
                            ListTile(
                              title: const Text('Frame Text Color'),
                              trailing: Container(width: 32, height: 32, color: config.frameTextColor.color),
                              onTap: () => _showColorPicker(context, config.frameTextColor.color, (c) => notifier.updateFrameStyle(textColor: config.frameTextColor.copyWith(color: c))),
                            ),
                          ],
                        ],
                      ),
                      
                      // Customizations
                      ExpansionTile(
                        title: const Text('Logo'),
                        leading: const Icon(Icons.image),
                        children: [
                          ListTile(title: const Text('Select Image'), trailing: const Icon(Icons.photo_library), onTap: _pickLogo),
                          if (config.logoPath != null)
                            ListTile(title: const Text('Remove Image'), trailing: const Icon(Icons.delete, color: Colors.red), onTap: () => notifier.updateLogo(null)),
                        ],
                      ),
                      
                      // Styling
                      ExpansionTile(
                        title: const Text('Styling & Design'),
                        leading: const Icon(Icons.color_lens),
                        children: [
                          ListTile(
                            title: const Text('Overall Shape'),
                            trailing: DropdownButton<QrOverallShape>(
                              value: config.overallShape,
                              onChanged: (val) => val != null ? notifier.updateOverallShape(val) : null,
                              items: const [DropdownMenuItem(value: QrOverallShape.square, child: Text('Square')), DropdownMenuItem(value: QrOverallShape.circle, child: Text('Circle'))],
                            ),
                          ),
                          ListTile(
                            title: const Text('Background Color'),
                            trailing: Container(width: 32, height: 32, decoration: BoxDecoration(color: config.backgroundColor.color, border: Border.all(color: Colors.grey))),
                            onTap: () => _showColorPicker(context, config.backgroundColor.color, (c) => notifier.updateBackgroundColor(config.backgroundColor.copyWith(color: c))),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Dot Shape (Data)'),
                            trailing: DropdownButton<QrDataModuleShape>(
                              value: config.dotShape,
                              onChanged: (val) => val != null ? notifier.updateDotStyle(val, config.dotColor) : null,
                              items: QrDataModuleShape.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            ),
                          ),
                          ListTile(
                            title: const Text('Dot Color'),
                            trailing: Container(width: 32, height: 32, color: config.dotColor.color),
                            onTap: () => _showColorPicker(context, config.dotColor.color, (c) => notifier.updateDotStyle(config.dotShape, config.dotColor.copyWith(color: c))),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Outer Eye Shape (Finder Pattern)'),
                            trailing: DropdownButton<QrEyeShape>(
                              value: config.cornerOutsideShape,
                              onChanged: (val) => val != null ? notifier.updateCornerOutsideStyle(val, config.cornerOutsideColor) : null,
                              items: QrEyeShape.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            ),
                          ),
                          ListTile(
                            title: const Text('Outer Eye Color'),
                            trailing: Container(width: 32, height: 32, color: config.cornerOutsideColor.color),
                            onTap: () => _showColorPicker(context, config.cornerOutsideColor.color, (c) => notifier.updateCornerOutsideStyle(config.cornerOutsideShape, config.cornerOutsideColor.copyWith(color: c))),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Inner Eye Shape'),
                            trailing: DropdownButton<QrInnerEyeShape>(
                              value: config.cornerInsideShape,
                              onChanged: (val) => val != null ? notifier.updateCornerInsideStyle(val, config.cornerInsideColor) : null,
                              items: QrInnerEyeShape.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            ),
                          ),
                          ListTile(
                            title: const Text('Inner Eye Color'),
                            trailing: Container(width: 32, height: 32, color: config.cornerInsideColor.color),
                            onTap: () => _showColorPicker(context, config.cornerInsideColor.color, (c) => notifier.updateCornerInsideStyle(config.cornerInsideShape, config.cornerInsideColor.copyWith(color: c))),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFrameSelectionDialog(BuildContext context, QrConfigModel config, QrConfig notifier) {
    final categories = {
      'None': [QrFrameStyle.none],
      'Tooltips': [QrFrameStyle.tooltipTop, QrFrameStyle.tooltipBottom, QrFrameStyle.tooltipLeft, QrFrameStyle.tooltipRight],
      'Borders': [QrFrameStyle.borderThick, QrFrameStyle.borderThin, QrFrameStyle.borderDashed, QrFrameStyle.borderDotted],
      'Badges': [QrFrameStyle.badgeCircle, QrFrameStyle.badgeShield, QrFrameStyle.badgeStarburst],
      'Layouts': [QrFrameStyle.layoutHeader, QrFrameStyle.layoutFooter, QrFrameStyle.layoutSplit],
      'Modern': [QrFrameStyle.modernNeon, QrFrameStyle.modernShadow, QrFrameStyle.modernGlass],
      'Specialty': [QrFrameStyle.specialtyTicket, QrFrameStyle.specialtyReceipt, QrFrameStyle.specialtyPhone],
      'Minimalist': [QrFrameStyle.minimalistBrackets, QrFrameStyle.minimalistSidebar],
    };

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Custom Frames', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.keys.length,
                    itemBuilder: (context, index) {
                      final category = categories.keys.elementAt(index);
                      final styles = categories[category]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: styles.map((style) {
                              final isSelected = config.frameStyle == style;
                              return GestureDetector(
                                onTap: () {
                                  notifier.updateFrameStyle(style: style);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300, width: isSelected ? 3 : 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IgnorePointer(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: QrFrameWidget(
                                        config: config.copyWith(frameStyle: style),
                                        child: Container(width: 150, height: 150, color: Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.black12),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
