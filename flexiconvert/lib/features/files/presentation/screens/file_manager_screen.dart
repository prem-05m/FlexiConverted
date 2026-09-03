import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  Directory? _currentDir;
  List<FileSystemEntity> _entities = [];

  @override
  void initState() {
    super.initState();
    _initDir();
  }

  Future<void> _initDir() async {
    final dir = await getApplicationDocumentsDirectory();
    _loadDir(dir);
  }

  void _loadDir(Directory dir) {
    setState(() {
      _currentDir = dir;
      _entities = dir.listSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentDir?.path.split('/').last ?? 'File Manager'),
        leading: BackButton(
          onPressed: () {
            if (_currentDir != null && _currentDir!.parent.path != _currentDir!.path) {
              _loadDir(_currentDir!.parent);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _entities.isEmpty
          ? const Center(child: Text('Empty folder'))
          : ListView.builder(
              itemCount: _entities.length,
              itemBuilder: (context, index) {
                final entity = _entities[index];
                final isDir = entity is Directory;
                return ListTile(
                  leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file),
                  title: Text(path.basename(entity.path)),
                  onTap: isDir
                      ? () => _loadDir(entity)
                      : null,
                );
              },
            ),
    );
  }
}
