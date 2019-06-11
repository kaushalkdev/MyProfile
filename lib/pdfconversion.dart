import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as Pdf;
import 'package:printing/printing.dart';

class Conversion extends StatelessWidget {
  String name='kaushal';

  String email = 'kaushal.deligence@gmail.com';
  String address =
      ' 106 & 107, 1st Floor, Jyoti Shikhar Tower,District Center, Janakpuri';

  List<int> buildPdf(PdfPageFormat format) {
    final PdfDoc pdf = PdfDoc()
      ..addPage(Pdf.MultiPage(
          pageFormat: PdfPageFormat.letter
              .copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: Pdf.CrossAxisAlignment.start,
          footer: (Pdf.Context context) {
            return Pdf.Container(
                alignment: Pdf.Alignment.centerRight,
                margin: const Pdf.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: Pdf.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: Pdf.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          build: (Pdf.Context context) => <Pdf.Widget>[
                Pdf.Header(
                    level: 0,
                    child: Pdf.Row(
                        mainAxisAlignment: Pdf.MainAxisAlignment.center,
                        children: <Pdf.Widget>[
                          Pdf.Text('Resume', textScaleFactor: 2),
                        ])),

                Pdf.Paragraph(text: ''),
                Pdf.Column(children: <Pdf.Widget>[
                  //bio start
                  Pdf.Row(children: <Pdf.Widget>[
                    Pdf.Text('Name: ',
                        style: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                    Pdf.Text(name),
                  ]),
                  Pdf.Row(children: <Pdf.Widget>[
                    Pdf.Text('Email: ',
                        style: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                    Pdf.Text(email),
                  ]),
                  Pdf.Row(children: <Pdf.Widget>[
                    Pdf.Paragraph(
                        text: 'Address: ',
                        style: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                    Pdf.Paragraph(text: address),
                  ]),
                  //bio end
                ]),

                // Educational details
                Pdf.Header(level: 1, text: 'Profile'),
                Pdf.Paragraph(
                    text:
                        'I am a full stack Software Developer and develops Mobile applications. Have experience in app designing with Fultter and Android Studio.'),

                Pdf.Header(level: 1, text: 'Education Details'),

                Pdf.Header(
                    level: 3,
                    text: 'Higher Secondary',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Institution: Kv.No.1 Delhi Cantt'),
                Pdf.Bullet(text: 'Field of Study: Science'),
                Pdf.Bullet(text: 'Year: 2011 - 2012'),

                Pdf.Header(
                    level: 3,
                    text: 'Senior Secondary',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Institution: Kv.No.1 Delhi Cantt'),
                Pdf.Bullet(text: 'Field of Study: PCM'),
                Pdf.Bullet(text: 'Year: 2013 - 2014'),

                Pdf.Header(
                    level: 3,
                    text: 'B.Tech',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(
                    text:
                        'Institution: Maharaja Surajmal Institute of Technology'),
                Pdf.Bullet(text: 'Field of Study: ECE'),
                Pdf.Bullet(text: 'Year: 2014 - 2018'),
                Pdf.Paragraph(text: ''),

                //project details
                Pdf.Header(level: 1, text: 'Project Details'),

                Pdf.Header(
                    level: 3,
                    text: 'MYProfile App',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Deligence Technologies'),
                Pdf.Bullet(text: '19/05/2019 - 10/06/2019'),
                Pdf.Bullet(
                    text:
                        'Description: The App helps in creating profile for users which they can share in form of Pdf. '),
                Pdf.Header(
                    level: 3,
                    text: 'TextToSpeech Chat App',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Deligence Technologies'),
                Pdf.Bullet(text: '15/03/2019 - 26/03/2019'),
                Pdf.Bullet(
                    text:
                        'Description: The App is simple chat app with speech out. User can send message to each other and can read as well as hear the messge. '),

                //professional detials
                Pdf.Header(level: 1, text: 'Professional Experience'),

                Pdf.Header(
                    level: 3,
                    text: 'Software Developer',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Deligence Technologies'),
                Pdf.Bullet(text: 'Mar 2019 - present'),
                Pdf.Bullet(
                    text:
                        'Description: The comapny mainly deals with developement of web aps and android and ios developement.'),
              ]));

    return pdf.save();
  }



  @override
  Widget build(BuildContext context) {
    Printing.layoutPdf(onLayout: buildPdf);

    return Container();
  }
}
