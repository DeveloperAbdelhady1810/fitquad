import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'health_service.dart';

class HealthPdfService {
  static Future<Uint8List> generateReport({
    required HealthSnapshot snapshot,
    required String memberName,
  }) async {
    final pdf = pw.Document();
    final date = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    final time = DateFormat('hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#1E0A35'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FitQuad',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Health Summary Report',
                          style: const pw.TextStyle(
                            fontSize: 13,
                            color: PdfColors.grey300,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          date,
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey300,
                          ),
                        ),
                        pw.Text(
                          time,
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Member name
              pw.Text(
                'Member: $memberName',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E0A35'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // Section title
              pw.Text(
                'Today\'s Smartwatch Data',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E0A35'),
                ),
              ),
              pw.SizedBox(height: 16),

              // Metric cards — 2 columns
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _metricCard(
                      label: 'Steps Today',
                      value: snapshot.steps.toString(),
                      unit: 'steps',
                      accent: PdfColor.fromHex('#00897B'),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _metricCard(
                      label: 'Heart Rate',
                      value: snapshot.heartRateBpm > 0
                          ? snapshot.heartRateBpm.toString()
                          : '—',
                      unit: 'bpm',
                      accent: PdfColor.fromHex('#E53935'),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _metricCard(
                      label: 'Sleep Last Night',
                      value: snapshot.sleepHrs > 0
                          ? snapshot.sleepHrs.toStringAsFixed(1)
                          : '—',
                      unit: 'hours',
                      accent: PdfColor.fromHex('#1565C0'),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _metricCard(
                      label: 'Active Calories',
                      value: snapshot.caloriesBurned.toString(),
                      unit: 'kcal',
                      accent: PdfColor.fromHex('#43A047'),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // Progress bars
              pw.Text(
                'Daily Goal Progress',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E0A35'),
                ),
              ),
              pw.SizedBox(height: 12),
              _progressBar(
                label: 'Steps',
                value: snapshot.steps,
                goal: 10000,
                color: PdfColor.fromHex('#00897B'),
              ),
              pw.SizedBox(height: 8),
              _progressBar(
                label: 'Active Calories',
                value: snapshot.caloriesBurned,
                goal: 500,
                color: PdfColor.fromHex('#43A047'),
              ),
              pw.SizedBox(height: 8),
              _progressBar(
                label: 'Sleep',
                value: (snapshot.sleepHrs * 10).round(),
                goal: 80,
                unit: 'hrs (goal: 8h)',
                color: PdfColor.fromHex('#1565C0'),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated by FitQuad™',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                  pw.Text(
                    'Data sourced from Apple Health / Health Connect',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _metricCard({
    required String label,
    required String value,
    required String unit,
    required PdfColor accent,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  unit,
                  style: pw.TextStyle(fontSize: 11, color: accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _progressBar({
    required String label,
    required int value,
    required int goal,
    required PdfColor color,
    String? unit,
  }) {
    final pct = (value / goal).clamp(0.0, 1.0);
    final display = unit ?? '';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
            pw.Text('$value / $goal $display',
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey500)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.LayoutBuilder(
          builder: (ctx, constraints) {
            final totalWidth = constraints?.maxWidth ?? 400;
            final fillWidth = totalWidth * pct;
            return pw.Stack(
              children: [
                pw.Container(
                  width: totalWidth,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
                pw.Container(
                  width: fillWidth,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: color,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
