
class QuestionData {
  const QuestionData(this.question,this.options);
  final String question;
  final List<String> options;

  List<String> shuffleOption(){
    final List<String> shuffleAnswer=List.of(options);
    shuffleAnswer.shuffle();
    return shuffleAnswer;
  }
  }
   const questions= [
    QuestionData(
      'In the last month, how often have you been upset because of something that happened unexpectedly?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you felt that you were unable to control the important things in your life?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you felt nervous and stressed?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData( 
      'In the last month, how often have you felt confident about your ability to handle your personal problems?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you felt that things were going your way?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you found that you could not cope with all the things that you had to do?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you been able to control irritations in your life?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you felt that you were on top of things?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you been angered because of things that happened that were outside of your control?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
    QuestionData(
      'In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?',
      ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'],
    ),
  ];
