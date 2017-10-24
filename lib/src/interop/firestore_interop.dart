@JS('firebase.firestore')
library firebase.firestore_interop;

import 'dart:typed_data' show Uint8List;
import 'package:js/js.dart';
import 'package:func/func.dart';

import 'app_interop.dart';
import 'firebase_interop.dart';

@JS("Firestore")
abstract class FirestoreJsImpl {
  external AppJsImpl get app;
  external void set app(AppJsImpl a);
  external WriteBatchJsImpl batch();
  external CollectionReferenceJsImpl collection(String collectionPath);
  external DocumentReferenceJsImpl doc(String documentPath);
  external PromiseJsImpl<Null> enablePersistence();
  external PromiseJsImpl runTransaction(
      Func1<TransactionJsImpl, dynamic> updateFunction);
  external void setLogLevel(String logLevel);
  external void settings(Settings settings);

  // TODO DocumentData object?
}

@JS("WriteBatch")
abstract class WriteBatchJsImpl {
  external PromiseJsImpl<Null> commit();
  external WriteBatchJsImpl delete(DocumentReferenceJsImpl documentRef);
  external WriteBatchJsImpl set(
      DocumentReferenceJsImpl documentRef, DocumentData data,
      [SetOptions options]);
  external WriteBatchJsImpl update(DocumentReferenceJsImpl documentRef,
      dynamic /*String|FieldPath*/ data_field,
      [dynamic value, List<dynamic> moreFieldsAndValues]);
}

@JS("CollectionReference")
class CollectionReferenceJsImpl extends QueryJsImpl {
  external String get id;
  external set id(String v);
  external DocumentReferenceJsImpl get parent;
  external set parent(DocumentReferenceJsImpl d);
  // TODO not in API?
  external String get path;
  external set path(String v);

  external factory CollectionReferenceJsImpl();
  external PromiseJsImpl<DocumentReferenceJsImpl> add(DocumentData data);
  external DocumentReferenceJsImpl doc([String documentPath]);
}

/// A [FieldPath] refers to a field in a document.
/// The path may consist of a single field name (referring to a top-level
/// field in the document), or a list of field names (referring to a nested
/// field in the document).
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FieldPath>.
@JS()
class FieldPath {
  /// Creates a [FieldPath] from the provided field names. If more than one
  /// field name is provided, the path will point to a nested field in
  /// a document.
  ///
  /// The [varArgs] is a list of field names. Value may be repeated.
  external factory FieldPath([List<String> varArgs]);

  /// Returns a special sentinel FieldPath to refer to the ID of a document.
  /// It can be used in queries to sort or filter by the document ID.
  external static FieldPath documentId();
}

/// An immutable object representing a geo point in Cloud Firestore.
/// The geo point is represented as latitude/longitude pair.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.GeoPoint>.
@JS()
class GeoPoint {
  /// Creates a new immutable [GeoPoint] object with the provided [latitude] and
  /// [longitude] values.
  ///
  /// [latitude] values are in the range of -90 to 90.
  /// [longitude] values are in the range of -180 to 180.
  external factory GeoPoint(num latitude, num longitude);

  /// The latitude of this GeoPoint instance.
  external num get latitude;
  external set latitude(num l);

  /// The longitude of this GeoPoint instance.
  external num get longitude;
  external set longitude(num l);
}

@JS()
abstract class BlobJsImpl {
  external static BlobJsImpl fromBase64String(String base64);
  external static BlobJsImpl fromUint8Array(Uint8List list);
  external String toBase64();
  external Uint8List toUint8Array();
}

// TODO implementation
@JS()
abstract class DocumentChange {
  // TODO atributes?
  /*
  external String /*'added'|'removed'|'modified'*/ get type;
  external set type(String /*'added'|'removed'|'modified'*/ v);

  /// The document affected by this change.
  external DocumentSnapshotJsImpl get doc;
  external set doc(DocumentSnapshotJsImpl v);

  /// The index of the changed document in the result set immediately prior to
  /// this DocumentChange (i.e. supposing that all prior DocumentChange objects
  /// have been applied). Is -1 for 'added' events.
  external num get oldIndex;
  external set oldIndex(num v);

