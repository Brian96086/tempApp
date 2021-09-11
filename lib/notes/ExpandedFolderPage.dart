import 'dart:developer';

import 'package:flutter/material.dart';

import 'NotesEditPage.dart';
import 'Notes_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ExpandedFolderPage extends StatefulWidget {
  final Folder folder;
  ExpandedFolderPage(this.folder);
  @override
  State<StatefulWidget> createState() => ExpandedFolderPageState();
}

class ExpandedFolderPageState extends State<ExpandedFolderPage> {
  

  double height, width;
  bool loaded=false;
  final firestore = FirebaseFirestore.instance;
  String tempID="7Hu1bqxiJ1aEICiuGGJKg9AQjU63";




  Widget build(BuildContext context){

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    


    return Scaffold(
        backgroundColor: Colors.white,
        //appBar: appBar(),
        resizeToAvoidBottomInset: false,
        appBar: _appBar(),
        floatingActionButton: AddButton(),
        body: Body());

  }

  Widget Body(){
    return ListView(children:NotesBloc());
  }

  Widget _appBar() {
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(height * 80 / 1000),
            child: Container(
                //margin: EdgeInsets.only(bottom: height * 0.007),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BackButton(),
                    Container(alignment: Alignment.center, child: Text(widget.folder.title, style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18))),
                    Container(width: width/20,),
                  ],
                ))),

    );
  }

  Widget BackButton(){
    return IconButton(icon:Icon(Icons.arrow_back),
    onPressed: (){
      Navigator.of(context).pop();
    },
    );
  }

  Widget AddButton(){
    return FloatingActionButton(child:Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.red,
      onPressed: (){
        log("button pressed");
        String currTime=DateTime.now().toString().substring(0,19);
        Map<String, dynamic> tempData = {"title":"New Notes "+widget.folder.count().toString(), "text":"", "id":currTime,"hasPhoto":false};
        Notes newNote=Notes.fromNotes(tempData);
        //add notes to frontend storage and backend firestore
        widget.folder.addNotes(newNote);
        firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").collection(widget.folder.title).doc(currTime).set(tempData);
        
        Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context){
                return NotesEditPage(newNote,widget.folder);
        })).then((value){
          setState(() {});
        });
        log("navigate to edit page");
      },);
  }

  List<Widget> NotesBloc() {
    log("notes number = " + widget.folder.notes_list.length.toString());

    if (widget.folder.notes_list.length == 0) {
      // return ListView();
      return [Container() as Widget];
    }
    List<Widget> notesTiles = new List<Widget>();

    for (int i = 0; i < widget.folder.notes_list.length-1; i += 2) {
      List<Widget> rowContent = List<Widget>();
      for (int j = 0; j < 2; j++) {
        rowContent.add(SingleNotesUI(widget.folder.notes_list[i+j]));     
      }
      notesTiles.add(Container(
        child: Row(
          children: rowContent,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        padding: EdgeInsets.only(left: width * 0.0533, right: width * 0.0533),
      ));
    }
    if ((widget.folder.notes_list.length) % 2 == 1) {
      int index=widget.folder.notes_list.length-1;
      notesTiles.add(Row(children:[Container(child:SingleNotesUI(widget.folder.notes_list[index]),padding: EdgeInsets.only(left: width * 0.0533))]));
    }
    //hasChanged = false;
    /*return ListView(
      children: notesTiles,
    );*/
    return notesTiles;
  }

  Widget SingleNotesUI(Notes n){
    return GestureDetector(
      child:Container(child: 
      Column(children: [
        Padding(padding:EdgeInsets.only(top:height/60)),
        Text(n.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        Padding(padding: EdgeInsets.only(bottom: height/50),),
        Text(n.text, maxLines: 9,),
      ],),
      color: Colors.grey[100],
      height: height/3,
      width: width*0.43,
      margin: EdgeInsets.only(bottom: height/70),
      padding: EdgeInsets.only(left:width/70, right:width/70),
    ),onTap:(){
      Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context){
                return NotesEditPage(n,widget.folder);
      })).then((value) => setState(() {}));
    });
  }
}