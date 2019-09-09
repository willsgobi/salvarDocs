import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class CadastroDoc extends StatefulWidget {
  @override
  _CadastroDocState createState() => _CadastroDocState();
}

class _CadastroDocState extends State<CadastroDoc> {

  File _pickedImage;

  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _valor = TextEditingController();

  double valor;

  bool isLoading = false;

  @override
  void dispose(){
    super.dispose();
    _title.dispose();
    _description.dispose();
    _valor.dispose();
  }

  Future<File> getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _pickedImage = image;
    });
    return image;
  }

  Future<File> getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = image;
    });
    return image;
  }

  void enviar(BuildContext context) async {

    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(DateTime.now().millisecondsSinceEpoch.toString());
    StorageUploadTask uploadTask =  firebaseStorageRef.putFile(_pickedImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();

    String titulo = _title.text;
    String descricao = _description.text;
    double valor = double.parse(_valor.text);

      await Firestore.instance.collection("documentos")
          .document().setData({"titulo": titulo, "descricao": descricao, "valor": valor, "img": url});

      setState(() {
        isLoading = false;
        Navigator.of(context).pop();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar"),
        centerTitle: true,
      ),
      body: isLoading == true ? Center(child: CircularProgressIndicator(),) : Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _title,
                    validator: (value) {
                      if(value.isEmpty) return "o campo deve ser preenchido";
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: "Digite o titulo"
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _description,
                    validator: (value) {
                      if(value.isEmpty) return "o campo deve ser preenchido";
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.short_text),
                        labelText: "Digite a descrição"
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _valor,
                    validator: (value) {
                      if(value.isEmpty) return "O campo deve ser preenchido";
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.attach_money),
                        labelText: "Digite o valor",
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                      onTap: getImageFromCamera,
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        color: Colors.tealAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.camera_alt),
                            Text("Camera")
                          ],
                        ),
                      ),
                  ),
                      InkWell(
                        onTap: getImageFromGallery,
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          color: Colors.tealAccent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Icon(Icons.photo_library),
                              Text("Galeria")
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: _pickedImage == null ? Text("Selecione uma imagem ou deixe a padrão")
                    : Image.file(_pickedImage),
                  )
                ],
              ),
              SizedBox(height: 15,),
              MaterialButton(
                height: 40,
                elevation: 3,
                hoverElevation: 5,
                color: Colors.teal,
                onPressed: (){
                  enviar(context);
                  setState(() {
                    isLoading = true;
                  });
              },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Enviar", style: TextStyle(color: Colors.white, fontSize: 20),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pop();
        },
        child: Icon(Icons.clear),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
