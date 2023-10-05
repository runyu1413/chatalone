import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextEditingController txtController = TextEditingController();
class Home extends StatelessWidget {
    String name;
    Home({required this.name});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 17, 20, 17),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              IconButton(
                  icon: new Icon(Icons.person),
                  color: Colors.white,
                  onPressed: () => showDialog(context: context, builder: (BuildContext context)=> AlertDialog(
                    title:  Text("Profile Name Change"),content: TextFormField(controller: txtController,decoration: InputDecoration(filled: true,fillColor: Colors.white,labelText: 'Enter New Name')),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(context,'Cancel'), child: const Text('Cancel')),TextButton(onPressed: ()=> Navigator.pop(context, name =txtController.text), child: const Text('Confirm'))
                    ],
                  ))),
              SizedBox(width: 40),
              Text("Welcome" ,
                  style: TextStyle(
                      color: Colors.white,
                      //fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Align(alignment: Alignment.center,child:Image.asset("image/society.png",height: 320,width: 320),),

          Container(padding: EdgeInsets.all(15.0),child:
          Card(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),clipBehavior: Clip.antiAliasWithSaveLayer ,child:
          InkWell(splashColor: Colors.blue.withAlpha(30) ,onTap: () => Navigator.of(context).pushNamed('start',arguments: name),child:
          Column(children:const<Widget>[Icon(Icons.phone_android), Text("Find Nearby Device")],),),
          ),
          ),
          Container(padding: EdgeInsets.all(15.0), child: Card(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),clipBehavior: Clip.antiAliasWithSaveLayer ,child:
          InkWell(splashColor: Colors.blue.withAlpha(30) ,onTap: () => Navigator.of(context).pushNamed('/',arguments: name),child: 
          Column(children:const<Widget>[Icon(Icons.phone_android), Text("        Group Chat       ")],),),
          
          
          ),)
      ],
      ),
    );
  }
}
