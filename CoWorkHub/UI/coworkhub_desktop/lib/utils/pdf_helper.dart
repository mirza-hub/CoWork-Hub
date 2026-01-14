import 'dart:io';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/dashboard_stats.dart';
import '../models/revenue_by_month.dart';

class PdfHelper {
  static Future<void> saveDashboardPdf(
    BuildContext context,
    DashboardStats stats, {
    List<RevenueByMonth>? revenueByMonth,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          // Naslov
          pw.Text(
            "Dashboard Stats",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Ukupno rezervacija: ${stats.totalReservations}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Aktivne rezervacije: ${stats.activeReservations}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Otkazane rezervacije: ${stats.cancelledReservations}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Korisnici: ${stats.totalUsers}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Workspace-ovi: ${stats.totalWorkingSpaces}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Prihod: ${stats.totalRevenue.toStringAsFixed(2)} KM",
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // Rezervacije po gradovima
          if (stats.reservationsByCity != null &&
              stats.reservationsByCity!.isNotEmpty) ...[
            pw.Text(
              "Rezervacije po gradovima",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: stats.reservationsByCity!.entries
                  .map((e) => pw.Text("${e.key}: ${e.value}"))
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Rezervacije po tipu workspace-a
          if (stats.reservationsByWorkspaceType != null &&
              stats.reservationsByWorkspaceType!.isNotEmpty) ...[
            pw.Text(
              "Rezervacije po tipu workspace-a",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: stats.reservationsByWorkspaceType!.entries
                  .map((e) => pw.Text("${e.key}: ${e.value}"))
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Prihod po mjesecima
          if (revenueByMonth != null && revenueByMonth.isNotEmpty) ...[
            pw.Text(
              "Prihod po mjesecima",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: revenueByMonth
                  .map(
                    (r) => pw.Text(
                      "${r.month}: ${r.revenue.toStringAsFixed(2)} KM",
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );

    // Otvori dijalog za spremanje sa predloženim nazivom
    final typeGroup = XTypeGroup(label: 'pdf', extensions: ['pdf']);
    final filePath = await getSavePath(
      suggestedName: 'dashboard_stats.pdf',
      acceptedTypeGroups: [typeGroup],
    );

    if (filePath != null) {
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      showTopFlushBar(
        context: context,
        message: "PDF je uspješno sačuvan!",
        backgroundColor: Colors.green,
      );
      print("PDF sačuvan: ${file.path}");
    }
  }
}
