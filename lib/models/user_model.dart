class UserProfile {
  String name;
  String email;
  String password;
  String gender;      // 'male' | 'female'
  double weight;      // kg
  String fitnessGoal; // e.g. 'Lose Weight'
  int age;

  // Progress tracking
  Map<String, bool> workoutCalendar; // 'yyyy-MM-dd' -> completed
  Map<String, int>  workoutDuration; // 'yyyy-MM-dd' -> minutes
  Map<String, int>  workoutCalories; // 'yyyy-MM-dd' -> calories
  List<String>      completedWorkouts; // workout names

  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.weight,
    required this.fitnessGoal,
    this.age = 25,
    Map<String, bool>?  workoutCalendar,
    Map<String, int>?   workoutDuration,
    Map<String, int>?   workoutCalories,
    List<String>?       completedWorkouts,
  })  : workoutCalendar  = workoutCalendar  ?? {},
        workoutDuration  = workoutDuration  ?? {},
        workoutCalories  = workoutCalories  ?? {},
        completedWorkouts = completedWorkouts ?? [];

  String get firstName => name.split(' ').first;
}

/// Very simple in-memory "auth" service.
class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  final Map<String, UserProfile> _users = {};
  UserProfile? currentUser;

  /// Sign up – returns null on success, error string on fail.
  String? signUp(String name, String email, String password,
      String gender, double weight, String goal, int age) {
    if (_users.containsKey(email.toLowerCase()))
      return 'Email already registered';
    final user = UserProfile(
        name: name, email: email, password: password,
        gender: gender, weight: weight, fitnessGoal: goal, age: age);
    _users[email.toLowerCase()] = user;
    currentUser = user;
    return null;
  }

  /// Login – returns null on success, error string on fail.
  String? login(String email, String password) {
    final u = _users[email.toLowerCase()];
    if (u == null) return 'No account found for this email';
    if (u.password != password) return 'Incorrect password';
    currentUser = u;
    return null;
  }

  void logout() => currentUser = null;

  void markWorkoutComplete(String workoutName, int durationMins, int calories) {
    final u = currentUser;
    if (u == null) return;
    final key = _todayKey();
    u.workoutCalendar[key]  = true;
    u.workoutDuration[key]  = (u.workoutDuration[key] ?? 0) + durationMins;
    u.workoutCalories[key]  = (u.workoutCalories[key] ?? 0) + calories;
    if (!u.completedWorkouts.contains(workoutName))
      u.completedWorkouts.add(workoutName);
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  static String keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}
