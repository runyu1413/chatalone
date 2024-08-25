import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:ntu_fyp_chatalone/main.dart';
import 'package:ntu_fyp_chatalone/model/user_model.dart';

TextEditingController txtController = TextEditingController();

class CreateUser extends StatelessWidget {
  final filter = ProfanityFilter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final textTheme = theme.textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme background
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Chatalone",
              style: textTheme.headline6?.copyWith(
                fontFamily: 'RobotoMono',
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(width: 50, height: 50),
          Image.asset("image/live-chat.png", height: 100, width: 100),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  } else if (filter.hasProfanity(value) == true) {
                    return 'Username contains profanity';
                  }
                  return null;
                },
                style: textTheme.bodyText1?.copyWith(
                  color: theme.textTheme.bodyText1?.color,
                ),
                controller: txtController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                  labelText: 'Enter Username',
                  labelStyle: textTheme.bodyText2?.copyWith(
                    color: theme.textTheme.bodyText2?.color,
                  ),
                ),
              ),
            ),
          ),
          UserButton(),
        ],
      ),
    );
  }
}

class UserButton extends StatefulWidget {
  const UserButton({super.key});

  @override
  UserButtonState createState() => new UserButtonState();
}

class UserButtonState extends State<UserButton> {
  final filter = ProfanityFilter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (txtController.text == null || txtController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter a username")),
          );
        } else if (filter.hasProfanity(txtController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please do not enter profanity")),
          );
        } else {
          Navigator.of(context)
              .pushReplacementNamed('home', arguments: txtController.text);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.primaryColor, // Use theme primary color
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Text(
          'Confirm',
          style: theme.textTheme.button?.copyWith(
            color: theme.colorScheme.onPrimary, // Use contrasting color
          ),
        ),
      ),
    );
  }
}
