import 'package:flutter/material.dart';

class ExerciseModel {
  final String name, muscle, equipment, instruction, gifAsset;
  final int sets, reps, restSeconds;
  final bool isTime;
  final IconData icon;
  final Color color;

  const ExerciseModel({
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.instruction,
    required this.sets,
    required this.reps,
    this.restSeconds = 60,
    this.isTime = false,
    required this.icon,
    required this.color,
    this.gifAsset = '',
  });
}

class WorkoutInfo {
  final String name, category, level, description;
  final int durationMins, calories;
  final IconData icon;
  final Color color;
  final List<ExerciseModel> exercises;

  const WorkoutInfo({
    required this.name,
    required this.category,
    required this.level,
    required this.description,
    required this.durationMins,
    required this.calories,
    required this.icon,
    required this.color,
    required this.exercises,
  });
}

// ── All workouts ──────────────────────────────────────────────────────────────
class WorkoutLibrary {
  static const _green  = Color(0xFFBEFF00);
  static const _cyan   = Color(0xFF00E5FF);
  static const _orange = Color(0xFFFF6B35);
  static const _purple = Color(0xFFB388FF);
  static const _teal   = Color(0xFF80DEEA);

  static final List<WorkoutInfo> all = [fullBody, abs, cardio, strength, challenges, yoga];

  static final fullBody = WorkoutInfo(
    name: 'Full Body Workout',
    category: 'WORKOUT',
    level: 'Intermediate',
    description: 'A balanced full-body session targeting every major muscle group. Perfect for building strength and burning fat.',
    durationMins: 45,
    calories: 380,
    icon: Icons.fitness_center_rounded,
    color: _green,
    exercises: [
      ExerciseModel(name: 'Push-Ups', muscle: 'Chest · Triceps · Shoulders', equipment: 'No Equipment',
        sets: 3, reps: 15, restSeconds: 60, icon: Icons.fitness_center_rounded, color: _green,
        instruction: 'Start in a high plank. Lower your chest until it nearly touches the floor, elbows at 45°. Push up explosively. Keep core tight throughout.'),
      ExerciseModel(name: 'Bodyweight Squats', muscle: 'Quads · Glutes · Hamstrings', equipment: 'No Equipment',
        sets: 4, reps: 20, restSeconds: 90, icon: Icons.accessibility_new_rounded, color: _cyan,
        instruction: 'Feet shoulder-width apart, toes slightly out. Lower hips back and down until thighs are parallel to the floor. Drive through heels to stand.'),
      ExerciseModel(name: 'Plank Hold', muscle: 'Core · Shoulders', equipment: 'No Equipment',
        sets: 3, reps: 45, restSeconds: 60, isTime: true, icon: Icons.horizontal_rule_rounded, color: _green,
        instruction: 'Forearms on floor, elbows under shoulders. Body in a straight line from head to heels. Breathe steadily. Do not let hips sag.'),
      ExerciseModel(name: 'Reverse Lunges', muscle: 'Quads · Hamstrings · Glutes', equipment: 'No Equipment',
        sets: 3, reps: 12, restSeconds: 60, icon: Icons.directions_walk_rounded, color: _orange,
        instruction: 'Step one foot back and lower the back knee toward the floor. Both knees at 90°. Push through front heel to return. Alternate legs each rep.'),
      ExerciseModel(name: 'Mountain Climbers', muscle: 'Core · Cardio', equipment: 'No Equipment',
        sets: 3, reps: 30, restSeconds: 60, isTime: true, icon: Icons.local_fire_department_rounded, color: _green,
        instruction: 'High plank position. Drive knees to chest alternately as fast as possible. Keep hips level and core braced throughout.'),
      ExerciseModel(name: 'Glute Bridges', muscle: 'Glutes · Hamstrings · Core', equipment: 'No Equipment',
        sets: 3, reps: 20, restSeconds: 45, icon: Icons.airline_seat_flat_rounded, color: _purple,
        instruction: 'Lie on back, knees bent, feet flat. Drive hips up by squeezing glutes. Hold 1 second at top. Lower slowly. Keep shoulders on floor.'),
      ExerciseModel(name: 'Burpees', muscle: 'Full Body · Cardio', equipment: 'No Equipment',
        sets: 3, reps: 10, restSeconds: 90, icon: Icons.bolt_rounded, color: _orange,
        instruction: 'From standing, squat down, jump feet back to plank, perform a push-up, jump feet forward, then explode upward with arms overhead.'),
    ],
  );