  /// The index of the changed document in the result set immediately after
  /// this DocumentChange (i.e. supposing that all prior DocumentChange
  /// objects and the current DocumentChange object have been applied).
  /// Is -1 for 'removed' events.
  external num get newIndex;
  external set newIndex(num v);
  external factory DocumentChangeJsImpl(
      {String /*'added'|'removed'|'modified'*/ type,
      DocumentSnapshotJsImpl doc,
      num oldIndex,
      num newIndex});*/
}

@JS("DocumentReference")
abstract class DocumentReferenceJsImpl {
  external FirestoreJsImpl get firestore;
  external set firestore(FirestoreJsImpl f);
  external String get id;
  external set id(String s);
  external CollectionReferenceJsImpl get parent;
  external set parent(CollectionReferenceJsImpl c);

  // TODO path?
  external String get path;
  external set path(String v);

  external CollectionReferenceJsImpl collection(String collectionPath);
  external PromiseJsImpl<Null> delete();
  external PromiseJsImpl<DocumentSnapshotJsImpl> get();
  external VoidFunc0 onSnapshot(
      optionsOrObserverOrOnNext, observerOrOnNextOrOnError,
      [Func1<FirebaseError, dynamic> onError]);
  external PromiseJsImpl<Null> set(DocumentData data, [SetOptions options]);
  external PromiseJsImpl<Null> update(dynamic /*String|FieldPath*/ data_field,
      [dynamic value, List<dynamic> moreFieldsAndValues]);
}

@JS("DocumentSnapshot")
abstract class DocumentSnapshotJsImpl {
  external bool get exists;
  external set exists(bool v);
  external String get id;
  external set id(String v);
  external SnapshotMetadata get metadata;
  external set metadata(SnapshotMetadata v);
  external DocumentReferenceJsImpl get ref;
  external set ref(DocumentReferenceJsImpl v);
  external DocumentData data();
  external dynamic get(dynamic /*String|FieldPath*/ fieldPath);
}

/// Sentinel values that can be used when writing document fields with
/// [set()] or [update()].
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FieldValue>.
@JS()
abstract class FieldValue {
  /// Returns a sentinel for use with [update()] to mark a field for deletion.
  external static FieldValue delete();

  /// Returns a sentinel used with [set()] or [update()] to include a
  /// server-generated timestamp in the written data.
  external static FieldValue serverTimestamp();
}

@JS("Query")
abstract class QueryJsImpl {
  external FirestoreJsImpl get firestore;
  external set firestore(FirestoreJsImpl f);
  external QueryJsImpl endAt(
      dynamic /*DocumentSnapshot|List<dynamic>*/ snapshot_fieldValues);
  external QueryJsImpl endBefore(
      dynamic /*DocumentSnapshot|List<dynamic>*/ snapshot_fieldValues);
  external PromiseJsImpl<QuerySnapshotJsImpl> get();
  external QueryJsImpl limit(num limit);
  external VoidFunc0 onSnapshot(
      optionsOrObserverOrOnNext, observerOrOnNextOrOnError,
      [Func1<FirebaseError, dynamic> onError, QueryListenOptions onCompletion]);
  external QueryJsImpl orderBy(/*String|FieldPath*/ fieldPath,
      [String /*'desc'|'asc'*/ directionStr]);
  external QueryJsImpl startAfter(
      dynamic /*DocumentSnapshot|List<dynamic>*/ snapshot_fieldValues);
  external QueryJsImpl startAt(
      dynamic /*DocumentSnapshot|List<dynamic>*/ snapshot_fieldValues);
  external QueryJsImpl where(dynamic /*String|FieldPath*/ fieldPath,
      String /*'<'|'<='|'=='|'>='|'>'*/ opStr, dynamic value);
}

@JS("QuerySnapshot")
abstract class QuerySnapshotJsImpl {
  external List<DocumentChange> get docChanges;
  external set docChanges(List<DocumentChange> v);
  external List<DocumentSnapshotJsImpl> get docs;
  external set docs(List<DocumentSnapshotJsImpl> v);
  external bool get empty;
  external set empty(bool v);
  external SnapshotMetadata get metadata;
  external set metadata(SnapshotMetadata v);
  external QueryJsImpl get query;
  external set query(QueryJsImpl v);
  external num get size;
  external set size(num v);
  external void forEach(VoidFunc1<DocumentSnapshotJsImpl> callback, [thisArg]);
}

