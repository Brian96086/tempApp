import 'dart:developer';

import 'package:flutter/material.dart';


import 'ExpandedFolderPage.dart';
import 'NotesEditPage.dart';
import 'Notes_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';




class NotesHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotesHomePageState();
}

class NotesHomePageState extends State<NotesHomePage> {
  double height,width;
  bool loaded=false;
  String temp="initial";
  List iconPathList=['assets/images/heart.png','assets/images/bucketlist.png','assets/images/random.png']; 
  TextEditingController etName = new TextEditingController();
  List<Notes> notesList=[];
  List<Folder> folderList=[];
  NotesStorage storage;

  final firestore = FirebaseFirestore.instance;
  String tempID="7Hu1bqxiJ1aEICiuGGJKg9AQjU63";

  void initState(){
    super.initState();
    storage=new NotesStorage(folderList, notesList);
    getAllData().then((value){
      setState(() {
        loaded=true;
        log("set state");
      });
    });
    
    
    /*DocumentReference events=firestore.collection("Users").doc(tempID).collection("Normal_Events").doc("Zn2mQ7bYOzcf0CRfBHYV");
    events.get().then((value) => log(value.data().toString()));*/
    /*Map<String, dynamic> temp_dict={"title":"Summer 2021", "text":"Today is a sunny day. \n First written notes haha"};
    firestore.collection("Users").doc(tempID).collection("Notes").doc("0101notes").set(temp_dict);
    temp_dict={"title":"Spring 2021","text":"first love notes"};
    firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").collection("Love Letters").doc("notes0103").set(temp_dict);*/
    log("finished initState");
  }

