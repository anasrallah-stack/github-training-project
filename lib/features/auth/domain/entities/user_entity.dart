import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String? workWifiSsid;
  final List<String> deviceIds;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.workWifiSsid,
    this.deviceIds = const [],
    required this.createdAt,
  });

  UserEntity copyWith({
    String? fullName,
    String? photoUrl,
    String? workWifiSsid,
    List<String>? deviceIds,
  }) => UserEntity(
    uid: uid,
    email: email,
    fullName: fullName ?? this.fullName,
    photoUrl: photoUrl ?? this.photoUrl,
    workWifiSsid: workWifiSsid ?? this.workWifiSsid,
    deviceIds: deviceIds ?? this.deviceIds,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [uid, email, fullName, photoUrl, workWifiSsid, deviceIds];
}
