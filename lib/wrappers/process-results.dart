class ProcessResults {
  List<List<int>> results;
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
      s += "No questions available";
      return s;
    }

    for (int i = 0; i < questions.length; i++) {
      s += "Question ${i + 1}: \n" + questions[i].toString() + "\n";
    }
    return s;
  }
}

class ProcessResultItem {
  String type;
  Map<String, String> question;
  Map<String, String> description;
  List<VoteResults> voteResults;

  ProcessResultItem(this.type, this.question, this.description);

  @override
  toString() {
    return "Question: $type, question: ${question["default"]}, description: ${description["default"]}, results: $voteResults";
  }
}

class VoteResults {
  Map<String, String> title;
  int votes;

  VoteResults(this.title, this.votes);

  @override
  toString() {
    return "${title["default"]}: $votes votes";
  }
}
