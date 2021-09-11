import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';

class Notes{
  String title="";
  String text="";
  String id;
  bool hasImage=false;
  File coverPhoto;

  getTitle()=> title;
  getText() => text;
  getCoverPhoto()=> coverPhoto;

  Notes.fromNotes(Map d){
    this.title=d["title"];
    this.text=d["text"];
    this.id=d["id"];
    if(!d.keys.contains("hasPhoto")){
      coverPhoto=null;
    }
  }

  setTitle(String title){
    this.title=title;
  }
  setText(String text){
    this.text=text;
  }
  setImage(File coverPhoto){
    if(coverPhoto!=null){
      this.coverPhoto=coverPhoto;
      this.hasImage=true;
    }else{
      this.coverPhoto=null;
      this.hasImage=false;
    }
  }

  getNotes(){
    return {"title":title, "text":text, "hasImage":hasImage, "coverPhoto":coverPhoto.readAsBytes()};
  }

  toString(){
    return "title = "+this.title+" , main text = "+(text.length>25?text:text.substring(0,25));
  }

  Notes(this.title, this.text, this.hasImage,this.coverPhoto,);
}

class Folder{
  List<Notes> notes_list=[];
  String title;
  Folder(this.notes_list, this.title);
  int initCount=0;

  addNotes(Notes n){
    return notes_list.add(n);
    
  }

  bool deleteNotes(Notes n){
    return notes_list.remove(n);
  }

  count(){
    return (initCount>notes_list.length)?initCount:notes_list.length;
  }
}

class NotesStorage{
  List<Folder> folderStorage=[];
  List<Notes> notesStorage=[];
  NotesStorage(this.folderStorage, this.notesStorage);

  bool deleteNotes(Notes n){
    //TBD: deal with cloud firestore
    return notesStorage.remove(n);
  }

  bool deleteFolder(Folder f){
    //TBD: deal with cloud firestore
    return folderStorage.remove(f);
  }

  void addFolder(Folder f){
    return folderStorage.add(f);
  }

  void addNotes(Notes n){
    return notesStorage.add(n);
  }

}

//CircularButton


class CircularButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final Function folder_callBack;
  final Function notes_callback;

  CircularButton({this.tooltip, this.icon, this.notes_callback, this.folder_callBack});

  @override
  CircularButtonState createState() => CircularButtonState();
}

class CircularButtonState extends State<CircularButton>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  double height,width;
  

  


  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.red,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -7.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
    
  }

  animate() {
    if (!isOpened) {      
      _animationController.forward();

    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget notes() {
    // if(!isOpened){
    //   return Container();
    // }
    return AnimatedOpacity(
      opacity: isOpened ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child:Container(
        child: GestureDetector(child:customTextRow("Notes", Icons.notes),
        onTap: (){
          //log(this.widget.callBack.toString());
          this.widget.notes_callback();
          
        },)
    ));
  }
  Widget customTextRow(String buttonName, IconData data){
    return Row(children:[Text(buttonName, style: TextStyle(color:Color(0xFFC4C4C4)),),Icon(data,size: 35,color:Colors.grey[400])],mainAxisAlignment: MainAxisAlignment.end,);
  }

  Widget folder() {
    // if(!isOpened){
    //   return Container();
    // }
    return AnimatedOpacity(
      opacity: isOpened ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child:Container(
        child: GestureDetector(child:customTextRow("Folder", Icons.folder),
          onTap: (){
            this.widget.folder_callBack();
          },)
    ));
  }

  


  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Add',
        // child: AnimatedIcon(
        //   icon: AnimatedIcons.close_menu,
        //   progress: _animateIcon,
        // ),

        child:isOpened?Icon(Icons.close): Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 4,
            0.0,
          ),
          child: folder(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: notes(),
        ),
        
        toggle(),
      ],
    );
  }
}