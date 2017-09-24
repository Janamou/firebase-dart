import 'package:js/js.dart';

@JS('self')
external WorkerGlobalScope get workerSelf;

@anonymous
@JS()
abstract class WorkerGlobalScope {
  //TODO resolve how to import more scripts
  external void importScripts(String script);
}
