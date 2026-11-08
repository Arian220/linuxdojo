enum ExperienceLevel {
  beginner('beginner', 'Beginner', 'New to the Linux terminal'),
  intermediate(
    'intermediate',
    'Intermediate',
    'Comfortable with common commands',
  ),
  advanced('advanced', 'Advanced', 'Ready for deeper system tasks');

  const ExperienceLevel(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static ExperienceLevel fromValue(String? value) {
    return values.firstWhere(
      (level) => level.value == value,
      orElse: () => ExperienceLevel.beginner,
    );
  }
}
