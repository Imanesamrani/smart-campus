import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

void openPdfInWeb(String fileUrl, String fileName) {
  if (fileUrl.startsWith('data:application/pdf;base64,')) {
    final base64String =
        fileUrl.replaceFirst('data:application/pdf;base64,', '');
    final bytes = base64Decode(base64String);
    final uint8List = Uint8List.fromList(bytes);

    final blob = html.Blob([uint8List], 'application/pdf');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    html.window.open(objectUrl, '_blank');
    return;
  }

  html.window.open(fileUrl, '_blank');
}

void downloadPdfInWeb(String fileUrl, String fileName) {
  String downloadUrl = fileUrl;

  if (fileUrl.startsWith('data:application/pdf;base64,')) {
    final base64String =
        fileUrl.replaceFirst('data:application/pdf;base64,', '');
    final bytes = base64Decode(base64String);
    final uint8List = Uint8List.fromList(bytes);

    final blob = html.Blob([uint8List], 'application/pdf');
    downloadUrl = html.Url.createObjectUrlFromBlob(blob);
  }

  final anchor = html.AnchorElement(href: downloadUrl)
    ..target = '_blank'
    ..download = fileName;
  anchor.click();
}