import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

deleteReminder(BuildContext context, String id, String uid) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text('Delete Reminder'),
          content: Text("Are you sure you want to delete?"),
          actions: [
            TextButton(
                onPressed: () {
                  try {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('reminder')
                        .doc(uid)
                        .delete();
                    Fluttertoast.showToast(msg: "Reminder Deleted");
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }
                  Navigator.pop(context);
                },
                child: Text('Delete')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
          ],
        );
      });
}
