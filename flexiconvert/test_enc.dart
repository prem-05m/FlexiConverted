import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  var doc = PdfDocument();
  doc.pages.add();
  doc.security.userPassword = 'abc';
  File('test_enc.pdf').writeAsBytesSync(doc.saveSync());
  doc.dispose();
  
  var doc2 = PdfDocument(inputBytes: File('test_enc.pdf').readAsBytesSync(), password: 'abc');
  doc2.security.userPassword = '';
  doc2.security.ownerPassword = '';
  File('test_dec.pdf').writeAsBytesSync(doc2.saveSync());
  doc2.dispose();
  
  var doc3 = PdfDocument(inputBytes: File('test_dec.pdf').readAsBytesSync());
  print('Decrypted successfully!');
}
