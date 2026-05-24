class Exercise {
  final String name;
  bool selected;

  Exercise({required this.name, this.selected = false});
}

final Map<String, List<Exercise>> exerciseMap = {
  'Chest': [
    Exercise(name: 'Bench Press'),
    Exercise(name: 'Chest Fly'),
    Exercise(name: 'Push Up'),
  ],
  'Back': [
    Exercise(name: 'Pull Up'),
    Exercise(name: 'Deadlift'),
    Exercise(name: 'Row'),
  ],
  'Legs': [
    Exercise(name: 'Squats'),
    Exercise(name: 'Lunges'),
    Exercise(name: 'Leg Press'),
  ],
  'Shoulder': [
    Exercise(name: 'Shoulder Press'),
    Exercise(name: 'Lateral Raise'),
    Exercise(name: 'Front Raise'),
  ],
  'Biceps': [
    Exercise(name: 'Bicep Curl'),
    Exercise(name: 'Hammer Curl'),
  ],
  'Triceps': [
    Exercise(name: 'Tricep Pushdown'),
    Exercise(name: 'Overhead Extension'),
  ],
  'Abs': [
    Exercise(name: 'Plank'),
    Exercise(name: 'Crunch'),
    Exercise(name: 'Leg Raise'),
  ],
  'Cardio': [
    Exercise(name: 'Running'),
    Exercise(name: 'Cycling'),
    Exercise(name: 'Jump Rope'),
  ],
};