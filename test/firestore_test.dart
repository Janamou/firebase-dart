@Timeout(const Duration(seconds: 60))
@TestOn('browser')
import 'dart:async';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firebase_firestore.dart' as fs;
import 'package:firebase/src/assets/assets.dart';
import 'package:test/test.dart';
import 'test_util.dart';

// Delete entire collection
// <https://firebase.google.com/docs/firestore/manage-data/delete-data#collections>
Future _deleteCollection(db, collectionRef, batchSize) {
  Completer completer = new Completer();

  var query = collectionRef.orderBy('__name__').limit(batchSize);
  _deleteQueryBatch(db, query, batchSize, completer);

  return completer.future;
}

_deleteQueryBatch(db, query, batchSize, completer) async {
  try {
    var snapshot = await query.get();

    // When there are no documents left, we are done
    if (snapshot.size == 0) {
      completer.complete();
      return;
    }

    // Delete documents in a batch
    var batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    var numDeleted = snapshot.size;
    if (numDeleted <= batchSize) {
      completer.complete();
      return;
    }

    // Recurse with delay, to avoid exploding the stack.
    new Future.delayed(const Duration(milliseconds: 10),
        () => _deleteQueryBatch(db, query, batchSize, completer));
  } catch (e) {
    print(e);
    completer.completeError(e);
  }
}

