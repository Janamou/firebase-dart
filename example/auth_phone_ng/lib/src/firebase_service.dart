import 'package:angular/angular.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';

@Injectable()
class FirebaseService {
  fb.Auth auth;
  fb.RecaptchaVerifier verifier;
  fb.ConfirmationResult confirmationResult;

  FirebaseService() {
    //Use for firebase package development only!
    _loadConfig();

    try {
      fb.initializeApp(
          apiKey: apiKey,
          authDomain: authDomain,
          databaseURL: databaseUrl,
          storageBucket: storageBucket);
    } on fb.FirebaseJsNotLoadedException catch (e) {
      print(e);
    }

    auth = fb.auth();

    if (auth.currentUser == null) {
      _initVerifier();
    }
  }

  register(String phone) async {
    try {
      confirmationResult = await auth.signInWithPhoneNumber(phone, verifier);
    } catch (e) {
      throw e;
    }
  }

  verify(String code) async {
    try {
      await confirmationResult.confirm(code);
    } catch (e) {
      throw e;
    }
  }

  void logout() {
    auth.signOut();
    _resetVerifier();
  }

  _loadConfig() async {
    await config();
  }

  _initVerifier() {
    // This is recaptcha widget
    verifier = new fb.RecaptchaVerifier("recaptcha-container")..render();

    // Use this if you want to use an anonymous recaptcha - size must be defined
    /*verifier = new fb.RecaptchaVerifier("register", {
      "size": "invisible",
      "callback": (resp) {
        print("reCAPTCHA solved, allow signInWithPhoneNumber.");
      },
      "expired-callback": () {
        print("Response expired. Ask user to solve reCAPTCHA again.");
      }
    });*/
  }

  _resetVerifier() {
    verifier.clear();
    _initVerifier();
  }
}
