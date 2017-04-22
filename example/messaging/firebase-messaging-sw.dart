import 'package:firebase/firebase.dart' as fb;
import 'package:service_worker/worker.dart';

void main(List<String> args) {
  fb.workerSelf.importScripts('https://www.gstatic.com/firebasejs/3.8.0/firebase-app.js');
  fb.workerSelf.importScripts('https://www.gstatic.com/firebasejs/3.8.0/firebase-messaging.js');

  fb.initializeApp(messagingSenderId: "782861952658");

  fb.Messaging messaging = fb.messaging();
  messaging.setBackgroundMessageHandler((payload) {
    print('[firebase-messaging-sw.js] Received background message $payload');
    String notificationTitle = 'Background Message Title';
    ShowNotificationOptions notificationOptions = new ShowNotificationOptions(
        body: 'Background Message body.', icon: '/firebase-logo.png');

    return registration.showNotification(
        notificationTitle, notificationOptions);
  });

  print('SW started.');

  onActivate.listen((ExtendableEvent event) {
    print('Activating.');
  });

  onMessage.listen((ExtendableMessageEvent event) {
    print('onMessage received ${event.data}');
  });
}
