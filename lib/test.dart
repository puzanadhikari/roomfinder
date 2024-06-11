import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class PDFViewerPage extends StatelessWidget {
  final String pdfFilePath;

  PDFViewerPage({required this.pdfFilePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: kThemeColor,
      ),
      body: PDFView(
        filePath: pdfFilePath,
        onPageChanged: (int? currentPage,int?totalPage) {
         log(currentPage.toString()+"a::::::::::::::::::"+totalPage.toString());
        },
      ),
    );
  }
}
