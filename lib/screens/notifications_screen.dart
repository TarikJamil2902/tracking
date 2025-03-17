import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: ListView.builder(
        itemCount: 10,  // এটার মান আপনার নোটিফিকেশনের সংখ্যা অনুযায়ী পরিবর্তন হবে
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notification #$index"),
            subtitle: Text("This is a sample notification message."),
          );
        },
      ),
);
}
}
