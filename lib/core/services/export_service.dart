import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class ExportService {
  /// Export transactions to CSV
  static Future<File> exportToCSV(List<TransactionModel> transactions, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = filename ?? 'pinkledger_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');

    final rows = <List<dynamic>>[
      ['ID', 'Type', 'Amount', 'Currency', 'Category', 'Payment Method', 'Date', 'Description', 'Merchant', 'Status'],
    ];

    for (final t in transactions) {
      rows.add([
        t.id,
        t.type,
        t.amount,
        t.currency,
        t.category,
        t.paymentMethod,
        t.date.toIso8601String(),
        t.description,
        t.merchantName ?? '',
        t.status,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    return file;
  }

  /// Export transactions to PDF
  static Future<File> exportToPDF(List<TransactionModel> transactions, {String? filename}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PINKLEDGER', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1E1033))),
              pw.Text('Every Rupee, Under Control.', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Text('Financial Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Generated: ${DateTime.now().toString()}', style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Type', 'Category', 'Amount', 'Date', 'Description', 'Status'],
                data: transactions.map((t) => [
                  t.type.toUpperCase(),
                  t.category,
                  '${AppConstants.currencySymbol}${t.amount.toStringAsFixed(0)}',
                  t.date.toString().substring(0, 10),
                  t.description,
                  t.status.toUpperCase(),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Transactions: ${transactions.length}', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = filename ?? 'pinkledger_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
