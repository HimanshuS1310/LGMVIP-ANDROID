import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:lgmtask2/widgets/facepainter.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  List<Face>? _faces;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'LGM Face Detector',
            style: GoogleFonts.play(),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: Text(
                        "About Face Detector",
                        style: GoogleFonts.play(),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Lets Grow More Task.\nThis App Identify the number of faces in an Image. You can choose image from gallery or take the image instantly from camera.",
                              style: GoogleFonts.play()),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copyright),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Developed by:\nHimanshu Sharma",
                                  style: GoogleFonts.play()),
                            ],
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: Text("Close"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(CupertinoIcons.info))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: "btn1",
              onPressed: () => _getImage(ImageSource.camera),
              label: Row(
                children: [
                  Icon(Icons.add_a_photo),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Camera",
                    style: GoogleFonts.play(),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            FloatingActionButton.extended(
              heroTag: "btn2",
              onPressed: () => _getImage(ImageSource.gallery),
              label: Row(
                children: [
                  Icon(Icons.image),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Gallery",
                    style: GoogleFonts.play(),
                  )
                ],
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (_imageFile == null)
                ? Center(
                    child: Container(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/face.png",
                          height: 250,
                          width: 250,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Select or Capture a Picture.',
                          style: GoogleFonts.play(fontSize: 20),
                        ),
                      ],
                    ),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 1.8,
                          child: Center(
                              child: FittedBox(
                            child: SizedBox(
                              width: _image!.width.toDouble(),
                              height: _image!.height.toDouble(),
                              child: CustomPaint(
                                painter: FacePainter(_image!, _faces!),
                              ),
                            ),
                          )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          child: Text(
                            _faces!.length == 1
                                ? _faces!.length.toString() + " Face Found"
                                : _faces!.length.toString() + " Faces Found",
                            style: GoogleFonts.play(
                                color: Colors.white, fontSize: 25),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ));
  }

  _getImage(ImageSource source) async {
    final imageFile = await picker.pickImage(source: source);
    setState(() {
      isLoading = true;
    });

    final image = GoogleVisionImage.fromFile(File(imageFile!.path));
    final faceDetector = GoogleVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);

    if (mounted) {
      setState(() {
        _imageFile = File(imageFile.path);
        _faces = faces;
        _loadImage(File(imageFile.path));
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
  }
}
