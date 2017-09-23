import 'dart:async';
import 'package:firebase/src/interop/messaging_interop.dart';
import 'package:firebase/src/js.dart';
import 'package:firebase/src/utils.dart';
import 'package:func/func.dart';
import 'package:js/js.dart';
import 'package:service_worker/window.dart' as sw;

/// Firebase Messaging service interface.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.messaging>.
class Messaging extends JsObjectWrapper<MessagingJsImpl> {
  static final _expando = new Expando<Messaging>();

  /// Creates a new Messaging from a [jsObject].
  static Messaging get(MessagingJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= new Messaging._fromJsObject(jsObject);
  }

  /// Creates a new Messaging from a [jsObject].
  Messaging._fromJsObject(MessagingJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Future deleteToken(String token) =>
      handleThenable(jsObject.deleteToken(token));

  Future<String> getToken() => handleThenable(jsObject.getToken());

  var _onMessageUnsubscribe;
  StreamController<dynamic> _onMessageController;

  Stream<dynamic> get onMessage {
    if (_onMessageController == null) {
      var nextWrapper = allowInterop((payload) {
        _onMessageController.add(payload);
      });

      void startListen() {
        _onMessageUnsubscribe = jsObject.onMessage(nextWrapper);
      }

      void stopListen() {
        _onMessageUnsubscribe();
      }

      _onMessageController = new StreamController<dynamic>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _onMessageController.stream;
  }

  var _onTokenRefreshUnsubscribe;
  StreamController<dynamic> _onTokenRefreshController;

  Stream<dynamic> get onTokenRefresh {
    if (_onTokenRefreshController == null) {
      var nextWrapper = allowInterop((payload) {
        _onTokenRefreshController.add(payload);
      });

      void startListen() {
        _onTokenRefreshUnsubscribe = jsObject.onTokenRefresh(nextWrapper);
      }

      void stopListen() {
        _onTokenRefreshUnsubscribe();
      }

      _onTokenRefreshController = new StreamController<dynamic>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _onTokenRefreshController.stream;
  }

  Future requestPermission() => handleThenable(jsObject.requestPermission());

  dynamic setBackgroundMessageHandler(Func1 callback) =>
      jsObject.setBackgroundMessageHandler(allowInterop(callback));

  dynamic useServiceWorker(sw.ServiceWorkerRegistration registration) =>
      // TODO has to be registration.deletage
      jsObject.useServiceWorker(registration);
}
