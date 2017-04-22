import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';

main() async {
  //Use for firebase package development only
  await config();

  fb.initializeApp(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseUrl,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId);

  new MessagesApp().start();
}

class MessagesApp {
  final fb.Messaging messaging;

  MessagesApp() : messaging = fb.messaging() {

  }

  start() async {
    await _showPermissionRequest();

    try {
      String token = await messaging.getToken();
      if (token != null) {

      } else {
        _showPermissionRequest();
      }
    } catch (e) {
      print("Error retrieving token");
    }

    messaging.onTokenRefresh.listen((_) async {
      String token = await messaging.getToken();
    });
  }

  _showPermissionRequest() async {
    try {
      await messaging.requestPermission();
      print("Permission granted");
    } catch (e) {
      print("Permission denied $e");
    }
  }
}
