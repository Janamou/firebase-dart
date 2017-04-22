@JS('firebase.messaging')
library firebase.messaging_interop;

import 'package:firebase/src/interop/firebase_interop.dart';
import 'package:func/func.dart';
import 'package:js/js.dart';

@JS('Messaging')
abstract class MessagingJsImpl {
  external PromiseJsImpl deleteToken(String token);
  external PromiseJsImpl<String> getToken();
  external Func0 onMessage(nextOrObserver);
  external Func0 onTokenRefresh(nextOrObserver);
  external PromiseJsImpl requestPermission();
  external dynamic setBackgroundMessageHandler(Func1 callback);
  external dynamic useServiceWorker(registration);
}
