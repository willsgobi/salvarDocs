import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  String imagem;

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

  void enviarPic() async{
    final FirebaseStorage storage = FirebaseStorage(storageBucket: 'gs://salvardocs-65f5b.appspot.com');
    StorageUploadTask task = storage.ref().child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(_pickedImage);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      imagem = url;
    });
    enviar();
  }

  void enviar() async {
//    enviarPic();
    String titulo = _title.text;
    String descricao = _description.text;
    double valor = double.parse(_valor.text);

    if(_formKey.currentState.validate()){
      await Firestore.instance.collection("documentos")
          .document().setData({"titulo": titulo, "descricao": descricao, "valor": valor, "img": imagem});
      setState(() {
        _description.text = "";
        _title.text = "";
        _valor.text = "";
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(25.0),
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
              MaterialButton(
                onPressed: (){
                  _pickedImage.delete();
                  _title.text = "";
                  _description.text = "";
                  _valor.text = "";
                },
                child: Text("Limpar"),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: enviarPic,
        child: Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
