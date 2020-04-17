import 'question.dart';

import 'package:flutter/material.dart' show UniqueKey;

class IncorrectQuestion extends Question {
  UniqueKey uniqueKey;

  IncorrectQuestion.fromQuestion(Question question)
      : uniqueKey = UniqueKey(),
        super.from(question);

  IncorrectQuestion.fromMap(Map map)
      : uniqueKey = UniqueKey(),
        super.fromMap(map);
}
