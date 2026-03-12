import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/pdf_native_helper.dart'
    if (dart.library.html) '../utils/pdf_web_helper.dart';

class TimetableViewerScreen extends StatefulWidget {
  final String timetableId;
  final String fileUrl;
  final String fileName;

  const TimetableViewerScreen({
    super.key,
    required this.timetableId,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  State<TimetableViewerScreen> createState() => _TimetableViewerScreenState();
}

class _TimetableViewerScreenState extends State<TimetableViewerScreen> {
  bool _isLoading = false;

  bool get _isDataUrl =>
      widget.fileUrl.startsWith('data:application/pdf;base64,');

  bool get _isHttpUrl =>
      widget.fileUrl.startsWith('http://') ||
      widget.fileUrl.startsWith('https://');

  Future<File> _saveBase64PdfToTempFile() async {
    final base64String = widget.fileUrl.replaceFirst(
      'data:application/pdf;base64,',
      '',
    );

    final bytes = base64Decode(base64String);
    final dir = await getTemporaryDirectory();
    final safeName = widget.fileName.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final file = File('${dir.path}/$safeName');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _openPdf() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        openPdfInWeb(widget.fileUrl, widget.fileName);
      } else if (_isDataUrl) {
        final file = await _saveBase64PdfToTempFile();
        final result = await OpenFilex.open(file.path);

        if (!mounted) return;

        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d’ouvrir le PDF: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (_isHttpUrl) {
        final uri = Uri.parse(widget.fileUrl);
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d’ouvrir le PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lien du fichier invalide'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur ouverture PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        downloadPdfInWeb(widget.fileUrl, widget.fileName);
      } else if (_isDataUrl) {
        final file = await _saveBase64PdfToTempFile();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF enregistré: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (_isHttpUrl) {
        final uri = Uri.parse(widget.fileUrl);
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de télécharger le PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lien du fichier invalide'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur téléchargement PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Emploi du temps'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          size: 40,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.fileName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Consultez ou téléchargez votre fichier PDF.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _openPdf,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.open_in_new),
                          label: const Text(
                            'Ouvrir le PDF',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _downloadPdf,
                          icon: const Icon(Icons.download),
                          label: const Text(
                            'Télécharger',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            side: const BorderSide(
                              color: Color(0xFF1565C0),
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}