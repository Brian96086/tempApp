import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'dart:developer';

import 'package:image_picker/image_picker.dart';
import 'package:loginPage/notes/customPopupMenu.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:loginPage/notes/customPopupMenu.dart' as customPopupMenu;


import 'Notes_util.dart';

class NotesEditPage extends StatefulWidget {
  final Notes n;
  //variable determining if notes is contained in a folder
  final Folder folder;
  NotesEditPage(this.n, this.folder);
  @override
  State<StatefulWidget> createState() => NotesEditPageState();
}

class NotesEditPageState extends State<NotesEditPage> {
  double height, width;
  TextEditingController etText;
  TextEditingController etTitle;
  File photo;
  String tempID="7Hu1bqxiJ1aEICiuGGJKg9AQjU63";
  bool hasTitle;


  
  final firestore = FirebaseFirestore.instance;


  void initState(){
    hasTitle=!widget.n.title.startsWith("New Notes");
    log("hasTitle = "+hasTitle.toString());
    etText=new TextEditingController(text:widget.n.text);
    etTitle=new TextEditingController(text:hasTitle?widget.n.title:null);
  }

  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        //appBar: appBar(),
        resizeToAvoidBottomInset: false,
        appBar: _appBar(),
        body: Body());
  }

  Widget _appBar() {
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(height * 80 / 812),
            child: Container(
                margin: EdgeInsets.only(bottom: height * 0.007),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(),
                    //Container(alignment: Alignment.center, child: Text(widget.n.title, style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18))),
                    TitleWidget(),
                    PopUpButton(),
                  ],
                ))),

    );
  }

  Widget TitleWidget(){
    return Expanded(
      //width:width/2,
      child:TextField(
      controller: etTitle,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18),
      maxLines: null,
      decoration: new InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        //contentPadding:
        //    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        hintText: hasTitle ?widget.n.title: "Add Title",
        hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ));
  }

  Widget BackButton(){
    return IconButton(icon:Icon(Icons.arrow_back),
    onPressed: (){
      //change notes text within storage object as well as cloud firestore
      String updateTitle=(etTitle.text.length==0)?widget.n.title:etTitle.text;
      log("updateTitle length = "+updateTitle.length.toString());
      log("updated title = "+updateTitle);
      setState(() {
        widget.n.text=etText.text;
        widget.n.title=updateTitle;
      });
      if(widget.folder==null){
        firestore.collection("Users").doc(tempID).collection("Notes").doc(widget.n.id).update({"text":etText.text, "title":updateTitle});
      }
      else{
        log("folderName ="+widget.folder.title+" , id = "+widget.n.id+" , title = "+widget.n.title);
        firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").collection(widget.folder.title).doc(widget.n.id).update({"text":etText.text,"title":updateTitle});
      }
      log("current title = "+etTitle.text);
      log(context.toString());
      Navigator.of(context).pop();
    },
    );
  }

  popPage(){
    Navigator.of(context).pop();
  }

  
  Widget PopUpButton() {
    /*return GestureDetector(
      onTapDown: (TapDownDetails details) {
        showPopupMenu(details.globalPosition);
      },
      child: Container(child: Text("Press Me")),
    );*/
    return Container(
      child: CustomPopupMenuButton(
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          icon: Icon(Icons.more_horiz, color: Colors.black),
          itemBuilder: (value) {
            print("value = " + value.toString());
            return <customPopupMenu.PopupMenuEntry>[
              //AddButton(),
              customPopupMenu.CustomPopUpMenuItem(
                  child: SendButton(), value: 'Send'),
              customPopupMenu.CustomPopUpMenuItem(
                  child: DeleteButton(), value: 'Delete'),
              /*new PopupMenuItem<String>(
                child: new Text('Lion'), value: 'Lion'),*/
            ];
          }),
      margin: EdgeInsets.only(right: width / 40),
    );
  }

  Widget SendButton() {
    return GestureDetector(
      child:Container(
        width:width/2.3,
        child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Send to Baby"),
        Container(
          width: width / 15,
          height: height/16,
          child: 
            Icon(
              Icons.photo_album_outlined,
              color: Colors.black,
              size:height/25,
            ),
            //iconSize: height / 30,
          //),
        )
      ]),padding: EdgeInsets.only(left: width / 25),),
      onTap: (){
        log("send button onPressed");
        
      },
    );

  }
  Widget DeleteButton(){
    return GestureDetector(
      child:Container(
        width:width/2.3,
        child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Delete"),
        Container(
          width: width / 15,
          height: height/16,
          child: 
            Icon(
              Icons.photo_album_outlined,
              color: Colors.black,
              size:height/25,
            ),
            //iconSize: height / 30,
          //),
        )
      ]),padding: EdgeInsets.only(left: width / 25),),
      onTap: (){
        log("delete onPressed");
        log(context.toString());
        Navigator.of(context).pop();
        if(widget.folder.title==null){
          firestore.collection("Users"+tempID+"Notes").doc(widget.n.id).delete();
          //widget.folder.deleteNotes(widget.n);
        }else{
          widget.folder.deleteNotes(widget.n);
          Navigator.of(context).pop();
          //log("delete folder "+widget.folder.title+ "and notes title = "+widget.n.title);
          firestore.collection("Users").doc(tempID).collection("Notes").doc("Folders").collection(widget.folder.title).doc(widget.n.id).delete();
          
        }
        
      
      
        
      },
    );
  }

  

  Widget Body() {
    return Container(
      padding: EdgeInsets.only(left:width/30, right:width/30),
      child:Column(
      
        children: [
          photoWidget(),
          Padding(padding: EdgeInsets.only(top:height/70),),
          TextField(
            controller: etText,
            keyboardType: TextInputType.multiline,
            textAlign: TextAlign.start,
            maxLines: null,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              //contentPadding:
              //    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              //hintText: "Add Cover Photo",
              ),
            ),
            ],),
        color: Color(0xF7F7FC));
  }
  Widget photoWidget(){
    
    //return Text("haha");
    if(photo==null){
      return GestureDetector(
        child:
        Container(
          padding: EdgeInsets.only(top:height/40),
        child:Text("Add Cover Photo",style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500,))),
        onTap : (){
          _imgFromCamera();
        },
        
      );
    }
    log("in photo widget, photo = "+photo.toString());
    return Container(
            width: width,
            height:height/3,
            margin: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                image: photo!=null? FileImage(photo):AssetImage('assets/images/profile_pic_1.png'),
              fit: BoxFit.scaleDown,),
            ),
          );
  }

  _imgFromCamera() async {
    PickedFile pImage = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if(pImage!=null){
        photo = File(pImage.path);
      }
    });
    /*await pImage.readAsBytes().then((value) async {
      customImage tempImage=customImage(value);
      String path = await FlutterAbsolutePath.getAbsolutePath(
          tempImage.);
    
      FirebaseStorage.instance.ref("User1" + "User2")
          .child("misc")
          .child("image " + "" + 1.toString())
          .putFile(File(path));
    });
    String path = await FlutterAbsolutePath.getAbsolutePath(
          .path);
    
    FirebaseStorage.instance.ref("User1" + "User2")
          .child("misc")
          .child("image " + "" + 1.toString())
          .putFile(File(path));*/
    
  }

  Future<void> pickImages() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
        //selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Select Photo",
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    setState(() {
    //   String path = await FlutterAbsolutePath.getAbsolutePath(
    //       currAlbum.assetPhotos[i].identifier);
    // FirebaseStorage.instance.ref("User1" + "User2")
    //       .child("misc")
    //       .child("image " + "" + i.toString())
    //       .putFile(File(path));

      /*images = resultList;
      currAlbum.assetPhotos += resultList;
      checkPath();
      log("images = " + images.toString());*/
    });
  }
}
