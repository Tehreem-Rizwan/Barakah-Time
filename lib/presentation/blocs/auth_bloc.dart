import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpRequested(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class SignOutRequested extends AuthEvent {}

class UpdateProfileImageRequested extends AuthEvent {
  final String imagePath;
  const UpdateProfileImageRequested(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String email;
  const UpdateProfileRequested({required this.name, required this.email});
  @override
  List<Object?> get props => [name, email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences prefs;

  AuthBloc(this.prefs) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<UpdateProfileImageRequested>(_onUpdateProfileImage);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final name = prefs.getString('user_name');
    if (name != null) {
      emit(Authenticated(UserEntity(
        id: '1',
        name: name,
        email: prefs.getString('user_email') ?? '',
        profilePicPath: prefs.getString('user_profile_pic'),
        memberSince: DateTime.now(), // Placeholder for simplicity
      )));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    // Simple mock logic
    await prefs.setString('user_name', 'Barakah User');
    await prefs.setString('user_email', event.email);
    
    emit(Authenticated(UserEntity(
      id: '1',
      name: 'Barakah User',
      email: event.email,
      memberSince: DateTime.now(),
    )));
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    await prefs.setString('user_name', event.name);
    await prefs.setString('user_email', event.email);
    
    emit(Authenticated(UserEntity(
      id: '1',
      name: event.name,
      email: event.email,
      memberSince: DateTime.now(),
    )));
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    await prefs.clear();
    emit(Unauthenticated());
  }

  Future<void> _onUpdateProfileImage(UpdateProfileImageRequested event, Emitter<AuthState> emit) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      await prefs.setString('user_profile_pic', event.imagePath);
      emit(Authenticated(currentUser.copyWith(profilePicPath: event.imagePath)));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      await prefs.setString('user_name', event.name);
      await prefs.setString('user_email', event.email);
      emit(Authenticated(currentUser.copyWith(name: event.name, email: event.email)));
    }
  }
}
