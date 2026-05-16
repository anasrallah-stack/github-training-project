import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    super.photoUrl,
    super.workWifiSsid,
    super.deviceIds,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      workWifiSsid: data['workWifiSsid'],
      deviceIds: List<String>.from(data['deviceIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'fullName': fullName,
    'photoUrl': photoUrl,
    'workWifiSsid': workWifiSsid,
    'deviceIds': deviceIds,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    uid: entity.uid,
    email: entity.email,
    fullName: entity.fullName,
    photoUrl: entity.photoUrl,
    workWifiSsid: entity.workWifiSsid,
    deviceIds: entity.deviceIds,
    createdAt: entity.createdAt,
  );
}