@JS("Transaction")
abstract class TransactionJsImpl {
  external TransactionJsImpl delete(DocumentReferenceJsImpl documentRef);
  external PromiseJsImpl<DocumentSnapshotJsImpl> get(
      DocumentReferenceJsImpl documentRef);
  external TransactionJsImpl set(
      DocumentReferenceJsImpl documentRef, DocumentData data,
      [SetOptions options]);
  external TransactionJsImpl update(DocumentReferenceJsImpl documentRef,
      dynamic /*String|FieldPath*/ data_field,
      [dynamic value, List<dynamic> moreFieldsAndValues]);
}

/// The set of Cloud Firestore status codes.
/// These status codes are also exposed by gRPC.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FirestoreError>.
// TODO
@anonymous
@JS()
abstract class FirestoreError {
  external dynamic /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ get code;
  external set code(
      dynamic /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ v);
  external String get message;
  external set message(String v);
  external String get name;
  external set name(String v);
  external String get stack;
  external set stack(String v);
  external factory FirestoreError(
      {dynamic /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ code,
      String message,
      String name,
      String stack});
}

/// Options for use with [Query.onSnapshot()] to control the behavior of
/// the snapshot listener.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.QueryListenOptions>.
@anonymous
@JS()
abstract class QueryListenOptions {
  /// Raise an event even if only metadata of a document in the query results
  /// changes (for example, one of the [DocumentSnapshot.metadata] properties on
  /// one of the documents). Default is [:false:].
  external bool get includeQueryMetadataChanges;
  external set includeQueryMetadataChanges(bool v);

  /// Raise an event even if only metadata changes (for example, one of the
  /// [QuerySnapshot.metadata] properties). Default is [:false:].
  external bool get includeDocumentMetadataChanges;
  external set includeDocumentMetadataChanges(bool v);
  external factory QueryListenOptions(
      {bool includeQueryMetadataChanges, bool includeDocumentMetadataChanges});
}

//TODO
@anonymous
@JS()
abstract class Settings {
  /// The hostname to connect to.
  external String get host;
  external set host(String v);

  /// Whether to use SSL when connecting.
  external bool get ssl;
  external set ssl(bool v);
  external factory Settings({String host, bool ssl});
}

//TODO
@anonymous
@JS()
abstract class SnapshotMetadata {
  /// True if the snapshot contains the result of local writes (e.g. set() or
  /// update() calls) that have not yet been committed to the backend.
  /// If your listener has opted into metadata updates (via
  /// `DocumentListenOptions` or `QueryListenOptions`) you will receive another
  /// snapshot with `hasPendingWrites` equal to false once the writes have been
  /// committed to the backend.
  external bool get hasPendingWrites;
  external set hasPendingWrites(bool v);

  /// True if the snapshot was created from cached data rather than
  /// guaranteed up-to-date server data. If your listener has opted into
  /// metadata updates (via `DocumentListenOptions` or `QueryListenOptions`)
  /// you will receive another snapshot with `fromCache` equal to false once
  /// the client has received up-to-date data from the backend.
  external bool get fromCache;
  external set fromCache(bool v);
  external factory SnapshotMetadata({bool hasPendingWrites, bool fromCache});
}

//TODO
@anonymous
@JS()
abstract class DocumentListenOptions {
  /// Raise an event even if only metadata of the document changed. Default is
  /// false.
  external bool get includeMetadataChanges;
  external set includeMetadataChanges(bool v);
  external factory DocumentListenOptions({bool includeMetadataChanges});
}

/// An object to configure the [WriteBatch.set] behavior.
/// Pass [: {merge: true} :] to only replace the values specified in
/// the data argument. Fields omitted will remain untouched.
@anonymous
@JS()
abstract class SetOptions {
  external bool get merge;
  external set merge(bool v);
  external factory SetOptions({bool merge});
}

//TODO
/// An object of the fields and values for the document.
@anonymous
@JS()
class DocumentData {}
