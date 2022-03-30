import 'dart:io';
import 'package:create_invoice_demo/src/api/pdf_api.dart';
import 'package:create_invoice_demo/src/model/customer.dart';
import 'package:create_invoice_demo/src/model/supplier.dart';
import 'package:create_invoice_demo/src/utils/Utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../model/invoice.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();
    
    pdf.addPage(MultiPage(
      build: (context)=>[
        buildHeader(invoice),
        SizedBox(height: 3*PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context)=> buildFooter(invoice),
    ));

    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1 * PdfPageFormat.cm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSupplierAddress(invoice.supplier),
            Container(
              height: 50,
              width: 50,
              child: BarcodeWidget(
                  data: invoice.info.number,
                  barcode: Barcode.fromType(BarcodeType.QrCode)
              )
            )
          ]
        ),
        SizedBox(height: 1 * PdfPageFormat.cm),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.info),
            ]
        ),
      ]
    );
  }

  static Widget buildSupplierAddress(Supplier supplier){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 1*PdfPageFormat.mm),
        Text(supplier.address),

      ]
    );
  }

  static Widget buildCustomerAddress(Customer customer){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1*PdfPageFormat.mm),
          Text(customer.address),

        ]
    );
  }

  static Widget buildInvoiceInfo(InvoiceInfo info){
    final paymentTerms= '${info.dueDate.difference(info.date)}';
    final titles=[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:',
    ];

    final data=[
      info.number,
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index){
        final title=titles[index];
        final value=data[index];

        return buildText(title: title, value: value, width: 200);
      })
    );
  }

  static Widget buildTitle(Invoice invoice){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brother\'s Pizza Hut',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
        SizedBox(height: 0.8*PdfPageFormat.cm),
        Text(invoice.info.description),

      ]
    );
  }

  static Widget buildInvoice(Invoice invoice){
    final headers=[
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];

    final data=invoice.items.map((item){
      final total=item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        '\$ ${item.unitPrice}',
        '${item.vat} %',
        '\$ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.center,
        1: Alignment.center,
        2: Alignment.center,
        3: Alignment.center,
        4: Alignment.center,
        5: Alignment.center,
      }
    );
  }

  static Widget buildTotal(Invoice invoice){
    final netTotal=invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((value, element) => value + element);

    final vatPercent= invoice.items.first.vat;
    final vat=netTotal * vatPercent;
    final total=netTotal + vat;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(title: 'Net Total', value: Utils.formatPrice(netTotal), unite: true),
                buildText(title: 'Vat ${vatPercent * 100} %', value: Utils.formatPrice(vat), unite: true),
                Divider(),
                buildText(
                    title: 'Total amount due',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    value: Utils.formatPrice(total),
                    unite: true
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ]
            ),

          )
        ]
      )
    );
  }

  static buildText({
    required String title,
    required String value,
    double width =double.infinity,
    TextStyle? titleStyle,
    bool unite= false,
    }){
        final style=titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

        return Container(
          width: width,
          child: Row(
            children: [
              Expanded(child: Text(title, style: style)),
              Text(value, style: unite ? style : null),
            ]
          )
        );
    }

    static Widget buildFooter(Invoice invoice){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2*PdfPageFormat.mm),
          buildSimpleText(title: 'Address', value: invoice.supplier.address),
          SizedBox(height: 1*PdfPageFormat.mm),
          buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo)
        ]
      );
    }

    static buildSimpleText({
      required String title,
      required String value,
    }){
        final style=TextStyle(fontWeight: FontWeight.bold);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: style),
            SizedBox(width: 2*PdfPageFormat.mm),
            Text(value),
          ]
        );
    }

}