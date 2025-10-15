import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model.dart';
import '../models/activity_report_model.dart';
import '../models/learning_progress_model.dart';

class ReportGenerator {
  static Future<void> generateAndPrintReport({
    required UserModel internUser,
    required List<ActivityReportModel> activityReports,
    required List<LearningProgressModel> learningProgress,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final internData = internUser.intern;

    // Load font yang mendukung karakter lebih luas (opsional tapi disarankan)
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    // Judul Dokumen
    pdf.addPage(
      pw.MultiPage(
        header: (context) => _buildHeader(internUser, startDate, endDate, boldFont),
        build: (context) => [
          _buildInternProfile(internData, font, boldFont),
          pw.SizedBox(height: 20),
          _buildSectionTitle('Rangkuman Laporan Aktivitas', boldFont),
          _buildActivityReportsTable(activityReports, font),
          pw.SizedBox(height: 20),
          _buildSectionTitle('Rangkuman Progres Pembelajaran', boldFont),
          _buildLearningProgressList(learningProgress, font),
        ],
        footer: (context) => _buildFooter(font),
      ),
    );

    // Menampilkan preview cetak dan opsi berbagi
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildHeader(UserModel user, DateTime start, DateTime end, pw.Font boldFont) {
    final period =
        'Periode: ${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(bottom: 20.0),
        child: pw.Column(
            children: [
              pw.Text('Laporan Rangkuman Peserta Magang',
                  style: pw.TextStyle(font: boldFont, fontSize: 18)),
              pw.Text(period, style: pw.TextStyle(fontSize: 12)),
            ]
        )
    );
  }

  static pw.Widget _buildInternProfile(dynamic intern, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Profil Peserta', style: pw.TextStyle(font: boldFont, fontSize: 16)),
        pw.Divider(),
        _profileRow('Nama Lengkap', intern?.fullName ?? 'N/A', font),
        _profileRow('Asal Sekolah', intern?.schoolOrigin ?? 'N/A', font),
        _profileRow('Jurusan', intern?.major ?? 'N/A', font),
      ],
    );
  }

  static pw.Widget _profileRow(String title, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(title, style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text(': $value', style: pw.TextStyle(font: font)),
        ],
      ),
    );
  }


  static pw.Widget _buildSectionTitle(String text, pw.Font boldFont) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 16)),
      pw.Divider(),
      pw.SizedBox(height: 8),
    ]);
  }

  static pw.Widget _buildActivityReportsTable(List<ActivityReportModel> reports, pw.Font font) {
    if (reports.isEmpty) {
      return pw.Text('Tidak ada laporan aktivitas pada periode ini.', style: pw.TextStyle(font: font));
    }
    final headers = ['Tanggal', 'Judul Aktivitas'];
    final data = reports
        .map((report) => [
      DateFormat('dd/MM/yyyy').format(report.reportDate),
      report.title,
    ])
        .toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
      cellStyle: pw.TextStyle(font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildLearningProgressList(List<LearningProgressModel> progresses, pw.Font font) {
    if (progresses.isEmpty) {
      return pw.Text('Tidak ada progres pembelajaran pada periode ini.', style: pw.TextStyle(font: font));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: progresses.map((progress) {
        return pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 8),
              pw.Text('• ', style: pw.TextStyle(font: font)),
              pw.Expanded(
                child: pw.Text(
                  '${progress.moduleTitle ?? "N/A"} (Status: ${progress.progressStatus})',
                  style: pw.TextStyle(font: font),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Text(
        'Laporan ini dibuat secara otomatis oleh sistem SiMagang',
        style: pw.TextStyle(color: PdfColors.grey, font: font),
      ),
    );
  }
}