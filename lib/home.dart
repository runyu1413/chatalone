import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ntu_fyp_chatalone/generated/l10n.dart'; // Import localization

TextEditingController txtController = TextEditingController();

class Home extends StatefulWidget {
  final String name;

  Home({required this.name});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<Home> {
  late String welcomeText;
  late String nameText;

  @override
  void initState() {
    super.initState();
    // Do not initialize localized strings here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Correct place to initialize localized strings
    welcomeText = S.of(context).welcomeText;
    nameText = widget.name;
  }

  void _updateTitle(String newName) {
    setState(() {
      nameText = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.scaffoldBackgroundColor, // Use theme background
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0), // Height of the AppBar
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            flexibleSpace: Center(
              // Center the content vertically
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.0), // Horizontal padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center vertically
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          welcomeText,
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Container(
                          width:
                              200, // Limit the width of the text to ensure truncation
                          child: Text(
                            nameText,
                            style: textTheme.titleLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Truncate with ellipsis
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.settings),
                          color: theme.iconTheme.color,
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('settings');
                          },
                        ),
                        /*
                        IconButton(
                          icon: Icon(Icons.person),
                          color: theme.iconTheme.color,
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              backgroundColor: theme.dialogBackgroundColor,
                              title: Text(
                                S.of(context).profileNameChange,
                                style: textTheme.titleLarge,
                              ),
                              content: TextFormField(
                                controller: txtController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      theme.inputDecorationTheme.fillColor,
                                  labelText: S.of(context).enterNewName,
                                  labelStyle: textTheme.subtitle1,
                                ),
                                style: textTheme.bodyText1,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: Text(
                                    S.of(context).cancel,
                                    style: textTheme.button,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _updateTitle(txtController.text);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    S.of(context).confirm,
                                    style: textTheme.button,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), */
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "image/chatalone-logo.png",
                height: 300,
                width: 300,
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(10), // Increase padding around the button
              child: SizedBox(
                width: 280, // Increase the width of the button
                height: 100, // Increase the height of the button
                child: Card(
                  color: theme
                      .primaryColor, // Use theme primary color for contrast
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    splashColor: theme.splashColor, // Use theme splash color
                    onTap: () => Navigator.of(context)
                        .pushNamed('start', arguments: widget.name),
                    child: Center(
                      child: Text(
                        S.of(context).findNearbyDevice,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20, // Larger font size
                          color: theme
                              .appBarTheme.foregroundColor, // Contrasting color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10), // Increase padding around the button
              child: SizedBox(
                width: 280, // Increase the width of the button
                height: 100, // Increase the height of the button
                child: Card(
                  color: theme
                      .primaryColor, // Use theme primary color for contrast
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                    splashColor: theme.splashColor, // Use theme splash color
                    onTap: () => Navigator.of(context)
                        .pushNamed('group', arguments: widget.name),
                    child: Center(
                      child: Text(
                        S.of(context).groupChat,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20, // Larger font size
                          color: theme
                              .appBarTheme.foregroundColor, // Contrasting color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
