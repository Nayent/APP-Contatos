import 'dart:io';
import 'package:contatos/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Formulario extends StatefulWidget {
  Contact contact;

  Formulario({this.contact});

  @override
  _FormularioState createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  Contact _editedContact;

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  bool _userEdited = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      nameController.text = _editedContact.name;
      emailController.text = _editedContact.email;
      phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(_editedContact.name ?? "Novo Contato"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_formkey.currentState.validate()) {
                Navigator.pop(context, _editedContact);
              }
            },
            child: Icon(Icons.save),
          ),
          body: SingleChildScrollView(
              child: Form(
            key: _formkey,
            child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : AssetImage("images/person.png"),
                              fit: BoxFit.cover
                        ),
                      ),
                    ),
                    onTap: (){
                      _userEdited = true;
                      ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
                        if(value == null){
                          return;
                        }else{
                          setState(() {
                            _editedContact.img = value.path;
                          });
                        }
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Insira o nome";
                        }
                      },
                      controller: nameController,
                      //keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Nome",
                          labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.name = text;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.email = text;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                          labelText: "Telefone",
                          labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.phone = text;
                      },
                    ),
                  ),
                ]),
          ))),
    );
  }

Future<bool> _requestPop() {
      if (_userEdited) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Descartar alterações?"),
                content: Text("Se sair as alterações serão perdidas."),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar")),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("Continuar")),
                ],
              );
            });
            return Future.value(false);
      }
      else {
        return Future.value(true);
      }
    }

}
