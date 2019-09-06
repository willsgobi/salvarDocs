import 'package:flutter/material.dart';
import 'package:salvedoc/cadastro_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Meus Documentos"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CadastroDoc()));
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection("documentos").snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return DocList(snapshot.data.documents[index].data);
                        },
                      );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DocList extends StatelessWidget {
  final Map<String, dynamic> data;

  DocList(this.data);

  @override
  Widget build(BuildContext context) {
    return
        Card(
          child: Column(
            children: <Widget>[
              Container(child: Image.network(data["img"].toString())),
              SizedBox(
                height: 10,
              ),
              Text(
                data["titulo"],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(data["descricao"]),
              SizedBox(
                height: 10,
              ),
              Text(
                "R\$ " + data["valor"].toStringAsFixed(2),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              )
          ]
          ),
        );}
}
