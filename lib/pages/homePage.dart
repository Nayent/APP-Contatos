import 'dart:io';
import 'package:contatos/helpers/helper.dart';
import 'package:contatos/pages/formulario.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _getAllContact();
  }

  List<Contact> contacts = List();

  ContactHelper helper = ContactHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contatos'),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza,
                ),
              ],
              onSelected: _orderList,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showContactPage();
          },
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _contactCard(context, index);
            }));
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Flexible(
                child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          contacts[index].name,
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis
                        ),
                        Text(
                          contacts[index].email ?? "",
                          style: TextStyle(fontSize: 18.0),
                          overflow: TextOverflow.ellipsis
                        ),
                        Text(
                          contacts[index].phone ?? "",
                          style: TextStyle(fontSize: 18.0),
                          overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ))
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            launch("tel:${contacts[index].phone}");
                          },
                          child: Text(
                            "Ligar",
                            style: TextStyle(fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: FlatButton(
                          onPressed: () {
                            helper.deleteContact(contacts[index].id);
                            setState(() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(fontSize: 20.0),
                          )),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Formulario(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContact();
    }
  }

  void _getAllContact() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      default:
    }
    setState(() {});
  }
}
