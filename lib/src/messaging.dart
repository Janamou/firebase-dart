import 'dart:async';

import 'package:func/func.dart';
import 'package:js/js.dart';
import 'package:service_worker/window.dart' as sw;

import 'interop/messaging_interop.dart';
import 'js.dart';
import 'utils.dart';

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

  Messaging._fromJsObject(MessagingJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// To forceably stop a registration [token] from being used, delete it by
  /// calling this method.
  Future deleteToken(String token) =>
      handleThenable(jsObject.deleteToken(token));

  /// After calling [requestPermission()] you can call this method to get
  /// an FCM registration token that can be used to send push messages
  /// to this user.
  Future<String> getToken() => handleThenable(jsObject.getToken());

  var _onMessageUnsubscribe;
  StreamController<dynamic> _onMessageController;

  /// When a push message is received and the user is currently on a page
  /// for your origin, the message is passed to the page and an onMessage event
  /// is dispatched with the payload of the push message.
  ///
  /// NOTE: These events are dispatched when you have called
  /// [setBackgroundMessageHandler()] in your service worker.
  Stream<dynamic> get onMessage {
    if (_onMessageController == null) {
      var nextWrapper = allowInterop((payload) {
        _onMessageController.add(payload);
      });

      void startListen() {
        assert(_onMessageUnsubscribe == null);
        _onMessageUnsubscribe = jsObject.onMessage(nextWrapper);
      }

      void stopListen() {
        _onMessageUnsubscribe();
        _onMessageUnsubscribe = null;
      }

      _onMessageController = new StreamController<dynamic>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _onMessageController.stream;
  }

  var _onTokenRefreshUnsubscribe;
  StreamController<dynamic> _onTokenRefreshController;

  /// You should listen for token refreshes so your web app knows when FCM has
  /// invalidated your existing token and you need to call [getToken()] to get
  /// a new token.
  Stream<dynamic> get onTokenRefresh {
    if (_onTokenRefreshController == null) {
      var nextWrapper = allowInterop((payload) {
        _onTokenRefreshController.add(payload);
      });

      void startListen() {
        assert(_onTokenRefreshUnsubscribe == null);
        _onTokenRefreshUnsubscribe = jsObject.onTokenRefresh(nextWrapper);
      }

      void stopListen() {
        _onTokenRefreshUnsubscribe();
        _onTokenRefreshUnsubscribe = null;
      }

      _onTokenRefreshController = new StreamController<dynamic>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _onTokenRefreshController.stream;
  }

  /// Notification permissions are required to send a user push messages.
  /// Calling this method displays the permission dialog to the user and
  /// resolves if the permission is granted.
  Future requestPermission() => handleThenable(jsObject.requestPermission());

  /// FCM directs push messages to your web page's [onMessage] if the user
  /// currently has it open. Otherwise, it calls your callback passed into
  /// this method.
  dynamic setBackgroundMessageHandler(Func1 callback) =>
      jsObject.setBackgroundMessageHandler(allowInterop(callback));

  /// To use your own service worker for receiving push messages,
  /// you can pass in your service worker registration in this method.
  dynamic useServiceWorker(sw.ServiceWorkerRegistration registration) =>
      jsObject.useServiceWorker(registration.jsObject);
}
