import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/cart_item_model.dart';

class PdfService {
  Future<bool> generateAndSaveInvoice(List<CartItem> cartItems) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Calculate totals
      double totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      int totalItems = cartItems.fold(0, (sum, item) => sum + item.quantity);

      // Add page to PDF (add your content here)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['Product', 'Price', 'Qty', 'Total'],
                  data: cartItems.map((item) => [
                    item.productName,
                    'rupees${item.price.toStringAsFixed(2)}',
                    item.quantity.toString(),
                    'rupees${item.totalPrice.toStringAsFixed(2)}',
                  ]).toList(),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total Items: $totalItems', style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(width: 20),
                    pw.Text('Total: rupees${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Get the correct Downloads directory for Android
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        print('Directory is null');
        return false;
      }

      // Save PDF file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/invoice_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());
      return true;
    } catch (e) {
      print('Error generating PDF: $e');
      return false;
    }
  }
}
