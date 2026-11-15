import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;

  /// Display name; empty when unknown — show the localized
  /// `default_user_name` instead (see [displayNameOr]).
  final String name;
  final String email;
  final String? profilePicPath;
  final DateTime? memberSince;
  final int totalQuranPoints;

  /// False for email/password accounts that haven't clicked the
  /// verification link yet (always true for Google/Apple).
  final bool emailVerified;

  /// Main sign-in provider: 'password', 'google.com' or 'apple.com'. Decides
  /// how to re-authenticate before deleting the account.
  final String? signInProvider;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicPath,
    this.memberSince,
    this.totalQuranPoints = 0,
    this.emailVerified = true,
    this.signInProvider,
  });

  bool get hasName => name.trim().isNotEmpty;

  String displayNameOr(String fallback) => hasName ? name : fallback;

  bool get isPasswordAccount => signInProvider == 'password';

  UserEntity copyWith({
    String? name,
    String? email,
    String? profilePicPath,
    int? totalQuranPoints,
    bool? emailVerified,
    String? signInProvider,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicPath: profilePicPath ?? this.profilePicPath,
      memberSince: memberSince,
      totalQuranPoints: totalQuranPoints ?? this.totalQuranPoints,
      emailVerified: emailVerified ?? this.emailVerified,
      signInProvider: signInProvider ?? this.signInProvider,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profilePicPath,
    memberSince,
    totalQuranPoints,
    emailVerified,
    signInProvider,
  ];
}
