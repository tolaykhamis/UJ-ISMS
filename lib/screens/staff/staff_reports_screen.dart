// screens/staff/staff_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  // ── PDF colours (mirrors admin SystemReportsScreen) ──────────────────────
  static const _teal      = PdfColor.fromInt(0xFF062C2B);
  static const _tealLight = PdfColor.fromInt(0xFFE6F4F3);
  static const _grey      = PdfColor.fromInt(0xFF64748B);
  static const _red       = PdfColor.fromInt(0xFFBE123C);
  static const _redLight  = PdfColor.fromInt(0xFFFFF1F2);

  // ── PDF stat box helper ───────────────────────────────────────────────────
  pw.Widget _pdfStatBox(
      String label, String value, PdfColor textColor, PdfColor bgColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 8,
                  color: textColor,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ── PDF builder ───────────────────────────────────────────────────────────
  Future<void> _generateAndSharePdf(
    BuildContext context,
    List<RequestModel> requests,
    String staffName,
    String staffEmail,
  ) async {
    final pdf = pw.Document();

    final now     = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final total      = requests.length;
    final pending    = requests.where((r) => r.status == 'Pending').length;
    final inProgress = requests.where((r) => r.status == 'On Progress').length;
    final completed  = requests.where((r) => r.status == 'Completed').length;
    final cancelled  = requests.where((r) => r.status == 'Cancelled').length;
    final urgent     = requests.where((r) => r.priority == 'Urgent').length;
    final high       = requests.where((r) => r.priority == 'High').length;
    final efficiency =
        total > 0 ? ((completed / total) * 100).toStringAsFixed(1) : '0.0';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: const pw.BoxDecoration(color: _teal),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('UJ ISMS',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2)),
                  pw.Text('Staff Performance Report',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text(dateStr,
                  style: const pw.TextStyle(
                      color: PdfColors.grey, fontSize: 10)),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}  ·  UJ ISMS Confidential',
            style: const pw.TextStyle(color: _grey, fontSize: 9),
          ),
        ),
        build: (ctx) => [
          pw.SizedBox(height: 16),

          // ── Staff info ─────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _tealLight,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Staff Member',
                    style: pw.TextStyle(
                        fontSize: 9,
                        color: _teal,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(staffName,
                    style: pw.TextStyle(
                        fontSize: 14,
                        color: _teal,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(staffEmail,
                    style: const pw.TextStyle(fontSize: 9, color: _grey)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Summary stats grid ─────────────────────────────────────────────
          pw.Text('Summary Statistics',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _teal)),
          pw.SizedBox(height: 10),
          pw.GridView(
            crossAxisCount: 4,
            childAspectRatio: 1.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _pdfStatBox('Total Assigned', '$total',      _teal, _tealLight),
              _pdfStatBox('Pending',        '$pending',    _teal, _tealLight),
              _pdfStatBox('Completed',      '$completed',  _teal, _tealLight),
              _pdfStatBox('Efficiency',     '$efficiency%',_teal, _tealLight),
              _pdfStatBox('In Progress',    '$inProgress', _teal, _tealLight),
              _pdfStatBox('Cancelled',      '$cancelled',  _teal, _tealLight),
              _pdfStatBox('Urgent',         '$urgent',     _red,  _redLight),
              _pdfStatBox('High',           '$high',       _teal, _tealLight),
            ],
          ),
          pw.SizedBox(height: 24),

          // ── Requests table ─────────────────────────────────────────────────
          if (requests.isNotEmpty) ...[
            pw.Text('Assigned Request Details',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _teal)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromInt(0xFFCBD5E1), width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(2.0),
                2: const pw.FlexColumnWidth(1.4),
                3: const pw.FlexColumnWidth(1.4),
                4: const pw.FlexColumnWidth(1.8),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _teal),
                  children: ['Request ID', 'Department', 'Status', 'Priority', 'Date']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9)),
                          ))
                      .toList(),
                ),
                // Data rows
                ...requests.map((r) {
                  final isEven = requests.indexOf(r) % 2 == 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: isEven
                            ? PdfColors.white
                            : PdfColor.fromInt(0xFFF4F7F6)),
                    children: [
                      r.requestId.length > 12
                          ? '${r.requestId.substring(0, 12)}...'
                          : r.requestId,
                      r.departmentName.isNotEmpty
                          ? r.departmentName
                          : r.departmentId,
                      r.status,
                      r.priority,
                      r.date.length >= 10 ? r.date.substring(0, 10) : r.date,
                    ]
                        .map((v) => pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Text(v,
                                  style: const pw.TextStyle(fontSize: 8.5)),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
          ] else ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                  color: _tealLight,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8))),
              child: pw.Center(
                child: pw.Text('No assigned requests found.',
                    style: const pw.TextStyle(color: _grey)),
              ),
            ),
          ],

          pw.SizedBox(height: 30),
          pw.Divider(color: PdfColor.fromInt(0xFFCBD5E1)),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report was auto-generated by UJ ISMS on $dateStr.\n'
            'University of Jordan — Inter-Departmental Services & Equipment Management System.',
            style: const pw.TextStyle(color: _grey, fontSize: 8),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'UJ_ISMS_Staff_Report_${now.year}-${now.month}-${now.day}.pdf',
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('My Reports',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: service.getStaffRequests(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests   = snapshot.data ?? [];
          final total      = requests.length;
          final pending    = requests.where((r) => r.status == 'Pending').length;
          final inProgress = requests.where((r) => r.status == 'On Progress').length;
          final completed  = requests.where((r) => r.status == 'Completed').length;
          final cancelled  = requests.where((r) => r.status == 'Cancelled').length;
          final urgent     = requests.where((r) => r.priority == 'Urgent').length;
          final high       = requests.where((r) => r.priority == 'High').length;
          final efficiency =
              total > 0 ? ((completed / total) * 100).toStringAsFixed(1) : '0.0';

          final stats = [
            ['Total Assigned', '$total'],
            ['Efficiency',     '$efficiency%'],
            ['Completed',      '$completed'],
            ['Pending',        '$pending'],
            ['In Progress',    '$inProgress'],
            ['Cancelled',      '$cancelled'],
            ['Urgent Priority','$urgent'],
            ['High Priority',  '$high'],
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your workload summary based on assigned requests.',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // ── Stats grid ───────────────────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: stats.map((s) {
                    final isUrgent =
                        s[0] == 'Urgent Priority' && urgent > 0;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? const Color(0xFFFFF1F2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isUrgent
                              ? const Color(0xFFFFCDD2)
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s[0],
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isUrgent
                                      ? const Color(0xFFBE123C)
                                      : Colors.black45)),
                          const SizedBox(height: 6),
                          Text(s[1],
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isUrgent
                                      ? const Color(0xFFBE123C)
                                      : AppColors.primary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── Zero-state note ──────────────────────────────────────────
                if (total == 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Color(0xFFC2410C)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No requests assigned to you yet.',
                            style: TextStyle(
                                color: Color(0xFFC2410C), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // ── Generate & Share PDF ─────────────────────────────────────
                GradientButton(
                  label: '📄  Generate & Share PDF Report',
                  onPressed: () => _generateAndSharePdf(
                      context, requests, user.name, user.email),
                ),
                const SizedBox(height: 10),

                // ── Print ────────────────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () async {
                    await Printing.layoutPdf(
                      onLayout: (format) async {
                        final printDoc = pw.Document();
                        final now = DateTime.now();
                        printDoc.addPage(
                          pw.Page(
                            pageFormat: format,
                            build: (ctx) => pw.Column(
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                    'UJ ISMS — Staff Performance Report',
                                    style: pw.TextStyle(
                                        fontSize: 20,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                    'Staff: ${user.name}  (${user.email})'),
                                pw.Text(
                                    'Generated: ${now.day}/${now.month}/${now.year}'),
                                pw.SizedBox(height: 20),
                                pw.Text(
                                    'Total: $total   Pending: $pending   '
                                    'Completed: $completed   Urgent: $urgent'),
                                pw.SizedBox(height: 20),
                                pw.Table.fromTextArray(
                                  headers: [
                                    'ID',
                                    'Dept',
                                    'Status',
                                    'Priority',
                                    'Date'
                                  ],
                                  data: requests
                                      .map((r) => [
                                            r.requestId.length > 10
                                                ? r.requestId
                                                    .substring(0, 10)
                                                : r.requestId,
                                            r.departmentName.isNotEmpty
                                                ? r.departmentName
                                                : r.departmentId,
                                            r.status,
                                            r.priority,
                                            r.date.length >= 10
                                                ? r.date.substring(0, 10)
                                                : r.date,
                                          ])
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                        return printDoc.save();
                      },
                    );
                  },
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Print Report'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}