import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  Timestamp? timestamp;
  bool? onOff;
  ReminderModel({this.timestamp, this.onOff});

  Map<String, dynamic> toMap() {
    return {
      'time': timestamp,
      'onOff': onOff,
    };
  }

  factory ReminderModel.fromMap(map) {
    return ReminderModel(onOff: map['onOff'], timestamp: map['time']);
  }
}
