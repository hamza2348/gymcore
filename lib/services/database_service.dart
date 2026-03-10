class DatabaseService {
  static final Map<String, dynamic> _data = {
    'steps': 12,
    'calories': 351,
    'weight': 42,
    'distance': 375,
    'energy': 76,
    'level': 193,
  };
  static dynamic get(String key) => _data[key];
  static void set(String key, dynamic val) => _data[key] = val;
}