void main() {
  fb.App app;

  setUpAll(() async {
    await config();
  });

  setUp(() async {
    app = fb.initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        projectId: projectId,
        storageBucket: storageBucket);
  });

  tearDown(() async {
    if (app != null) {
      await app.delete();
      app = null;
    }
  });

  group("Firestore", () {
    fs.Firestore firestore;

    setUp(() {
      firestore = fb.firestore();
    });

    group("instance", () {
      test("App exists", () {
        expect(firestore, isNotNull);
        expect(firestore.app, isNotNull);
        expect(firestore.app.name, fb.app().name);
      });
    });

    group("Collections and documents", () {
      fs.CollectionReference ref;

      setUp(() {
        ref = firestore.collection("messages");
      });

      tearDown(() async {
        if (ref != null) {
          await _deleteCollection(firestore, ref, 4);
          ref = null;
        }
      });

      test("collection exists", () {
        expect(ref, isNotNull);
        expect(ref.id, "messages");
        expect(ref.path, "messages");
      });

      test("create document with auto generated ID", () {
        var docRef = ref.doc();

        expect(docRef, isNotNull);
        expect(docRef.id, isNotEmpty);
      });

      test("create document", () {
        var docRef = ref.doc("message1");

        expect(docRef, isNotNull);
        expect(docRef.id, "message1");
        expect(docRef.path, "messages/message1");
        expect(docRef.parent.id, ref.id);
      });

      test("get document in collection", () {
        var docRef = ref.doc("message2");
        var docRefSecond = firestore.doc("messages/message2");
        expect(docRefSecond, isNotNull);
        expect(docRefSecond.id, docRef.id);
      });

      test("get document in collection of document", () {
        var docRef = ref.doc("message3").collection("words").doc("word1");
        expect(docRef, isNotNull);
        expect(docRef.id, "word1");
      });

      test("collection path", () {
        ref = firestore.collection("messages/message4/words");
        expect(ref, isNotNull);
        expect(ref.id, "words");
        expect(ref.parent.id, "message4");
      });
    });

    group("DocumentReference", () {
      fs.CollectionReference ref;

      setUp(() {
        ref = firestore.collection("messages");
      });

      tearDown(() async {
        if (ref != null) {
          await _deleteCollection(firestore, ref, 4);
          ref = null;
        }
      });

      test("delete collection", () async {
        ref = firestore.collection("cities");
        var nycRef = ref.doc("NYC");
        await nycRef.set({"name": "NYC"});
        var sfRef = ref.doc("SF");
        await sfRef.set({"name": "SF", "population": 0});
        var laRef = ref.doc("LA");
        await laRef.set({"name": "LA"});

        await _deleteCollection(firestore, ref, 4);

        var snapshot = await ref.get();
        expect(snapshot.empty, isTrue);
        expect(snapshot.docs.isEmpty, isTrue);
      });

      test("delete", () async {
        ref = firestore.collection("cities");
        var nycRef = ref.doc("NYC");
        await nycRef.set({"name": "NYC"});

        await nycRef.delete();
        nycRef = ref.doc("NYC");

        var snapshot = await nycRef.get();
        expect(snapshot.exists, isFalse);
      });

      test("delete fields", () async {
        ref = firestore.collection("cities");
        var nycRef = ref.doc("NYC");
        await nycRef.set({"name": "New York", "population": 1000});

        var snapshot = await nycRef.get();
        var snapshotData = snapshot.data();
        expect(snapshotData["name"], "New York");
        expect(snapshotData["population"], 1000);

        await nycRef.update(data: {"population": fs.FieldValue.delete()});

        snapshot = await nycRef.get();
        snapshotData = snapshot.data();
        expect(snapshotData["name"], "New York");
        expect(snapshotData["population"], isNull);
      });

      test("set document", () async {
        var docRef = ref.doc("message1");
        await docRef.set({"text": "Hi!"});

        var snapshot = await docRef.get();
        expect(snapshot.id, "message1");
        expect(snapshot.exists, true);
      });

      test("set overwrites document", () async {
        var docRef = ref.doc("message2");

        await docRef.set({"text": "Message2"});
        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData, new isInstanceOf<Map>());
        expect(snapshotData["text"], "Message2");

        await docRef.set({"title": "Ahoj"});
        snapshot = await docRef.get();
        snapshotData = snapshot.data();

        expect(snapshotData["text"], isNull);
        expect(snapshotData["title"], "Ahoj");
      });

      test("set with merge", () async {
        var docRef = ref.doc("message3");

        await docRef.set({"text": "Message3"});
        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        await docRef.set({"text": "MessageNew", "title": "Ahoj"},
            new fs.SetOptions(merge: true));
        snapshot = await docRef.get();
        snapshotData = snapshot.data();

        expect(snapshotData["text"], "MessageNew");
        expect(snapshotData["title"], "Ahoj");
      });

      test("set various types", () async {
        var docRef = ref.doc("message4");

        var map = {
          "stringExample": "Hello world!",
          "booleanExample": true,
          "numberExample": 3.14159265,
          "arrayExample": [5, true, "hello"],
          "nullExample": null,
          "mapExample": {
            "a": 5,
            "b": {"nested": "foo"}
          }
        };

        await docRef.set(map);
        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["stringExample"], map["stringExample"]);
        expect(snapshotData["booleanExample"], map["booleanExample"]);
        expect(snapshotData["numberExample"], map["numberExample"]);
        expect(snapshotData["arrayExample"], map["arrayExample"]);
        expect(snapshotData["nullExample"], map["nullExample"]);
        expect(snapshotData["mapExample"], map["mapExample"]);
      });

      test("get field", () async {
        var docRef = ref.doc("message4");

        var map = {
          "stringExample": "Hello world!",
          "innerMap": {"someNumber": 3.14159265}
        };

        await docRef.set(map);
        var snapshot = await docRef.get();

        expect(snapshot.get("stringExample"), "Hello world!");
        expect(snapshot.get("innerMap.someNumber"), 3.14159265);
        expect(snapshot.get(new fs.FieldPath("innerMap", "someNumber")),
            3.14159265);
        expect(snapshot.get("someNotExistentValue"), isNull);
      });

      test("add document", () async {
        var docRef = await ref.add({"text": "MessageAdd"});

        expect(docRef, isNotNull);
        expect(docRef.id, isNotNull);
        expect(docRef.parent.id, ref.id);
      });

      test("update document with Map", () async {
        var docRef = await ref.add({"text": "Ahoj"});
        await docRef.update(data: {"text": "Ahoj2"});

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["text"], "Ahoj2");

        await docRef.update(data: {"text": "Ahoj", "text_en": "Hi"});

        snapshot = await docRef.get();
        snapshotData = snapshot.data();

        expect(snapshotData["text"], "Ahoj");
        expect(snapshotData["text_en"], "Hi");
      });

      test("update with serverTimestamp", () async {
        var docRef = await ref.add({"text": "Good night"});
        await docRef
            .update(data: {"timestamp": fs.FieldValue.serverTimestamp()});

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["timestamp"], isNotNull);
      });

      test("update nested with dot notation", () async {
        var docRef = await ref.add({
          "greeting": {"text": "Good Morning"}
        });
        await docRef
            .update(data: {"greeting.text": "Good Morning after update"});

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["greeting"]["text"], "Good Morning after update");
      });

      test("update with FieldPath", () async {
        var docRef = await ref.add({
          "greeting": {"text": "Good Evening"}
        });
        await docRef.update(fieldsAndValues: [
          new fs.FieldPath("greeting", "text"),
          "Good Evening after update",
          new fs.FieldPath("greeting", "text_cs"),
          "Dobry vecer po uprave"
        ]);

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["greeting"]["text"], "Good Evening after update");
        expect(snapshotData["greeting"]["text_cs"], "Dobry vecer po uprave");
      });

      test("update with alternating fields as Strings and values", () async {
        var docRef = await ref.add({
          "greeting": {"text": "Hello"}
        });
        await docRef.update(fieldsAndValues: [
          "greeting.text",
          "Hello after update",
          "greeting.text_cs",
          "Ahoj po uprave"
        ]);

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["greeting"]["text"], "Hello after update");
        expect(snapshotData["greeting"]["text_cs"], "Ahoj po uprave");
      });

      test("transaction", () async {
        var docRef = ref.doc("message5");
        await docRef.set({"text": "Hi"});

        await firestore.runTransaction((transaction) async {
          transaction.update(docRef, data: {"text": "Hi from transaction"});
        });

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["text"], "Hi from transaction");
      });

      test("transaction returns updated value", () async {
        var docRef = ref.doc("message6");
        await docRef.set({"text": "Hi"});

        var newValue = await firestore.runTransaction((transaction) async {
          var documentSnapshot = await transaction.get(docRef);
          var value = documentSnapshot.data()["text"] + " val from transaction";
          transaction.update(docRef, data: {"text": value});
          return value;
        });

        expect(newValue, "Hi val from transaction");

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["text"], newValue);
      });

      test("transaction fails", () async {
        // update is before get -> transaction fails
        var docRef = ref.doc("message7");
        await docRef.set({"text": "Hi"});

        expect(firestore.runTransaction((transaction) async {
          transaction.update(docRef, data: {"text": "Some value"});
          await transaction.get(docRef);
        }),
            throwsToString(
                contains('Transactions lookups are invalid after writes.')));
      });

      test("transaction with FieldPath", () async {
        var docRef = ref.doc("message8");
        await docRef.set({
          "description": {"text": "Good morning!!!"}
        });

        await firestore.runTransaction((transaction) async {
          transaction.update(docRef, fieldsAndValues: [
            new fs.FieldPath("description", "text"),
            "Good morning after update!!!",
            new fs.FieldPath("description", "text_cs"),
            "Dobre rano po uprave!!!"
          ]);
        });

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["description"]["text"],
            "Good morning after update!!!");
        expect(
            snapshotData["description"]["text_cs"], "Dobre rano po uprave!!!");
      });

      test("transaction with alternating fields as Strings and values",
          () async {
        var docRef = ref.doc("message8");
        await docRef.set({
          "description": {"text": "Good morning!!!"}
        });

        await firestore.runTransaction((transaction) async {
          transaction.update(docRef, fieldsAndValues: [
            "description.text",
            "Good morning after update!!!",
            "description.text_cs",
            "Dobre rano po uprave!!!"
          ]);
        });

        var snapshot = await docRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["description"]["text"],
            "Good morning after update!!!");
        expect(
            snapshotData["description"]["text_cs"], "Dobre rano po uprave!!!");
      });

      test("WriteBatch operations", () async {
        ref = firestore.collection("cities");
        var nycRef = ref.doc("NYC");
        await nycRef.set({"name": "NYC"});
        var sfRef = ref.doc("SF");
        await sfRef.set({"name": "SF", "population": 0});
        var laRef = ref.doc("LA");
        await laRef.set({"name": "LA"});

        var collectionSnapshot = await ref.get();
        expect(collectionSnapshot.size, 3);

        var batch = firestore.batch();
        batch.set(nycRef, {"name": "New York"});
        batch.update(sfRef, data: {"population": 1000000});
        batch.delete(laRef);
        await batch.commit();

        var snapshot = await nycRef.get();
        var snapshotData = snapshot.data();
        expect(snapshotData["name"], "New York");

        snapshot = await sfRef.get();
        snapshotData = snapshot.data();
        expect(snapshotData["population"], 1000000);

        collectionSnapshot = await ref.get();
        expect(collectionSnapshot.size, 2);
      });

      test("WriteBatch operations with FieldPath", () async {
        ref = firestore.collection("cities");
        var sfRef = ref.doc("SF");
        await sfRef.set({
          "name": {"short": "SF"},
          "population": 0
        });

        var batch = firestore.batch();
        batch.update(sfRef, fieldsAndValues: [
          new fs.FieldPath("name", "long"),
          "San Francisco",
          new fs.FieldPath("population"),
          1000000
        ]);
        await batch.commit();

        var snapshot = await sfRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["name"]["long"], "San Francisco");
        expect(snapshotData["population"], 1000000);
      });

      test("WriteBatch with alternating fields as Strings and values",
          () async {
        ref = firestore.collection("cities");
        var sfRef = ref.doc("SF");
        await sfRef.set({
          "name": {"short": "SF"},
          "population": 0
        });

        var batch = firestore.batch();
        batch.update(sfRef, fieldsAndValues: [
          "name.long",
          "San Francisco",
          "population",
          1000000
        ]);
        await batch.commit();

        var snapshot = await sfRef.get();
        var snapshotData = snapshot.data();

        expect(snapshotData["name"]["long"], "San Francisco");
        expect(snapshotData["population"], 1000000);
      });
    });

    group("Quering data", () {
      fs.CollectionReference ref;

      setUp(() async {
        ref = firestore.collection("messages");

        await _deleteCollection(firestore, ref, 4);

        await ref
            .doc("message1")
            .set({"text": "hello", "lang": "en", "new": true});
        await ref.doc("message2").set({
          "text": "hi",
          "lang": "en",
          "description": {"text": "description text"}
        });
        await ref
            .doc("message3")
            .set({"text": "ahoj", "lang": "cs", "new": true});
        await ref.doc("message4").set({"text": "cau", "lang": "cs"});
      });

      tearDown(() async {
        if (ref != null) {
          await _deleteCollection(firestore, ref, 4);
          ref = null;
        }
      });

      test("get document data", () async {
        var docRef = ref.doc("message1");
        var snapshot = await docRef.get();
        expect(snapshot, isNotNull);
        expect(snapshot.exists, isTrue);

        var data = snapshot.data();
        expect(data, isNotNull);
        expect(data["text"], "hello");
      });

      test("get nonexistent document", () async {
        var docRef = ref.doc("message0");
        var snapshot = await docRef.get();
        expect(snapshot.exists, isFalse);
      });

      test("get documents where", () async {
        var snapshot = await ref.where("new", "==", true).get();
        expect(snapshot.size, 2);
      });

      test("get documents where with FieldPath", () async {
        var snapshot =
            await ref.where(new fs.FieldPath("new"), "==", true).get();
        expect(snapshot.size, 2);
      });

      test("get documents using compound query", () async {
        var snapshot = await ref
            .where("new", "==", true)
            .where("text", "==", "hello")
            .get();
        expect(snapshot.size, 1);
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs[0].data()["text"], "hello");
      });

      test("get all documents", () async {
        var snapshot = await ref.get();
        expect(snapshot.size, 4);
        expect(snapshot.docs, isNotEmpty);
        expect(snapshot.docs.length, snapshot.size);
        expect(snapshot.docs[0].data()["text"],
            anyOf("hello", "hi", "ahoj", "cau"));
      });

      test("onSnapshot", () async {
        var subscription;

        subscription = ref.onSnapshot.listen((snapshot) {
          expect(snapshot, isNotNull);
          expect(snapshot.docChanges, isNotEmpty);

          snapshot.forEach(expectAsync1((doc) {
            expect(
                doc.id, anyOf("message1", "message2", "message3", "message4"));
            expect(doc.metadata, isNotNull);
          }, count: 4));

          subscription.cancel();
        });
      });

      test("onSnapshot view changes", () async {
        ref.onSnapshot.listen((snapshot) {
          snapshot.docChanges.forEach((change) {
            if (change.type == "added") {
              expect(change.doc.id,
                  anyOf("message1", "message2", "message3", "message4"));
            }
          });
        });
      });

      test("onSnapshot document", () async {
        ref.doc("message1").onSnapshot.listen((doc) {
          if (doc.exists) {
            expect(doc.data()["text"], "hello");
          }
        });
      });

      test("onSnapshot document", () async {
        ref.doc("message1").onSnapshot.listen((doc) {
          if (doc.exists) {
            expect(doc.data()["text"], "hello");
          }
        });
      });

      test("order by", () async {
        var snapshot = await ref.orderBy("text").get();

        expect(snapshot.size, 4);
        expect(snapshot.docs[0].data()["text"], "ahoj");
        expect(snapshot.docs[3].data()["text"], "hi");

        snapshot = await ref.orderBy("text", "desc").get();

        expect(snapshot.size, 4);
        expect(snapshot.docs[0].data()["text"], "hi");
        expect(snapshot.docs[3].data()["text"], "ahoj");
      });

      test("limit", () async {
        var snapshot = await ref.get();
        expect(snapshot.size, 4);

        snapshot = await ref.limit(2).get();
        expect(snapshot.size, 2);
      });

      test("get documents where with limit", () async {
        var snapshot = await ref.where("new", "==", true).limit(1).get();
        expect(snapshot.size, 1);
      });

      // !!!IMPORTANT: You need to build index for lang and text under messages
      // collection to be able to run these tests.
      // (You can do this in Firebase console)
      test("startAt", () async {
        var snapshot = await ref
            .orderBy("lang")
            .orderBy("text")
            .startAt(fieldValues: ["cs", "cau"]).get();
        expect(snapshot.size, 3);
        expect(snapshot.docs[0].data()["text"], "cau");
        expect(snapshot.docs[2].data()["text"], "hi");

        snapshot = await ref.orderBy("description").startAt(fieldValues: [
          {"text": "description text"}
        ]).get();

        expect(snapshot.size, 1);
        expect(snapshot.docs[0].data()["description"],
            {"text": "description text"});

        var message2Snapshot = await ref.doc("message2").get();
        snapshot =
            await ref.orderBy("text").startAt(snapshot: message2Snapshot).get();

        // message2 text = "hi" => it is the last one
        expect(snapshot.size, 1);
        expect(snapshot.docs[0].data()["text"], "hi");
      });

      test("startAfter", () async {
        var snapshot = await ref
            .orderBy("lang")
            .orderBy("text")
            .startAfter(fieldValues: ["cs", "cau"]).get();
        expect(snapshot.size, 2);
        expect(snapshot.docs[0].data()["text"], "hello");
        expect(snapshot.docs[1].data()["text"], "hi");

        snapshot = await ref.orderBy("description").startAfter(fieldValues: [
          {"text": "description text"}
        ]).get();

        expect(snapshot.empty, isTrue);

        var message2Snapshot = await ref.doc("message2").get();
        snapshot = await ref
            .orderBy("text")
            .startAfter(snapshot: message2Snapshot)
            .get();

        // message2 text = "hi"
        expect(snapshot.empty, isTrue);
      });

      test("endBefore", () async {
        var snapshot = await ref
            .orderBy("lang")
            .orderBy("text")
            .endBefore(fieldValues: ["en", "hello"]).get();
        expect(snapshot.size, 2);
        expect(snapshot.docs[0].data()["text"], "ahoj");
        expect(snapshot.docs[1].data()["text"], "cau");

        snapshot = await ref.orderBy("description").endBefore(fieldValues: [
          {"text": "description text"}
        ]).get();

        expect(snapshot.empty, isTrue);

        var message2Snapshot = await ref.doc("message2").get();
        snapshot = await ref
            .orderBy("text")
            .endBefore(snapshot: message2Snapshot)
            .get();

        // message2 text = "hi"
        expect(snapshot.size, 3);
        expect(snapshot.docs[0].data()["text"], "ahoj");
        expect(snapshot.docs[2].data()["text"], "hello");
      });

      test("endAt", () async {
        var snapshot = await ref
            .orderBy("lang")
            .orderBy("text")
            .endAt(fieldValues: ["en", "hello"]).get();
        expect(snapshot.size, 3);
        expect(snapshot.docs[0].data()["text"], "ahoj");
        expect(snapshot.docs[2].data()["text"], "hello");

        snapshot = await ref.orderBy("description").endAt(fieldValues: [
          {"text": "description text"}
        ]).get();

        expect(snapshot.size, 1);
        expect(snapshot.docs[0].data()["description"],
            {"text": "description text"});

        var message2Snapshot = await ref.doc("message2").get();
        snapshot =
            await ref.orderBy("text").endAt(snapshot: message2Snapshot).get();

        // message2 text = "hi"
        expect(snapshot.size, 4);
        expect(snapshot.docs[0].data()["text"], "ahoj");
        expect(snapshot.docs[3].data()["text"], "hi");
      });
    });
  });
}
