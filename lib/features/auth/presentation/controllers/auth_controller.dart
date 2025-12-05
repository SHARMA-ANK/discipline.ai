import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/pages/login_page.dart';
import '../../../todo/presentation/pages/todo_page.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _authRepository.currentUser;
    _authRepository.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      user.value = session?.user;

      if (event == AuthChangeEvent.signedIn) {
        Get.offAll(() => const TodoPage());
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAll(() => const LoginPage());
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
