import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/firebase_service.dart';

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
  final SupabaseService supabaseService;
  final FirebaseService firebaseService;

  AuthBloc(this.prefs, this.supabaseService, this.firebaseService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<UpdateProfileImageRequested>(_onUpdateProfileImage);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final name = prefs.getString('user_name');
    final uid = prefs.getString('user_id') ?? '1'; // In real app, get from FirebaseAuth
    
    if (name != null) {
      emit(Authenticated(UserEntity(
        id: uid,
        name: name,
        email: prefs.getString('user_email') ?? '',
        profilePicPath: prefs.getString('user_profile_pic'),
        memberSince: DateTime.now(),
      )));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    const uid = '123'; // Mock UID
    await prefs.setString('user_id', uid);
    await prefs.setString('user_name', 'Barakah User');
    await prefs.setString('user_email', event.email);

    // Sync to Firebase
    await firebaseService.saveUserProfile(
      uid: uid,
      name: 'Barakah User',
      email: event.email,
    );
    
    emit(Authenticated(UserEntity(
      id: uid,
      name: 'Barakah User',
      email: event.email,
      memberSince: DateTime.now(),
    )));
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    const uid = '123'; // Mock UID
    await prefs.setString('user_id', uid);
    await prefs.setString('user_name', event.name);
    await prefs.setString('user_email', event.email);

    // Sync to Firebase
    await firebaseService.saveUserProfile(
      uid: uid,
      name: event.name,
      email: event.email,
    );
    
    emit(Authenticated(UserEntity(
      id: uid,
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
      emit(AuthLoading());
      try {
        final String imageUrl = await supabaseService.uploadImage(event.imagePath);
        await prefs.setString('user_profile_pic', imageUrl);
        
        // Update Firebase
        await firebaseService.saveUserProfile(
          uid: currentUser.id,
          name: currentUser.name,
          email: currentUser.email,
          profilePicUrl: imageUrl,
        );

        emit(Authenticated(currentUser.copyWith(profilePicPath: imageUrl)));
      } catch (e) {
        emit(AuthError('Failed to upload profile image: ${e.toString()}'));
        emit(Authenticated(currentUser));
      }
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      emit(AuthLoading());
      try {
        await prefs.setString('user_name', event.name);
        await prefs.setString('user_email', event.email);

        // Update Firebase
        await firebaseService.saveUserProfile(
          uid: currentUser.id,
          name: event.name,
          email: event.email,
          profilePicUrl: currentUser.profilePicPath,
        );

        emit(Authenticated(currentUser.copyWith(name: event.name, email: event.email)));
      } catch (e) {
        emit(AuthError('Failed to update profile: ${e.toString()}'));
        emit(Authenticated(currentUser));
      }
    }
  }
}
