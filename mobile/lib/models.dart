double _number(dynamic value) => value is num ? value.toDouble() : 0;
int _integer(dynamic value) => value is num ? value.toInt() : 0;

class UserInfo {
  const UserInfo(
      {required this.id,
      required this.username,
      required this.nickname,
      this.gender = 0,
      this.age = 0,
      this.height = 0,
      this.weight = 0,
      this.phone = '',
      this.email = ''});
  final int id;
  final String username;
  final String nickname;
  final int gender;
  final int age;
  final double height;
  final double weight;
  final String phone;
  final String email;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: _integer(json['id']),
        username: '${json['username'] ?? ''}',
        nickname: '${json['nickname'] ?? ''}',
        gender: _integer(json['gender']),
        age: _integer(json['age']),
        height: _number(json['height']),
        weight: _number(json['weight']),
        phone: '${json['phone'] ?? ''}',
        email: '${json['email'] ?? ''}',
      );
}

class HealthRecord {
  const HealthRecord(
      {this.steps = 0,
      this.heartRate = 0,
      this.sleepHours = 0,
      this.weight = 0,
      this.systolicBp = 0,
      this.diastolicBp = 0,
      this.bloodSugar = 0,
      this.calories = 0,
      this.waterIntake = 0,
      this.mood = 3,
      this.note = ''});
  final int steps;
  final int heartRate;
  final double sleepHours;
  final double weight;
  final int systolicBp;
  final int diastolicBp;
  final double bloodSugar;
  final int calories;
  final int waterIntake;
  final int mood;
  final String note;

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        steps: _integer(json['steps']),
        heartRate: _integer(json['heartRate']),
        sleepHours: _number(json['sleepHours']),
        weight: _number(json['weight']),
        systolicBp: _integer(json['systolicBp']),
        diastolicBp: _integer(json['diastolicBp']),
        bloodSugar: _number(json['bloodSugar']),
        calories: _integer(json['calories']),
        waterIntake: _integer(json['waterIntake']),
        mood: _integer(json['mood']),
        note: '${json['note'] ?? ''}',
      );
}
