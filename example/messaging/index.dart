import 'dart:convert';
import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';
import 'package:service_worker/window.dart' as sw;

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
  final DivElement tokenDivId;
  final ParagraphElement tokenParagraph;
  final DivElement permissionDivId;
  final DivElement messagesDiv;
  final ButtonElement deleteTokenButton;
  final ButtonElement permissionButton;

  MessagesApp()
      : messaging = fb.messaging(),
        tokenDivId = querySelector('#token_div'),
        tokenParagraph = querySelector('#token'),
        deleteTokenButton = querySelector('#token_div button'),
        permissionDivId = querySelector('#permission_div'),
        permissionButton = querySelector('#permission_div button'),
        messagesDiv = querySelector('#messages') {
    deleteTokenButton.onClick.listen(deleteToken);
    permissionButton.onClick.listen(requestPermission);
  }

  start() async {
    if (sw.isNotSupported) {
      print('ServiceWorkers are not supported.');
      return;
    }

    sw.ServiceWorkerRegistration registration =
        await sw.register('firebase-messaging-sw.dart.js');
    print('registered');

    messaging.useServiceWorker(registration);

    messaging.onTokenRefresh.listen((_) async {
      try {
        String refreshedToken = await messaging.getToken();
        print('Token refreshed.');
        setTokenSentToServer(false);
        sendTokenToServer(refreshedToken);
        resetUI();
      } catch (e) {
        print('Unable to retrieve refreshed token $e');
        showToken('Unable to retrieve refreshed token $e');
      }
    });

    messaging.onMessage.listen((payload) {
      print('Message received. ${payload.body}');
      appendMessage(payload);
    });

    resetUI();
  }

  resetUI() async {
    clearMessages();
    showToken('loading...');

    try {
      String currentToken = await messaging.getToken();
      print(currentToken);
      if (currentToken != null) {
        sendTokenToServer(currentToken);
        updateUIForPushEnabled(currentToken);
      } else {
        print(
            'No Instance ID token available. Request permission to generate one.');
        updateUIForPushPermissionRequired();
        setTokenSentToServer(false);
      }
    } catch (e) {
      print('An error occurred while retrieving token. $e');
      showToken('Error retrieving Instance ID token. $e');
      setTokenSentToServer(false);
    }
  }

  showToken(currentToken) {
    tokenParagraph.text = currentToken;
  }

  sendTokenToServer(currentToken) {
    if (!isTokenSentToServer()) {
      print('Sending token to server...');
      // TODO(developer): Send the current token to your server.
      setTokenSentToServer(true);
    } else {
      print('Token already sent to server so won\'t send it again ' +
          'unless it changes');
    }
  }

  isTokenSentToServer() {
    if (window.localStorage['sentToServer'] == '1') {
      return true;
    }
    return false;
  }

  setTokenSentToServer(sent) {
    window.localStorage['sentToServer'] = sent ? '1' : '0';
  }

  showHideDiv(div, show) {
    if (show) {
      div.style.display = "block";
    } else {
      div.style.display = "none";
    }
  }

  requestPermission(e) async {
    print('Requesting permission...');

    try {
      await messaging.requestPermission();
      print('Notification permission granted.');
      resetUI();
    } catch (e) {
      print('Unable to get permission to notify. $e');
    }
  }

  deleteToken(e) async {
    try {
      String currentToken = await messaging.getToken();
      try {
        await messaging.deleteToken(currentToken);
        print('Token deleted.');
        setTokenSentToServer(false);
        resetUI();
      } catch (e) {
        print('Unable to delete token. $e');
      }
    } catch (e) {
      print('Error retrieving Instance ID token. $e');
      showToken('Error retrieving Instance ID token. $e');
    }
  }

  appendMessage(payload) {
    var dataHeaderELement = document.createElement('h5');
    var dataElement = document.createElement('pre');
    dataElement.style.overflowX = 'hidden';
    dataHeaderELement.text = 'Received message:';
    dataElement.text = JSON.decode(payload);
    messagesDiv.append(dataHeaderELement);
    messagesDiv.append(dataElement);
  }

  clearMessages() {
    messagesDiv.children.clear();
  }

  updateUIForPushEnabled(currentToken) {
    showHideDiv(tokenDivId, true);
    showHideDiv(permissionDivId, false);
    showToken(currentToken);
  }

  updateUIForPushPermissionRequired() {
    showHideDiv(tokenDivId, false);
    showHideDiv(permissionDivId, true);
  }
}
