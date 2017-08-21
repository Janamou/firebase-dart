import 'package:angular/angular.dart';
import 'src/firebase_service.dart';

@Component(
    selector: 'phone-auth',
    templateUrl: 'phone_auth_component.html',
    providers: const [FirebaseService])
class PhoneAuthComponent implements OnInit {
  bool isRegister = true;
  bool isVerification = false;
  String phone;
  String code;
  String error;

  final FirebaseService service;

  PhoneAuthComponent(this.service);

  @override
  ngOnInit() {
    // After opening
    if (service.auth.currentUser != null) {
      _setLayout(service.auth.currentUser);
    }

    // When auth state changes
    auth.onAuthStateChanged.listen((e) => _setLayout(e));
  }

  registerUser() {
    service.register(phone);
  }

  verifyUser() {
    service.verify(code);
  }

  /*void _setLayout(fb.User user) {
    if (user != null) {
      registerForm.style.display = "none";
      verificationForm.style.display = "none";
      logout.style.display = "block";
      phone.value = "";
      code.value = "";
      error.text = "";
      authInfo.style.display = "block";

      var data = <String, dynamic>{
        "email": user.email,
        "emailVerified": user.emailVerified,
        "isAnonymous": user.isAnonymous,
        "phoneNumber": user.phoneNumber
      };

      data.forEach((k, v) {
        if (v != null) {
          var row = authInfo.addRow();

          row.addCell()
            ..text = k
            ..classes.add("header");
          row.addCell()..text = "$v";
        }
      });

      print("User.toJson:");
      print(const JsonEncoder.withIndent(' ').convert(user));
    } else {
      isRegister = true;

      registerForm.style.display = "block";
      authInfo.style.display = "none";
      logout.style.display = "none";
      authInfo.children.clear();
    }
  }*/
}
