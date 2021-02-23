import 'package:dvote/dvote.dart';

class ProcessResults {
  List<List<String>> results;
  String state;
  String type;

  ProcessResults.empty();
  ProcessResults(this.state, this.type, this.results);

  @override
  toString() {
    return "ProcessResults: type $type, state $state, results $results";
  }
}

class ProcessResultsDigested {
  String state;
  String type;
  List<ProcessResultItem> questions;

  ProcessResultsDigested(this.state, this.type);

  @override
  toString() {
    String s = "Process results: \nType: $type, state: $state \n";
    if (questions?.isEmpty ?? true) {
      s += "No fields available";
      return s;
    }

    for (int i = 0; i < questions.length; i++) {
      s += "Field ${i + 1}: \n" + questions[i].toString() + "\n";
    }
    return s;
  }
}

class ProcessResultItem {
  Map<String, String> description;
  List<VoteResults> voteResults;

  ProcessResultItem(this.description);

  @override
  toString() {
    return "Question: description: ${description["default"]}, values: $voteResults";
  }
}

class VoteResults {
  Map<String, String> title;
  BigInt votes;

  VoteResults(this.title, this.votes);

  @override
  toString() {
    return "${title["default"]}: $votes votes";
  }
}
