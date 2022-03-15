import 'dart:io';
import 'package:create_invoice_demo/src/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../model/invoice.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();

    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }


}