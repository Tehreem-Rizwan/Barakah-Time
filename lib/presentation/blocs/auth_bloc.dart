import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/firebase_service.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

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

class GoogleSignInRequested extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpRequested(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class SignOutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class ForgotPasswordSent extends AuthState {
  const ForgotPasswordSent();
}

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

// ─── States ───────────────────────────────────────────────────────────────────

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

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences prefs;
  final SupabaseService supabaseService;
  final FirebaseService firebaseService;

  AuthBloc(this.prefs, this.supabaseService, this.firebaseService)
      : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<UpdateProfileImageRequested>(_onUpdateProfileImage);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  // ── Session Check ───────────────────────────────────────────────────────────
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final firebaseUser = firebaseService.currentUser;
    if (firebaseUser != null) {
      final name = firebaseUser.displayName ??
          prefs.getString('user_name') ??
          'Barakah User';
      emit(Authenticated(UserEntity(
        id: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? '',
        profilePicPath:
            firebaseUser.photoURL ?? prefs.getString('user_profile_pic'),
        memberSince: firebaseUser.metadata.creationTime ?? DateTime.now(),
      )));
    } else {
      emit(Unauthenticated());
    }
  }

  // ── Email Sign In ───────────────────────────────────────────────────────────
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signIn(
        email: event.email,
        password: event.password,
      );
      final name = firebaseUser.displayName ??
          prefs.getString('user_name') ??
          'Barakah User';

      await _syncToFirestoreAndPrefs(
        uid: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? event.email,
      );

      emit(Authenticated(UserEntity(
        id: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? event.email,
        profilePicPath:
            firebaseUser.photoURL ?? prefs.getString('user_profile_pic'),
        memberSince: firebaseUser.metadata.creationTime ?? DateTime.now(),
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Google Sign In ──────────────────────────────────────────────────────────
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signInWithGoogle();
      final name = firebaseUser.displayName ?? 'Barakah User';

      await _syncToFirestoreAndPrefs(
        uid: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? '',
        profilePicUrl: firebaseUser.photoURL,
      );

      emit(Authenticated(UserEntity(
        id: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? '',
        profilePicPath: firebaseUser.photoURL,
        memberSince: firebaseUser.metadata.creationTime ?? DateTime.now(),
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────────
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      await _syncToFirestoreAndPrefs(
        uid: firebaseUser.uid,
        name: event.name,
        email: firebaseUser.email ?? event.email,
      );

      emit(Authenticated(UserEntity(
        id: firebaseUser.uid,
        name: event.name,
        email: firebaseUser.email ?? event.email,
        memberSince: firebaseUser.metadata.creationTime ?? DateTime.now(),
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await firebaseService.signOut();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_profile_pic');
    emit(Unauthenticated());
  }

  // ── Forgot Password ───────────────────────────────────────────────────────────
  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await firebaseService.sendPasswordResetEmail(event.email);
      emit(const ForgotPasswordSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Update Profile Image ──────────────────────────────────────────────────────
  Future<void> _onUpdateProfileImage(
    UpdateProfileImageRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      emit(AuthLoading());
      try {
        final String imageUrl =
            await supabaseService.uploadImage(event.imagePath);
        await prefs.setString('user_profile_pic', imageUrl);

        await firebaseService.saveUserProfile(
          uid: currentUser.id,
          name: currentUser.name,
          email: currentUser.email,
          profilePicUrl: imageUrl,
        );

        emit(Authenticated(currentUser.copyWith(profilePicPath: imageUrl)));
      } catch (e) {
        emit(AuthError('Failed to upload image: $e'));
        emit(Authenticated(currentUser));
      }
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────────
  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      emit(AuthLoading());
      try {
        await prefs.setString('user_name', event.name);
        await prefs.setString('user_email', event.email);

        await firebaseService.saveUserProfile(
          uid: currentUser.id,
          name: event.name,
          email: event.email,
          profilePicUrl: currentUser.profilePicPath,
        );

        emit(Authenticated(
            currentUser.copyWith(name: event.name, email: event.email)));
      } catch (e) {
        emit(AuthError('Failed to update profile: $e'));
        emit(Authenticated(currentUser));
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Future<void> _syncToFirestoreAndPrefs({
    required String uid,
    required String name,
    required String email,
    String? profilePicUrl,
  }) async {
    await prefs.setString('user_id', uid);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await firebaseService.saveUserProfile(
      uid: uid,
      name: name,
      email: email,
      profilePicUrl: profilePicUrl,
    );
  }
}