  static final abs = WorkoutInfo(
    name: 'ABS Shred',
    category: 'CORE',
    level: 'Advanced',
    description: 'Intense core-focused workout targeting upper abs, lower abs, and obliques for a defined midsection.',
    durationMins: 30,
    calories: 220,
    icon: Icons.sports_gymnastics_rounded,
    color: _cyan,
    exercises: [
      ExerciseModel(name: 'Crunches', muscle: 'Upper Abs', equipment: 'No Equipment',
        sets: 4, reps: 25, restSeconds: 40, icon: Icons.fitness_center_rounded, color: _cyan,
        instruction: 'Lie on back, knees bent, hands lightly behind head. Curl shoulders toward knees using abs only. Lower slowly. Do not pull neck.'),
      ExerciseModel(name: 'Leg Raises', muscle: 'Lower Abs · Hip Flexors', equipment: 'No Equipment',
        sets: 3, reps: 15, restSeconds: 50, icon: Icons.height_rounded, color: _green,
        instruction: 'Lie flat, hands under hips. Keep legs straight and raise them to 90°. Lower slowly without letting them touch the floor.'),
      ExerciseModel(name: 'Russian Twists', muscle: 'Obliques', equipment: 'Optional Weight',
        sets: 3, reps: 20, restSeconds: 45, icon: Icons.rotate_right_rounded, color: _orange,
        instruction: 'Sit with knees bent, lean back 45°. Hold hands together. Rotate torso side to side, touching the floor each rep.'),
      ExerciseModel(name: 'Bicycle Crunches', muscle: 'Full Abs · Obliques', equipment: 'No Equipment',
        sets: 3, reps: 30, restSeconds: 45, icon: Icons.directions_bike_rounded, color: _cyan,
        instruction: 'Lie back, hands behind head. Bring opposite elbow to knee while extending the other leg. Alternate in a smooth pedaling motion.'),
      ExerciseModel(name: 'Dead Bug', muscle: 'Deep Core', equipment: 'No Equipment',
        sets: 3, reps: 12, restSeconds: 40, icon: Icons.bug_report_rounded, color: _purple,
        instruction: 'Lie on back, arms up, knees at 90°. Lower opposite arm and leg simultaneously toward the floor. Return and repeat. Keep lower back pressed to mat.'),
      ExerciseModel(name: 'Plank to Hip Dip', muscle: 'Obliques · Core', equipment: 'No Equipment',
        sets: 3, reps: 20, restSeconds: 50, icon: Icons.horizontal_rule_rounded, color: _cyan,
        instruction: 'Start in forearm plank. Rotate hips to one side, dipping them toward the floor. Return to center and repeat to the other side.'),
      ExerciseModel(name: 'Flutter Kicks', muscle: 'Lower Abs', equipment: 'No Equipment',
        sets: 3, reps: 30, restSeconds: 40, isTime: true, icon: Icons.waves_rounded, color: _green,
        instruction: 'Lie flat, lift both legs 6 inches off ground. Alternate kicking up and down in small, fast movements. Keep lower back pressed to mat.'),
    ],
  );

  static final cardio = WorkoutInfo(
    name: 'Cardio Blast',
    category: 'CARDIO',
    level: 'Beginner',
    description: 'High-energy cardio circuit to spike your heart rate, burn fat, and boost endurance. No equipment needed.',
    durationMins: 40,
    calories: 450,
    icon: Icons.directions_run_rounded,
    color: _orange,
    exercises: [
      ExerciseModel(name: 'Jumping Jacks', muscle: 'Full Body · Cardio', equipment: 'No Equipment',
        sets: 3, reps: 40, restSeconds: 30, isTime: true, icon: Icons.directions_run_rounded, color: _green,
        instruction: 'Start with feet together. Jump while spreading legs and raising arms overhead. Jump back to start. Keep a fast, steady rhythm.'),
      ExerciseModel(name: 'High Knees', muscle: 'Core · Quads · Cardio', equipment: 'No Equipment',
        sets: 3, reps: 45, restSeconds: 30, isTime: true, icon: Icons.local_fire_department_rounded, color: _orange,
        instruction: 'Run in place lifting knees to hip level. Pump arms in sync. Land softly on balls of feet. Keep an upright posture.'),
      ExerciseModel(name: 'Skater Jumps', muscle: 'Glutes · Balance', equipment: 'No Equipment',
        sets: 3, reps: 20, restSeconds: 45, icon: Icons.sports_gymnastics_rounded, color: _cyan,
        instruction: 'Leap laterally from one foot to the other, swinging arms across your body. Land softly and hold for a moment before jumping again.'),
      ExerciseModel(name: 'Butt Kicks', muscle: 'Hamstrings · Cardio', equipment: 'No Equipment',
        sets: 3, reps: 40, restSeconds: 30, isTime: true, icon: Icons.directions_run_rounded, color: _orange,
        instruction: 'Jog in place kicking heels up toward your glutes. Pump arms and keep torso upright. Maintain a fast pace.'),
      ExerciseModel(name: 'Box Jumps', muscle: 'Legs · Power', equipment: 'Box or Step',
        sets: 4, reps: 10, restSeconds: 90, icon: Icons.upload_rounded, color: _green,
        instruction: 'Stand before box. Bend knees and swing arms. Jump onto box landing softly on both feet. Stand fully. Step down and repeat.'),
      ExerciseModel(name: 'Sprint in Place', muscle: 'Full Cardio', equipment: 'No Equipment',
        sets: 5, reps: 20, restSeconds: 20, isTime: true, icon: Icons.bolt_rounded, color: _orange,
        instruction: 'Sprint in place at maximum effort. Drive knees high and pump arms hard. Rest briefly between sets. Pure intensity.'),
    ],
  );

