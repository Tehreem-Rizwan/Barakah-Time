import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePicPath;
  final DateTime memberSince;
  final int totalQuranPoints;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicPath,
    required this.memberSince,
    this.totalQuranPoints = 0,
  });

  UserEntity copyWith({
    String? name,
    String? email,
    String? profilePicPath,
    int? totalQuranPoints,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicPath: profilePicPath ?? this.profilePicPath,
      memberSince: memberSince,
      totalQuranPoints: totalQuranPoints ?? this.totalQuranPoints,
    );
  }

  @override
  List<Object?> get props => [id, name, email, profilePicPath, memberSince, totalQuranPoints];
}
