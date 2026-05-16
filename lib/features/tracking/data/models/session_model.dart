import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.userId,
    required super.startTime,
    super.endTime,
    required super.wifiSsid,
    required super.deviceId,
    super.isSynced,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      startTime: (d['startTime'] as Timestamp).toDate(),
      endTime: (d['endTime'] as Timestamp?)?.toDate(),
      wifiSsid: d['wifiSsid'] ?? '',
      deviceId: d['deviceId'] ?? '',
      isSynced: true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    'wifiSsid': wifiSsid,
    'deviceId': deviceId,
    'date': '${startTime.year}-${startTime.month.toString().padLeft(2,'0')}-${startTime.day.toString().padLeft(2,'0')}',
  };
}