  Future getAllData() async {
    await firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").get().then((value) {
      List<dynamic>folderNames = value.data()["names"];
      log(folderNames.toString());
      DocumentReference tempRef=firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders");
      //iterate through folderNames and get references
      folderNames.forEach((fName) {
        Folder f=Folder([], fName);
        //iterate through notes within a folder
        tempRef.collection(fName).get().then((notesRef) {
          f.initCount=notesRef.size;
          notesRef.docs.forEach((notes) {
            Notes n = Notes.fromNotes(notes.data());
            log("notes data = "+notes.data().toString());
            f.addNotes(n);

          });
        });
        setState(() {
          storage.addFolder(f);
        });
        log("curr folder size  = "+storage.folderStorage.length.toString());
      });
    });
    log("finished downloading folders");
    return firestore.collection("Users").doc(tempID).collection("Notes").get().then((value){
      
      value.docs.forEach((element) {
        if (element.id!="Folders"){
          storage.notesStorage.add(Notes.fromNotes(element.data()));
          log("(id, count) = ("+element.id+" , "+ storage.notesStorage.length.toString()+" )");
        }
      });
    });
    /*storage=new NotesStorage(folderList, notesList);
    storage.notesStorage.add(Notes.fromNotes({"title":"Notes1", "text":"Sunny Day"}));
    String tempText="";
    for(int i=0;i<50;i++){
      tempText+="Rainy ";
    }
    storage.notesStorage.add(Notes.fromNotes({"title":"Notes2", "text":tempText}));
    storage.notesStorage.add(Notes.fromNotes({"title":"Notes3", "text":"Cloudy Day"}));*/

  }

  void add_notes_callback(){
    String currTime= DateTime.now().toString().substring(0, 19);
    Map<String, dynamic> newData= {"title":"New Notes "+(storage.notesStorage.length+1).toString(), "text":"", "id":currTime, "hasPhoto":false};
    Notes n =Notes.fromNotes(newData);
    storage.addNotes(n);
    firestore.collection("Users").doc(tempID).collection("Notes").doc(currTime).set(newData);
    
    
    Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context){
              return NotesEditPage(n,null);
    })).then((value) {
      setState(() {});
    });
  }

  void add_folder_callback(){
    setState(() {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return NewFolderBox();
      });
    });
  }

  Widget build(BuildContext context){

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        //appBar: appBar(),
        resizeToAvoidBottomInset: false,
        body: Body(),
        floatingActionButton: CircularButton(icon: Icons.add,notes_callback: this.add_notes_callback,folder_callBack: this.add_folder_callback,),);
  }
  // Widget CircularButton(){
  //   return FloatingActionButton(child:Icon(Icons.add));
  // }

  Widget Body(){
    return ListView(children:[Container(child:
        Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Padding(padding: EdgeInsets.only(top:height/10)),
            Text("Folders",style:TextStyle(color: Colors.grey, fontWeight:FontWeight.w500)),
            Padding(padding: EdgeInsets.only(top:height/60)),
            FolderView(),
            Padding(padding: EdgeInsets.only(top:height/60)),
            Text("Notes",style:TextStyle(color: Colors.grey,fontWeight:FontWeight.w500)),
        ]),
      padding: EdgeInsets.only(left:width*21/375, right:width*18/375),
      ) as Widget]+(loaded?BottomNotes():[Container(height: height/3,)]),
    );
    /*
    return FutureBuilder(
      future: getAllData(),
      builder: (_, __){
        log("state = "+__.connectionState.toString()+" , folder num = "+storage.notesStorage.length.toString());
        return ListView(children:[Container(child:
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Padding(padding: EdgeInsets.only(top:height/10)),
              Text("Folders",style:TextStyle(color: Colors.grey, fontWeight:FontWeight.w500)),
              Padding(padding: EdgeInsets.only(top:height/60)),
              FolderView(),
              Padding(padding: EdgeInsets.only(top:height/60)),
              Text("Notes",style:TextStyle(color: Colors.grey,fontWeight:FontWeight.w500)),
          ]),
        padding: EdgeInsets.only(left:width*21/375, right:width*18/375),
        ) as Widget]+(__.connectionState==ConnectionState.done?BottomNotes(__.connectionState):[Container(height: height/3,)]),
      );
      });*/


  }

  Widget FolderView(){
    return Container(
      
      height:height/5,
      child:ListView(scrollDirection: Axis.horizontal,
        children: FolderSource(),
    ));
  }
  List<Widget> FolderSource(){
    List<Widget> folders=List();
    
    for(int i=0;i<storage.folderStorage.length;i++){
      folders.add(FolderBloc(iconPathList[i%3], storage.folderStorage[i]));
    }
    return folders;
  }

  Widget FolderBloc(String iconPath, Folder f){
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context){
                return ExpandedFolderPage(f);
        })).then((value) => setState(() {}));
      },
      child:Column(children:[
        Container(child:
        Stack(alignment: Alignment.center,children:[
          Align(child:FolderImage()),
          //Positioned(child:FolderIcon(),left:width*90/750,top: height*95/1300),
          
          Align(child:FolderIcon(iconPath)),
        
        ])),
        Container(child:Text(f.title, style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28),),padding: EdgeInsets.only(top:height/100),),
        Text(f.count().toString()+" notes", style: TextStyle(color: Colors.grey),)
      ]));
  }

  Widget FolderIcon(String iconPath){
    return Container(child:
    // ImageIcon(
    //   AssetImage("assets/images/heart.png"),
    // )
    Tab(icon: Container(
          child: Image(
            image: AssetImage(
              iconPath,
            ),
            fit: BoxFit.cover,
          ),
          height: width/25,
          width: width/25,
          margin: EdgeInsets.only(top:height/120),
        ))
    );
  }

  Widget FolderImage(){
    return Container(
              width: width*105/375,
              height:height*95/812,
              decoration: BoxDecoration(
                //color: Colors.yellow,
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: AssetImage('assets/images/folder.png'),
                fit: BoxFit.scaleDown,),
              ),
            );
  }


  Widget NewFolderBox(){

    return Container(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: FolderDialog(),
        insetPadding: EdgeInsets.all(10),
      ),
    );
  }

  Widget FolderDialog() {

    return Container(
        height: height / 3,
        width: width * 0.9,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(children: [
          Container(
            child: Text("Create New Folder",
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w700,
                    fontSize: height / 40)),
            padding: EdgeInsets.only(bottom: height / 40, top: height / 20),
          ),
          AlbumNameTextBox(),
          SaveButton(),
        ]));
  }

  Widget SaveButton() {
    return Container(
      margin: EdgeInsets.only(top: height / 50),
      decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: FlatButton(
        child: Text(
          "Save",
          style: TextStyle(color: Colors.grey[100]),
        ),
        onPressed: () {
          setState(() {
            //add to frontend storage
            storage.addFolder(Folder([], etName.text));
            log("current length = "+storage.folderStorage.length.toString());
            String currTime=DateTime.now().toString().substring(0,19);
            //add folder object to backend firestore
            firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").collection(etName.text).doc(currTime).set(emptyNotes(currTime));
            //add folder name to Folder documents' field(names)
            firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").get().then((value){
              List tempList=value.data()["names"];
              tempList.add(etName.text);
              log("list = "+tempList.toString());
              firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").update({"names":tempList});
            });
            
            Navigator.of(context).pop();
          });
        },
      ),
      height: height / 17, width: width / 4.2,
      //padding: EdgeInsets.only(top:height/20),
    );
  }

  Map<String, dynamic> emptyNotes(String currTime){
    return {"title":"New Notes","text":"", "id":currTime};
  }

  Widget AlbumNameTextBox() {
    return Container(
      child: TextFormField(
          textAlign: TextAlign.center,
          controller: etName,
          decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintStyle: TextStyle(fontWeight: FontWeight.bold))),
      decoration: BoxDecoration(
          color: Colors.brown[100],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      padding: EdgeInsets.only(top: height / 50, bottom: height / 50),
      width: width * 0.7,
    );
  }

  List<Widget> BottomNotes() {
    log("notes number = " + storage.notesStorage.length.toString());

    if (storage.notesStorage.length == 0) {
      // return ListView();
      return [Container() as Widget];
    }
    List<Widget> notesTiles = new List<Widget>();

    for (int i = 0; i < storage.notesStorage.length-1; i += 2) {
      List<Widget> rowContent = List<Widget>();
      for (int j = 0; j < 2; j++) {
        rowContent.add(SingleNotesUI(storage.notesStorage[i+j]));     
      }
      notesTiles.add(Container(
        child: Row(
          children: rowContent,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        padding: EdgeInsets.only(left: width * 0.0533, right: width * 0.0533),
      ));
    }
    if ((storage.notesStorage.length) % 2 == 1) {
      int index=storage.notesStorage.length-1;
      notesTiles.add(Row(children:[Container(child:SingleNotesUI(storage.notesStorage[index]),padding: EdgeInsets.only(left: width * 0.0533))]));
    }
    //hasChanged = false;
    /*return ListView(
      children: notesTiles,
    );*/
    return notesTiles;
  }

  Widget SingleNotesUI(Notes n){
    bool isSample=n.title=="Summer 2021!";
    return GestureDetector(
      child:Container(child: 
      Column(children: [
        Padding(padding:EdgeInsets.only(top:height/60)),
        Text(n.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        Padding(padding: EdgeInsets.only(bottom: height/50),),
        ImageBloc(n),
        Text(n.text, maxLines: isSample?3:9,),
      ],),
      height: height/3,
      width: width*0.43,
      margin: EdgeInsets.only(bottom: height/70),
      padding: EdgeInsets.only(left:width/70, right:width/70),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15.0)),color: Color(0xFFF7F7FC),
      )),onTap:(){
      
        Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context){
                return NotesEditPage(n, null);
        })).then((value){
          setState(() {
            log("from EDIT back to HOME");
          });
        });
        
      
    });
  }

  Widget ImageBloc(Notes n){
    if(n.title!="Summer 2021!"){
      return Container();
    }
    
    return Container(
            width: width*0.43,height:height/7,
            margin: EdgeInsets.only(bottom:height/50),
            decoration: BoxDecoration(
              
              image: DecorationImage(
                image: AssetImage('assets/images/sampleCoverPhoto.png'),
              fit: BoxFit.fill,),
            ),
          );
  }

}

