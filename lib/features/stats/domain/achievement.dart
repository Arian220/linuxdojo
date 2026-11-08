import 'package:linuxdojo/features/stats/domain/user_stats.dart';

enum AchievementCategory {
  sessions,
  cards,
  accuracy,
  streak,
  goals,
  mastery,
  multipleChoice,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final bool Function(UserStats stats) isUnlocked;
}

class AchievementStatus {
  const AchievementStatus({required this.definition, this.unlockedAt});

  final AchievementDefinition definition;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;
}

final achievementDefinitions = <AchievementDefinition>[
  AchievementDefinition(
    id: 'first_session',
    title: 'Hello, World',
    description: 'Complete your first study session.',
    category: AchievementCategory.sessions,
    isUnlocked: (stats) => stats.totalSessions >= 1,
  ),
  AchievementDefinition(
    id: 'sessions_5',
    title: 'Getting Started',
    description: 'Complete 5 study sessions.',
    category: AchievementCategory.sessions,
    isUnlocked: (stats) => stats.totalSessions >= 5,
  ),
  AchievementDefinition(
    id: 'sessions_10',
    title: 'Regular Practice',
    description: 'Complete 10 study sessions.',
    category: AchievementCategory.sessions,
    isUnlocked: (stats) => stats.totalSessions >= 10,
  ),
  AchievementDefinition(
    id: 'sessions_25',
    title: 'Dojo Devotee',
    description: 'Complete 25 study sessions.',
    category: AchievementCategory.sessions,
    isUnlocked: (stats) => stats.totalSessions >= 25,
  ),
  AchievementDefinition(
    id: 'sessions_50',
    title: 'Terminal Veteran',
    description: 'Complete 50 study sessions.',
    category: AchievementCategory.sessions,
    isUnlocked: (stats) => stats.totalSessions >= 50,
  ),
  AchievementDefinition(
    id: 'cards_10',
    title: 'First Steps',
    description: 'Review 10 cards.',
    category: AchievementCategory.cards,
    isUnlocked: (stats) => stats.cardsReviewed >= 10,
  ),
  AchievementDefinition(
    id: 'cards_50',
    title: 'Command Ready',
    description: 'Review 50 cards.',
    category: AchievementCategory.cards,
    isUnlocked: (stats) => stats.cardsReviewed >= 50,
  ),
  AchievementDefinition(
    id: 'cards_100',
    title: 'Shell Scout',
    description: 'Review 100 cards.',
    category: AchievementCategory.cards,
    isUnlocked: (stats) => stats.cardsReviewed >= 100,
  ),
  AchievementDefinition(
    id: 'cards_250',
    title: 'Pipeline Pro',
    description: 'Review 250 cards.',
    category: AchievementCategory.cards,
    isUnlocked: (stats) => stats.cardsReviewed >= 250,
  ),
  AchievementDefinition(
    id: 'cards_500',
    title: 'Kernel Explorer',
    description: 'Review 500 cards.',
    category: AchievementCategory.cards,
    isUnlocked: (stats) => stats.cardsReviewed >= 500,
  ),
  AchievementDefinition(
    id: 'cards_1000',
    title: 'Command Master',
    description: 'Review 1,000 cards.',
    category: AchievementCategory.cards,
    isUnlocked: (stats) => stats.cardsReviewed >= 1000,
  ),
  AchievementDefinition(
    id: 'correct_25',
    title: 'Sharp Shooter',
    description: 'Answer 25 cards correctly.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.correctAnswers >= 25,
  ),
  AchievementDefinition(
    id: 'correct_100',
    title: 'Precision',
    description: 'Answer 100 cards correctly.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.correctAnswers >= 100,
  ),
  AchievementDefinition(
    id: 'correct_250',
    title: 'Flawless Flow',
    description: 'Answer 250 cards correctly.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.correctAnswers >= 250,
  ),
  AchievementDefinition(
    id: 'correct_500',
    title: 'Error Free',
    description: 'Answer 500 cards correctly.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.correctAnswers >= 500,
  ),
  AchievementDefinition(
    id: 'accuracy_80',
    title: 'Reliable',
    description: 'Reach 80% accuracy over at least 20 cards.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.cardsReviewed >= 20 && stats.accuracy >= 0.8,
  ),
  AchievementDefinition(
    id: 'accuracy_90',
    title: 'Accurate',
    description: 'Reach 90% accuracy over at least 50 cards.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.cardsReviewed >= 50 && stats.accuracy >= 0.9,
  ),
  AchievementDefinition(
    id: 'accuracy_95',
    title: 'Near Perfect',
    description: 'Reach 95% accuracy over at least 100 cards.',
    category: AchievementCategory.accuracy,
    isUnlocked: (stats) => stats.cardsReviewed >= 100 && stats.accuracy >= 0.95,
  ),
  AchievementDefinition(
    id: 'streak_3',
    title: 'Warming Up',
    description: 'Reach a 3-day streak.',
    category: AchievementCategory.streak,
    isUnlocked: (stats) => stats.longestStreak >= 3,
  ),
  AchievementDefinition(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Reach a 7-day streak.',
    category: AchievementCategory.streak,
    isUnlocked: (stats) => stats.longestStreak >= 7,
  ),
  AchievementDefinition(
    id: 'streak_14',
    title: 'Fortnight Focus',
    description: 'Reach a 14-day streak.',
    category: AchievementCategory.streak,
    isUnlocked: (stats) => stats.longestStreak >= 14,
  ),
  AchievementDefinition(
    id: 'streak_30',
    title: 'Unstoppable',
    description: 'Reach a 30-day streak.',
    category: AchievementCategory.streak,
    isUnlocked: (stats) => stats.longestStreak >= 30,
  ),
  AchievementDefinition(
    id: 'goal_1',
    title: 'Goal Getter',
    description: 'Meet your daily goal once.',
    category: AchievementCategory.goals,
    isUnlocked: (stats) => stats.daysGoalMet >= 1,
  ),
  AchievementDefinition(
    id: 'goal_7',
    title: 'Consistent',
    description: 'Meet your daily goal 7 times.',
    category: AchievementCategory.goals,
    isUnlocked: (stats) => stats.daysGoalMet >= 7,
  ),
  AchievementDefinition(
    id: 'goal_30',
    title: 'Habit Formed',
    description: 'Meet your daily goal 30 times.',
    category: AchievementCategory.goals,
    isUnlocked: (stats) => stats.daysGoalMet >= 30,
  ),
  AchievementDefinition(
    id: 'mastered_10',
    title: 'Memory Lane',
    description: 'Master 10 cards.',
    category: AchievementCategory.mastery,
    isUnlocked: (stats) => stats.masteredCards >= 10,
  ),
  AchievementDefinition(
    id: 'mastered_30',
    title: 'Solid Foundation',
    description: 'Master 30 cards.',
    category: AchievementCategory.mastery,
    isUnlocked: (stats) => stats.masteredCards >= 30,
  ),
  AchievementDefinition(
    id: 'mastered_60',
    title: 'Deep Knowledge',
    description: 'Master 60 cards.',
    category: AchievementCategory.mastery,
    isUnlocked: (stats) => stats.masteredCards >= 60,
  ),
  AchievementDefinition(
    id: 'mastered_120',
    title: 'Almost There',
    description: 'Master 120 cards.',
    category: AchievementCategory.mastery,
    isUnlocked: (stats) => stats.masteredCards >= 120,
  ),
  AchievementDefinition(
    id: 'mastered_240',
    title: 'LinuxDojo Complete',
    description: 'Master all 240 cards.',
    category: AchievementCategory.mastery,
    isUnlocked: (stats) => stats.masteredCards >= 240,
  ),
  AchievementDefinition(
    id: 'mc_10',
    title: 'Choice Student',
    description: 'Answer 10 multiple-choice cards.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceAnswered >= 10,
  ),
  AchievementDefinition(
    id: 'mc_50',
    title: 'Option Picker',
    description: 'Answer 50 multiple-choice cards.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceAnswered >= 50,
  ),
  AchievementDefinition(
    id: 'mc_100',
    title: 'Multiple Choice Pro',
    description: 'Answer 100 multiple-choice cards.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceAnswered >= 100,
  ),
  AchievementDefinition(
    id: 'mc_250',
    title: 'Decision Maker',
    description: 'Answer 250 multiple-choice cards.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceAnswered >= 250,
  ),
  AchievementDefinition(
    id: 'mc_correct_10',
    title: 'Right Choice',
    description: 'Answer 10 multiple-choice cards correctly.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceCorrect >= 10,
  ),
  AchievementDefinition(
    id: 'mc_correct_50',
    title: 'Quick Thinker',
    description: 'Answer 50 multiple-choice cards correctly.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceCorrect >= 50,
  ),
  AchievementDefinition(
    id: 'mc_correct_100',
    title: 'Command Selector',
    description: 'Answer 100 multiple-choice cards correctly.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.multipleChoiceCorrect >= 100,
  ),
  AchievementDefinition(
    id: 'mc_streak_5',
    title: 'On a Roll',
    description: 'Answer 5 multiple-choice cards correctly in a row.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.bestMultipleChoiceStreak >= 5,
  ),
  AchievementDefinition(
    id: 'mc_streak_10',
    title: 'Unbroken',
    description: 'Answer 10 multiple-choice cards correctly in a row.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.bestMultipleChoiceStreak >= 10,
  ),
  AchievementDefinition(
    id: 'mc_streak_20',
    title: 'Perfect Run',
    description: 'Answer 20 multiple-choice cards correctly in a row.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) => stats.bestMultipleChoiceStreak >= 20,
  ),
  AchievementDefinition(
    id: 'mc_accuracy_80',
    title: 'Good Instincts',
    description: 'Reach 80% multiple-choice accuracy over 20 answers.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) =>
        stats.multipleChoiceAnswered >= 20 &&
        stats.multipleChoiceAccuracy >= 0.8,
  ),
  AchievementDefinition(
    id: 'mc_accuracy_90',
    title: 'Excellent Instincts',
    description: 'Reach 90% multiple-choice accuracy over 50 answers.',
    category: AchievementCategory.multipleChoice,
    isUnlocked: (stats) =>
        stats.multipleChoiceAnswered >= 50 &&
        stats.multipleChoiceAccuracy >= 0.9,
  ),
];
