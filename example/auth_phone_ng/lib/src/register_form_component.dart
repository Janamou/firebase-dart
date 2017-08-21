import 'package:angular/angular.dart';
import 'package:firebase/firebase.dart' as fb;

@Component(
    selector: 'register-form', templateUrl: 'register_form_component.html')
class RegisterFormComponent {
  String phone;

  void register() async {
    // TODO vyresit angular validaci
    if (phone.isNotEmpty) {
      try {
        confirmationResult =
            await auth.signInWithPhoneNumber(phoneValue, verifier);
        isVerification = true;
        isRegister = false;
      } catch (e) {
        error = e.toString();
      }
    } else {
      error = "Please fill correct phone number.";
    }
  }
}
