import 'package:create_invoice_demo/src/api/pdf_api.dart';
import 'package:create_invoice_demo/src/model/customer.dart';
import 'package:create_invoice_demo/src/model/invoice.dart';
import 'package:create_invoice_demo/src/model/supplier.dart';
import 'package:flutter/material.dart';

import '../api/pdf_invoice_api.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: ()async{
            final date=DateTime.now();
            final dueDate=date.add(Duration(days: 7));

            final invoice=Invoice(
                info: InvoiceInfo(
                    description: 'Nice',
                    number: '1001',
                    date: date,
                    dueDate: dueDate
                ),
                supplier: Supplier(
                    name: 'Rahim',
                    address: 'Dr. para, Feni',
                    paymentInfo: 'A/C No.: 88078451245'
                ),
                customer: Customer(
                    name: 'Karim Miyah',
                    address: 'Chittagong'
                ),
                items: [
                  InvoiceItem(
                      description: 'Fresh Condition',
                      date: date,
                      quantity: 5,
                      vat: 50,
                      unitPrice: 50000
                  ),
                  InvoiceItem(
                      description: 'Fresh Condition',
                      date: date,
                      quantity: 5,
                      vat: 50,
                      unitPrice: 50000
                  ),
                  InvoiceItem(
                      description: 'Fresh Condition',
                      date: date,
                      quantity: 5,
                      vat: 50,
                      unitPrice: 50000
                  ),
                ]
            );

            final pdfFile=await PdfInvoiceApi.generate(invoice);

            PdfApi.openFile(pdfFile);
          },
          child: Text('Create Invoice'),
        ),
      ),
    );
  }
}
