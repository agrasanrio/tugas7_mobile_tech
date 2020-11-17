import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Mhs>> fetchMhss(http.Client client) async {
  final response = await client
      .get('https://fluttermobiletech.000webhostapp.com/readDatajson.php');

  // Use the compute function to run parseMhss in a separate isolate.
  return compute(parseMhss, response.body);
}

// A function that converts a response body into a List<Mhs>.
List<Mhs> parseMhss(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Mhs>((json) => Mhs.fromJson(json)).toList();
}

void deleteData(String nim) {
  var url = "https://fluttermobiletech.000webhostapp.com/deleteData.php";
  http.post(url, body: {
    'nim': nim,
  });
}

class Mhs {
  final String nim;
  final String nama;
  final String kelas;
  final String kdmatkul;
  final String email;

  Mhs({this.nim, this.nama, this.kelas, this.kdmatkul, this.email});

  factory Mhs.fromJson(Map<String, dynamic> json) {
    return Mhs(
      nim: json['nim'] as String,
      nama: json['nama'] as String,
      kelas: json['kelas'] as String,
      kdmatkul: json['kdmatkul'] as String,
      email: json['email'] as String,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Data Mahasiswa';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: appTitle),
        '/second': (context) => EditData(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Mhs>>(
        future: fetchMhss(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? MhssList(mhsData: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MhssList extends StatefulWidget {
  final List<Mhs> mhsData;

  MhssList({Key key, this.mhsData}) : super(key: key);

  @override
  _MhssListState createState() => _MhssListState();
}

class _MhssListState extends State<MhssList> {
  _getRequests() async {}
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: widget.mhsData.length,
      itemBuilder: (context, index) {
        return viewData(widget.mhsData, index, context);
      },
    );
  }

  Widget viewData(var data, int index, BuildContext context) {
    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.green,
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //ClipRRect(
            //      borderRadius: BorderRadius.only(
            //      topLeft: Radius.circular(8.0),
            //    topRight: Radius.circular(8.0),
            // ),
            // child: Image.network(
            //    "https://elearning.binadarma.ac.id/pluginfile.php/1/theme_lambda/logo/1602057627/ubd_logo.png"
            //    width: 100,
            //   height: 50,
            //fit:BoxFit.fill

            // ),
            // ),

            ListTile(
              //leading: Image.network(
              //   "https://elearning.binadarma.ac.id/pluginfile.php/1/theme_lambda/logo/1602057627/ubd_logo.png",
              // ),
              title:
                  Text(data[index].nim, style: TextStyle(color: Colors.white)),
              subtitle:
                  Text(data[index].nama, style: TextStyle(color: Colors.white)),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('Edit',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/second',
                          arguments: Mhs(
                            nim: data[index].nim,
                            nama: data[index].nama,
                            kelas: data[index].kelas,
                            kdmatkul: data[index].kdmatkul,
                            email: data[index].email,
                          ));
                    },
                  ),
                  FlatButton(
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      deleteData(data[index].nim);
                      setState(() {
                        widget.mhsData.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditData extends StatefulWidget {
  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  TextEditingController nimController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController kelasController = TextEditingController();
  TextEditingController kdmatkulController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String nim;

  @override
  void didChangeDependencies() {
    final Mhs data = ModalRoute.of(context).settings.arguments;
    nim = data.nim;
    nimController = new TextEditingController(text: data.nim);
    namaController = new TextEditingController(text: data.nama);
    kelasController = new TextEditingController(text: data.kelas);
    kdmatkulController = new TextEditingController(text: data.kdmatkul);
    emailController = new TextEditingController(text: data.email);
    super.didChangeDependencies();
  }

  void editData() async {
    var url = "https://fluttermobiletech.000webhostapp.com/editData.php";
    await http.post(url, body: {
      "nimA": nim,
      "nimB": nimController.text,
      "nama": namaController.text,
      "kelas": kelasController.text,
      "kdmatkul": kdmatkulController.text,
      "email": emailController.text
    });
  }

  Widget _editForm(TextEditingController controller, String label) {
    return Container(
        margin: EdgeInsets.all(20),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: label,
          ),
        ));
  }

  Widget _submit() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        onPressed: () {
          // Validate will return true if the form is valid, or false if
          // the form is invalid.
          if ((nimController.text.isEmpty) ||
              (namaController.text.isEmpty) ||
              (kelasController.text.isEmpty) ||
              (kdmatkulController.text.isEmpty) ||
              (emailController.text.isEmpty)) {
            print("Tidak boleh kosong");

            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thanks!'),
                  content: Text('Tidak boleh kosong'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            editData();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          }

          ///end if
        },
        child: Text('Submit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Edit Data Mahasiswa'),
          ),
          body: Center(
              child: Column(children: <Widget>[
            _editForm(nimController, 'NIM'),
            _editForm(namaController, 'Nama'),
            _editForm(kelasController, 'Kelas'),
            _editForm(kdmatkulController, 'Kdmatkul'),
            _editForm(emailController, 'Email'),
            _submit(),
          ])),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Close',
            child: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    );
  }
}