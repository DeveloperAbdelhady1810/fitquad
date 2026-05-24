import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/widgets/custom_button.dart';

class TrainingTabBarViewScreen extends StatefulWidget {
  const TrainingTabBarViewScreen({super.key});

  @override
  State<TrainingTabBarViewScreen> createState() =>
      _TrainingTabBarViewScreenState();
}

class _TrainingTabBarViewScreenState extends State<TrainingTabBarViewScreen> {

  late int todayIndex;

  @override
  void initState() {
    super.initState();
    todayIndex = getTodayIndex();
  }

  int getTodayIndex() {
    final today = DateTime.now().weekday;

    switch (today) {
      case DateTime.saturday:
        return 0;
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      case DateTime.friday:
        return 6;
      default:
        return 0;
    }
  }

  DayModel get selectedDay => mockDays[todayIndex];

  void saveDay() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Day Saved Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff111C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hypertrophy Phase 2",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "12 Weeks • 4 Days/Week",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ===== Weekly Schedule =====
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Weekly Schedule",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              vGap(10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(

                    mockDays.length, (index) {
                  final day = mockDays[index];

                  final bool isPast = index < todayIndex;
                  final bool isToday = index == todayIndex;
                  final bool isFuture = index > todayIndex;

                  Color backgroundColor;
                  Widget? trailingIcon;

                  if (isPast) {
                    backgroundColor = const Color(0xff1E293B);
                    trailingIcon = const Icon(Icons.check_circle,
                        color: Colors.green, size: 16);
                  } else if (isToday) {
                    backgroundColor = Colors.teal;
                  } else {
                    backgroundColor = const Color(0xff0F172A);
                  }

                  return Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: Colors.tealAccent, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(
                            color: isFuture ? Colors.grey : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.title,
                          style: TextStyle(
                            color:
                            isFuture ? Colors.grey : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(height: 4),
                          trailingIcon,
                        ]
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              /// ===== Day Details =====
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff111C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Day Detail: ${selectedDay.title} (Today)",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      /// Exercises List
                      Expanded(
                        child: selectedDay.exercises.isEmpty
                            ? const Center(
                          child: Text(
                            "Rest Day",
                            style: TextStyle(
                                color: Colors.white54),
                          ),
                        )
                            : ListView.builder(
                          itemCount:
                          selectedDay.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                            selectedDay.exercises[index];
                            return ListTile(
                              contentPadding:
                              EdgeInsets.zero,
                              title: Text(
                                exercise.name,
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                exercise.details,
                                style: const TextStyle(
                                    color: Colors.white54),
                              ),
                              trailing: const Icon(
                                Icons.play_arrow,
                                color: Colors.white54,
                              ),
                            );
                          },
                        ),
                      ),

                     vGap(10),

                      /// Save Button
                     CustomButton(text: 'save day', onPressed: () {

                     },)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ExerciseModel {
  final String name;
  final String details;

  ExerciseModel({
    required this.name,
    required this.details,
  });
}

class DayModel {
  final String day;
  final String title;
  final List<ExerciseModel> exercises;

  DayModel({
    required this.day,
    required this.title,
    required this.exercises,
  });
}

final List<DayModel> mockDays = [
  DayModel(
    day: "Sat",
    title: "Legs",
    exercises: [
      ExerciseModel(name: "Squat", details: "4 x 8-10 • 90s rest"),
      ExerciseModel(name: "Leg Press", details: "3 x 12 • 60s rest"),
      ExerciseModel(name: "Lunges", details: "3 x 12 • 60s rest"),
      ExerciseModel(name: "Calf Raises", details: "4 x 15 • 45s rest"),
    ],
  ),
  DayModel(
    day: "Sun",
    title: "Push",
    exercises: [
      ExerciseModel(name: "Bench Press", details: "4 x 8 • 90s rest"),
      ExerciseModel(name: "Shoulder Press", details: "3 x 10 • 60s rest"),
    ],
  ),
  DayModel(day: "Mon", title: "Rest", exercises: []),
  DayModel(day: "Tue", title: "Pull", exercises: []),
  DayModel(day: "Wed", title: "Legs", exercises: []),
  DayModel(day: "Thu", title: "Upper", exercises: []),
  DayModel(day: "Fri", title: "Rest", exercises: []),
];