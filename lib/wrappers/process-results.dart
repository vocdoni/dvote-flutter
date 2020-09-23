class ProcessResults {
  List<List<int>> results;
  String state;
  String type;

  ProcessResults.empty();
  ProcessResults(this.state, this.type, this.results);
  toString() {
    return "type: $type \nstate: $state \nresults: $results";
  }
}

class ProcessResultsDigested {
  List<ProcessResultItem> questions;

  toString() {
    String s = "Process results: \n";
    if (questions?.isNotEmpty ?? false) {
      for (int i = 0; i < questions.length; i++) {
        s += "Question ${i + 1}: \n" + questions[i].toString() + "\n";
      }
    } else {
      s = "No questions available";
    }
    return s;
  }
}

class ProcessResultItem {
  String type;
  Map<String, String> question;
  List<VoteResults> voteResults;

  toString() {
    String s =
        "Type: $type\nQuestion: ${question["default"]} \nResults: $voteResults";
    return s;
  }

  ProcessResultItem(this.type, this.question);
}

class VoteResults {
  String title;
  int votes;

  VoteResults(this.title, this.votes);

  toString() {
    return "$title: $votes votes";
  }
}
