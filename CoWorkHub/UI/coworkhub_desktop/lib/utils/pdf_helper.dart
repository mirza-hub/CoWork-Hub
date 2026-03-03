import 'dart:io';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/dashboard_stats.dart';
import '../models/revenue_by_month.dart';

class PdfHelper {
  static const headerColor = PdfColor.fromInt(0xFF1976D2);
  static const lightBlueColor = PdfColor.fromInt(0xFFE3F2FD);

  static final headerStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: headerColor,
  );

  static final cellStyle = pw.TextStyle(fontSize: 12);
  static final sectionTitleStyle = pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
  );

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 2)),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  static Future<void> saveDashboardPdf(
    BuildContext context,
    DashboardStats stats, {
    List<RevenueByMonth>? revenueByMonth,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          _buildHeader("Izvjestaj o Statistici Dashboard-a"),

          // Glavne statistike - tabela
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerColor),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "Metrika",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "Vrijednost",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Ukupno rezervacija", style: cellStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      stats.totalReservations.toString(),
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Aktivne rezervacije", style: cellStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      stats.activeReservations.toString(),
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Otkazane rezervacije", style: cellStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      stats.cancelledReservations.toString(),
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Ukupno korisnika", style: cellStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      stats.totalUsers.toString(),
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Workspace-ovi", style: cellStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      stats.totalWorkingSpaces.toString(),
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Ukupni prihod", style: cellStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "${stats.totalRevenue.toStringAsFixed(2)} KM",
                      style: cellStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          // Rezervacije po gradovima
          if (stats.reservationsByCity != null &&
              stats.reservationsByCity!.isNotEmpty) ...[
            pw.Text("Rezervacije po gradovima", style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBlueColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("Grad", style: headerStyle),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("Broj rezervacija", style: headerStyle),
                    ),
                  ],
                ),
                ...stats.reservationsByCity!.entries.map(
                  (e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.key, style: cellStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.value.toString(), style: cellStyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Rezervacije po tipu workspace-a
          if (stats.reservationsByWorkspaceType != null &&
              stats.reservationsByWorkspaceType!.isNotEmpty) ...[
            pw.Text("Rezervacije po tipu prostora", style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBlueColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("Tip prostora", style: headerStyle),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("Broj rezervacija", style: headerStyle),
                    ),
                  ],
                ),
                ...stats.reservationsByWorkspaceType!.entries.map(
                  (e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.key, style: cellStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.value.toString(), style: cellStyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Prihod po mjesecima
          if (revenueByMonth != null && revenueByMonth.isNotEmpty) ...[
            pw.Text("Prihod po mjesecima", style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBlueColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("Mjesec", style: headerStyle),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("Prihod (KM)", style: headerStyle),
                    ),
                  ],
                ),
                ...revenueByMonth.map(
                  (r) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(r.month, style: cellStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "${r.revenue.toStringAsFixed(2)} KM",
                          style: cellStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    await _savePdf(context, pdf, 'dashboard_report.pdf');
  }

  static Future<void> saveReservationsByCitiesPdf(
    BuildContext context,
    DashboardStats stats,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          _buildHeader("Izvjestaj - Rezervacije po Gradovima"),

          if (stats.reservationsByCity != null &&
              stats.reservationsByCity!.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Grad",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Broj Rezervacija",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ...stats.reservationsByCity!.entries.map(
                  (e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.key, style: cellStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.value.toString(), style: cellStyle),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            pw.Text("Nema dostupnih podataka", style: cellStyle),
        ],
      ),
    );

    await _savePdf(context, pdf, 'reservations_by_cities.pdf');
  }

  static Future<void> saveReservationsByRoomTypePdf(
    BuildContext context,
    DashboardStats stats,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          _buildHeader("Izvjestaj - Rezervacije po Tipu Prostora"),

          if (stats.reservationsByWorkspaceType != null &&
              stats.reservationsByWorkspaceType!.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Tip Prostora",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Broj Rezervacija",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ...stats.reservationsByWorkspaceType!.entries.map(
                  (e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.key, style: cellStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.value.toString(), style: cellStyle),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            pw.Text("Nema dostupnih podataka", style: cellStyle),
        ],
      ),
    );

    await _savePdf(context, pdf, 'reservations_by_room_type.pdf');
  }

  static Future<void> saveRevenueByMonthPdf(
    BuildContext context,
    List<RevenueByMonth>? revenueByMonth,
  ) async {
    final pdf = pw.Document();

    final totalRevenue =
        revenueByMonth?.fold<double>(
          0,
          (prev, element) => prev + element.revenue,
        ) ??
        0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          _buildHeader("Izvjestaj - Prihod po Mjesecima"),

          // Sažetak
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightBlueColor,
              border: pw.Border.all(),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Ukupni Prihod: ${totalRevenue.toStringAsFixed(2)} KM",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          if (revenueByMonth != null && revenueByMonth.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Mjesec",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        "Prihod (KM)",
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ...revenueByMonth.map(
                  (r) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(r.month, style: cellStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "${r.revenue.toStringAsFixed(2)} KM",
                          style: cellStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            pw.Text("Nema dostupnih podataka", style: cellStyle),
        ],
      ),
    );

    await _savePdf(context, pdf, 'revenue_by_month.pdf');
  }

  static Future<void> _savePdf(
    BuildContext context,
    pw.Document pdf,
    String filename,
  ) async {
    final typeGroup = XTypeGroup(label: 'pdf', extensions: ['pdf']);
    final filePath = await getSavePath(
      suggestedName: filename,
      acceptedTypeGroups: [typeGroup],
    );

    if (filePath != null) {
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      showTopFlushBar(
        context: context,
        message: "$filename je uspješno sačuvan!",
        backgroundColor: Colors.green,
      );
      print("PDF sačuvan: ${file.path}");
    }
  }
}
