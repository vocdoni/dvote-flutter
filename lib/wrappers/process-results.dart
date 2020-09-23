class ProcessResults {
  List<List<int>> results;
  String state;
  String type;

  ProcessResults.empty();
  ProcessResults(this.state, this.type, this.results);
  toString() {
    return "ProcessResults: type $type, state $state, results $results";
  }
}

class ProcessResultsDigested {
  String state;
  String type;
  List<ProcessResultItem> questions;

  ProcessResultsDigested(this.state, this.type);

  toString() {
    String s = "Process results: \nType: $type, state: $state \n";
    if (questions?.isEmpty ?? true) {
      s += "No questions available";
      return s;
    }
    if (questions?.isNotEmpty ?? false) {
      for (int i = 0; i < questions.length; i++) {
        s += "Question ${i + 1}: \n" + questions[i].toString() + "\n";
      }
    }
    return s;
  }
}

class ProcessResultItem {
  String type;
  Map<String, String> question;
  Map<String, String> description;
  List<VoteResults> voteResults;

  toString() {
    return "Question: $type, question: ${question["default"]}, description: ${description["default"]}, results: $voteResults";
  }

  ProcessResultItem(this.type, this.question, this.description);
}

class VoteResults {
  String title;
  int votes;

  VoteResults(this.title, this.votes);

  toString() {
    return "$title: $votes votes";
  }
}
