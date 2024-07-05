import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextEditingController txtController = TextEditingController();

class Home extends StatefulWidget {
  String name;
  Home({required this.name});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<Home> {
  String text = "";

  void updateTitle() {
    setState(() {
      text = "Welcome " + this.widget.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    updateTitle();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 17, 20, 17),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            IconButton(
                icon: new Icon(Icons.person),
                color: Colors.white,
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text("Profile Name Change"),
                          content: TextFormField(
                              controller: txtController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Enter New Name')),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed('home',
                                      arguments: txtController.text),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ))),
            SizedBox(width: 40),
            Text(text,
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
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset("image/society.png", height: 320, width: 320),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 200, // Set a fixed width for the button
            child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed('start', arguments: this.widget.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Find Nearby Device',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 200, // Set the same fixed width for the button
            child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed('group', arguments: this.widget.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Group Chat',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          /*
          Container(
            padding: EdgeInsets.all(15.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => Navigator.of(context)
                    .pushNamed('start', arguments: this.widget.name),
                child: Column(
                  children: const <Widget>[
                    Icon(Icons.phone_android),
                    Text("Find Nearby Device")
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => Navigator.of(context)
                    .pushNamed('group', arguments: this.widget.name),
                child: Column(
                  children: const <Widget>[
                    Icon(Icons.phone_android),
                    Text("Group Chat")
                  ],
                ),
              ),
            ),
          )*/
        ],
      ),
    );
  }
}