  static final strength = WorkoutInfo(
    name: 'Strength Training',
    category: 'STRENGTH',
    level: 'Advanced',
    description: 'Classic compound lifts for maximum strength and muscle gains. Requires gym equipment.',
    durationMins: 60,
    calories: 320,
    icon: Icons.hardware_rounded,
    color: _purple,
    exercises: [
      ExerciseModel(name: 'Barbell Bench Press', muscle: 'Chest · Triceps · Shoulders', equipment: 'Barbell + Bench',
        sets: 4, reps: 8, restSeconds: 120, icon: Icons.fitness_center_rounded, color: _green,
        instruction: 'Lie on bench. Grip bar slightly wider than shoulders. Lower to chest with control. Press explosively. Do not bounce off chest.'),
      ExerciseModel(name: 'Deadlift', muscle: 'Back · Hamstrings · Glutes', equipment: 'Barbell',
        sets: 4, reps: 5, restSeconds: 180, icon: Icons.arrow_upward_rounded, color: _orange,
        instruction: 'Feet hip-width, bar over midfoot. Hinge at hips, keep back flat. Grip bar. Drive through floor to stand. Hinge back down with control.'),
      ExerciseModel(name: 'Barbell Back Squat', muscle: 'Quads · Glutes · Core', equipment: 'Barbell + Rack',
        sets: 4, reps: 8, restSeconds: 150, icon: Icons.accessibility_new_rounded, color: _green,
        instruction: 'Bar on upper traps. Feet shoulder-width. Brace core, push knees out and sit to parallel. Drive through heels. Keep chest up.'),
      ExerciseModel(name: 'Pull-Ups', muscle: 'Lats · Biceps · Core', equipment: 'Pull-Up Bar',
        sets: 3, reps: 8, restSeconds: 90, icon: Icons.upgrade_rounded, color: _cyan,
        instruction: 'Overhand grip, slightly wider than shoulders. Pull chest toward bar by driving elbows down. Lower under full control. Full hang between reps.'),
      ExerciseModel(name: 'Overhead Press', muscle: 'Shoulders · Triceps', equipment: 'Barbell or Dumbbells',
        sets: 3, reps: 10, restSeconds: 90, icon: Icons.arrow_upward_rounded, color: _purple,
        instruction: 'Bar at collarbone, grip shoulder-width. Press overhead until elbows lock out. Lower to collarbone. Keep core tight. Do not lean back.'),
      ExerciseModel(name: 'Bent-Over Row', muscle: 'Upper Back · Biceps', equipment: 'Barbell',
        sets: 4, reps: 10, restSeconds: 90, icon: Icons.rowing_rounded, color: _green,
        instruction: 'Hinge at hips, back parallel to floor. Pull bar toward lower chest, elbows back. Squeeze shoulder blades at top. Lower under control.'),
    ],
  );

