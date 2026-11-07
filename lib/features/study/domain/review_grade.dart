enum ReviewGrade {
  again(quality: 0),
  hard(quality: 3),
  good(quality: 4),
  easy(quality: 5);

  const ReviewGrade({required this.quality});

  final int quality;

  static ReviewGrade fromMultipleChoice({required bool correct}) {
    return correct ? ReviewGrade.good : ReviewGrade.again;
  }
}
