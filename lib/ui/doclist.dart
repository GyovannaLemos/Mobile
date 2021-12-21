import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ftt_docexpireapp/ui/docdetail.dart';
import 'package:ftt_docexpireapp/util/dbhelper.dart';

import '../model/model.dart';
// import '../util/dphelper.dart';
import '../util/utils.dart';
//import '../docdetail.dart';

const menuReset = "Reset Local Data";
List<String> menuOptions = const <String>[menuReset];

class DocList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DocListState();
}

class DocListState extends State<DocList> {
  DbHelper dbh = DbHelper();
  late List<Doc> docs;
  int count = 0;
  late DateTime cDate;

  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      final docsFuture = dbh.getDocs();
      docsFuture.then((result) {
        if (result.length >= 0) {
          //List<Doc> docList = List<Doc>();
          List<Doc> docList = [];
          var count = result.length;
          for (int i = 0; i <= count - 1; i++) {
            docList.add(Doc.fromObject(result[i]));
          }
          setState(() {
            if (this.docs.length > 0) {
              this.docs.clear();
            }
            this.docs = docList;
            this.count = count;
          });
        }
      });
    });
  }

  void _checkDate() {
    const secs = const Duration(seconds: 10);

    new Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();

      if (cDate.day != nw.day ||
          cDate.month != nw.month ||
          cDate.year != nw.year) {
        getData();
        cDate = DateTime.now();
      }
    });
  }

  void navigateToDetail(Doc doc) async {
    bool r = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DocDetail(doc)));

    if (r == true) {
      getData();
    }
  }

  void _showResetDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Reset"),
            content: new Text("Do you want to delete all local data?"),
            //actions espera um array de widgets
            actions: <Widget>[
              TextButton(
                // child só aceita um objeto - children aceita vários objetos
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: new Text("OK"),
                onPressed: () {
                  Future f = _resetLocalData();

                  f.then((result) {
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        });
  }

  Future _resetLocalData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      final dDocs = dbh.deleteRows(DbHelper.tblDocs);
      dDocs.then((result) {
        setState(() {
          this.docs.cast();
          this.count = 0;
        });
      });
    });
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuReset:
        _showResetDialog();
    }
  }

  ListView docListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        String dd = Val.GetExpireStr(this.docs[position].expiration);
        String dl = (dd != "1") ? " days left" : " day left";
        return Card(
            color: Colors.white,
            elevation: 1.0,
            child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      (Val.GetExpireStr(this.docs[position].expiration) != "0")
                          ? Colors.blue
                          : Colors.red,
                  child: Text(
                    this.docs[position].id.toString(),
                  ),
                ),
                title: Text(this.docs[position].title),
                subtitle: Text(
                    Val.GetExpireStr(this.docs[position].expiration) +
                        dl +
                        "\nExp: " +
                        DateUtilsDD.convertToDateFull(
                            this.docs[position].expiration)),
                onTap: () {
                  navigateToDetail(this.docs[position]);
                }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    this.cDate = DateTime.now();

    if (this.docs == null) {
      List<Doc> doclist = [];
      this.docs = doclist;
      getData();
    }

    _checkDate();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("DocExpire"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _selectMenu,
            itemBuilder: (BuildContext context) {
              return menuOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Center(
        child: Scaffold(
          body: Stack(children: <Widget>[
            docListItems(),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigateToDetail(Doc.withId(-1, "", "", 1, 1, 1, 1));
            },
            tooltip: "Add new doc",
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
