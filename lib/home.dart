import 'package:flutter/material.dart';
import 'package:ntu_fyp_chatalone/generated/l10n.dart'; // Import localization
import 'group_created_list.dart';

TextEditingController txtController = TextEditingController();

class Home extends StatefulWidget {
  final String name;

  const Home({required this.name});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<Home> {
  late String welcomeText;
  late String nameText;

  @override
  void initState() {
    super.initState();
    nameText = widget.name; // Initialize nameText from the widget's property
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch localized strings whenever the dependencies change
    welcomeText = S.of(context).welcomeText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            flexibleSpace: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            welcomeText,
                            style: textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              nameText,
                              style: textTheme.titleLarge?.copyWith(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings),
                          color: theme.iconTheme.color,
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('settings');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                width: 300,
                child: Image.asset(
                  "image/chatalone.png",
                  fit: BoxFit.cover, // Adjust the fit property as needed
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 300,
                  height: 100,
                  child: Card(
                    color: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: InkWell(
                      splashColor: theme.splashColor,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(
                                  child: Text(
                                      "Choose Chat Type")), // Localized title
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double
                                        .infinity, // Make the button fill the available width
                                    height: 100, // Set the height of the button
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.of(context).pushNamed(
                                          'start',
                                          arguments: widget.name,
                                        ); // Navigate to the person chat page
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.person, size: 40),
                                          const SizedBox(height: 8),
                                          Text("Person Chat",
                                              textAlign: TextAlign
                                                  .center), // Localized text
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushNamed(
                                          'group',
                                          arguments: widget.name,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.group, size: 40),
                                          const SizedBox(height: 8),
                                          Text("Join Group Chat",
                                              textAlign: TextAlign.center),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Center(
                                                  child: Text(
                                                      "Create Group Chat")), // Localized title
                                              content: TextField(
                                                controller: txtController,
                                                decoration: InputDecoration(
                                                  labelText: "Group Name",
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GroupCreatedScreen(
                                                          mydata: widget.name,
                                                          groupName:
                                                              txtController
                                                                  .text,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text("Create"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.group_add, size: 40),
                                          const SizedBox(height: 8),
                                          Text("Create Group Chat",
                                              textAlign: TextAlign.center),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: Text(
                          S.of(context).newChat, // Use localized string
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: theme.appBarTheme.foregroundColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 300,
                  height: 100,
                  child: Card(
                    color: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: InkWell(
                      splashColor: theme.splashColor,
                      onTap: () =>
                          Navigator.of(context).pushNamed('chatSessions'),
                      child: Center(
                        child: Text(
                          S.of(context).oldChat, // Use localized string
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: theme.appBarTheme.foregroundColor,
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
      ),
    );
  }
}
