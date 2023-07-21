import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class CreateQrCode extends StatefulWidget {
  final String? textQrCode,op1,op2,op3,op4;
  const CreateQrCode({Key? key,this.textQrCode,this.op1,this.op2,this.op3,this.op4}) : super(key: key);

  @override
  State<CreateQrCode> createState() => _CreateQrCodeState();
}

class _CreateQrCodeState extends State<CreateQrCode> {
  final GlobalKey globalKey = GlobalKey();

  Future<void> converQrCodeToImage() async{
    RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile  = File("$directory/qrCode.png");
    await imgFile.writeAsBytes(pngBytes);
    await Share.shareFiles([imgFile.path],text:"Your text share");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share your Poll"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15,right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: RepaintBoundary(
                  key: globalKey,
                  child: QrImageView(
                    data: "${widget.textQrCode},\n${widget.op1},\n${widget.op2},\n${widget.op3},\n${widget.op4}",
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    gapless: true,
                    errorStateBuilder: (cxt, err){
                      return const Center(
                        child: Text("Error"),
                      );
                    },
                  ),
                )
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => converQrCodeToImage(),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1
                    )
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_outlined, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 10),
                      Text("Convert qr code to image and Share",style: TextStyle(
                          color: Theme.of(context).primaryColor
                      ),)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class QRhome extends StatefulWidget {
  const QRhome({Key? key}) : super(key: key);

  @override
  State<QRhome> createState() => _QRhomeState();
}

class _QRhomeState extends State<QRhome> {
  final TextEditingController textQr = TextEditingController();
  String textQrCodeScan = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Generate qr code and share"),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.text,
                controller: textQr,
                cursorColor: Theme.of(context).primaryColor,
                decoration: const InputDecoration(
                  hintText: "Enter text",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(
                      CupertinoPageRoute(builder: (BuildContext context)=>
                          CreateQrCode(textQrCode: textQr.text.trim())));
                },
                child: Container(
                  height: 50,
                  color: Theme.of(context).primaryColor,
                  child: const Center(
                    child: Text("Generate",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if(textQrCodeScan.isNotEmpty)
                Center(
                  child: Text(textQrCodeScan,
                    style:const TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),
                  ),
                )
            ],
          ),
        )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}