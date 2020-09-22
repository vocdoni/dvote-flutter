import 'dart:ffi';

class ProcessResults {
  List<List<int>> results;
  String state;
  String type;

  ProcessResults();
  toString() {
    return "type: $type \nstate: $state \nresults: $results";
  }
}
