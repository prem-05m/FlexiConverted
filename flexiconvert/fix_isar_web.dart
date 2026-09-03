import 'dart:io';

void main() {
  final Map<String, String> replacements = {
    '8773120788250692482': '8773120788250692608',
    '2918041768256347220': '2918041768256347136',
    '-4222060418120810312': '-4222060418120810496',
    '1562904810927054119': '1562904810927054080',
    '-1537962893477976456': '-1537962893477976576',
    '428040767606462206': '428040767606462208',
    '-5633561779022347008': '-5633561779022347264',
    '-8790468936041821297': '-8790468936041821184',
  };

  final dir = Directory('lib/core/database/models');
  final files = dir.listSync().where((e) => e.path.endsWith('.g.dart')).cast<File>();

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;
    
    replacements.forEach((oldStr, newStr) {
      if (content.contains(oldStr)) {
        content = content.replaceAll(oldStr, newStr);
        changed = true;
      }
    });

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
    }
  }
}