  static final challenges = WorkoutInfo(
    name: 'Daily Challenges',
    category: 'CHALLENGE',
    level: 'Expert',
    description: 'Grueling challenge-style workouts to push your limits. These are meant to be hard.',
    durationMins: 50,
    calories: 500,
    icon: Icons.emoji_events_rounded,
    color: _green,
    exercises: [
      ExerciseModel(name: '100 Push-Up Challenge', muscle: 'Chest · Arms', equipment: 'No Equipment',
        sets: 5, reps: 20, restSeconds: 60, icon: Icons.emoji_events_rounded, color: _green,
        instruction: 'Complete 100 push-ups in 5 sets of 20. Take exactly 60s rest. If you fail a set, rest 30s extra and continue where you left off.'),
      ExerciseModel(name: 'Wall Sit Hold', muscle: 'Quads · Mental Endurance', equipment: 'Wall',
        sets: 3, reps: 90, restSeconds: 60, isTime: true, icon: Icons.timer_rounded, color: _orange,
        instruction: 'Back flat against wall. Slide down until thighs are parallel. Arms extended forward. Hold and breathe steadily. Do not touch thighs.'),
      ExerciseModel(name: 'Burpee Ladder', muscle: 'Full Body', equipment: 'No Equipment',
        sets: 4, reps: 15, restSeconds: 90, icon: Icons.bolt_rounded, color: _cyan,
        instruction: 'Complete each set without stopping. Full push-up at bottom, clap overhead at top. Each set you do 2 more reps than the last.'),
      ExerciseModel(name: 'Jump Squat Tabata', muscle: 'Legs · Power', equipment: 'No Equipment',
        sets: 8, reps: 20, restSeconds: 10, isTime: true, icon: Icons.local_fire_department_rounded, color: _green,
        instruction: '20s max effort, 10s rest. Squat deep and explode upward. Land softly. This is Tabata — every set must be maximum intensity.'),
      ExerciseModel(name: 'Plank to Failure', muscle: 'Core · Shoulders', equipment: 'No Equipment',
        sets: 3, reps: 120, restSeconds: 60, isTime: true, icon: Icons.horizontal_rule_rounded, color: _orange,
        instruction: 'Get into forearm plank and hold until you physically cannot hold it any longer. Rest. Repeat. Track your time each set.'),
    ],
  );

  static final yoga = WorkoutInfo(
    name: 'Yoga & Stretch',
    category: 'FLEXIBILITY',
    level: 'Beginner',
    description: 'Relax, restore, and improve flexibility with this gentle yoga flow. Great for rest days and recovery.',
    durationMins: 35,
    calories: 160,
    icon: Icons.self_improvement_rounded,
    color: _teal,
    exercises: [
      ExerciseModel(name: 'Sun Salutation A', muscle: 'Full Body · Mobility', equipment: 'Yoga Mat',
        sets: 3, reps: 60, restSeconds: 20, isTime: true, icon: Icons.wb_sunny_rounded, color: _teal,
        instruction: 'Flow: Mountain → Forward Fold → Half Lift → Plank → Chaturanga → Upward Dog → Downward Dog → repeat. Breathe deeply at each pose.'),
      ExerciseModel(name: 'Warrior I', muscle: 'Hips · Shoulders · Balance', equipment: 'Yoga Mat',
        sets: 2, reps: 45, restSeconds: 15, isTime: true, icon: Icons.sports_martial_arts_rounded, color: _purple,
        instruction: 'Step one foot back. Front knee at 90°. Raise arms overhead, palms facing. Square hips forward. Hold, breathe, and feel the stretch.'),
      ExerciseModel(name: 'Downward Dog', muscle: 'Hamstrings · Calves · Back', equipment: 'Yoga Mat',
        sets: 3, reps: 30, restSeconds: 15, isTime: true, icon: Icons.pets_rounded, color: _teal,
        instruction: 'From plank, push hips up and back forming an inverted V. Press heels toward floor. Spread fingers wide and push through palms.'),
      ExerciseModel(name: 'Pigeon Pose', muscle: 'Hip Flexors · Glutes', equipment: 'Yoga Mat',
        sets: 2, reps: 60, restSeconds: 15, isTime: true, icon: Icons.airline_seat_flat_rounded, color: _purple,
        instruction: 'Bring one shin forward across mat. Extend back leg behind. Gently lower hips. Fold forward over front leg for a deeper stretch. Switch sides.'),
      ExerciseModel(name: 'Child\'s Pose', muscle: 'Lower Back · Hips', equipment: 'Yoga Mat',
        sets: 2, reps: 60, restSeconds: 0, isTime: true, icon: Icons.self_improvement_rounded, color: _teal,
        instruction: 'Kneel and sit back on heels. Stretch arms forward on mat. Lower forehead to mat. Breathe into your lower back. Complete surrender.'),
      ExerciseModel(name: 'Seated Spinal Twist', muscle: 'Spine · Obliques', equipment: 'Yoga Mat',
        sets: 2, reps: 40, restSeconds: 10, isTime: true, icon: Icons.rotate_right_rounded, color: _purple,
        instruction: 'Sit with legs extended. Bend one knee, place foot outside opposite thigh. Twist torso toward bent knee, hook elbow on outside. Switch sides.'),
    ],
  );
}
