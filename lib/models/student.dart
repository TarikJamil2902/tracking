class Student {
  final String id;
  final String name;
  final String studentClass;
  final String section;
  final String roll;
  final String parent;
  final String phone;
  final String address;
  final String? busRoute;
  final double attendancePercentage;
  final DateTime? lastAttendance;  
  final bool isPresent;

  Student({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.section,
    required this.roll,
    required this.parent,
    required this.phone,
    required this.address,
    this.busRoute,
    this.attendancePercentage = 0.0,
    this.lastAttendance,
    this.isPresent = false,
  }) {
    // Validate required fields
    if (id.isEmpty) throw ArgumentError('Student ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
    if (studentClass.isEmpty) throw ArgumentError('Class cannot be empty');
    if (section.isEmpty) throw ArgumentError('Section cannot be empty');
    if (roll.isEmpty) throw ArgumentError('Roll number cannot be empty');
    if (parent.isEmpty) throw ArgumentError('Parent name cannot be empty');
    if (phone.isEmpty) throw ArgumentError('Phone number cannot be empty');
    if (phone.length != 11) throw ArgumentError('Phone number must be 11 digits');
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      throw ArgumentError('Phone number must contain only digits');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id.trim(),
      'name': name.trim(),
      'class': studentClass,
      'section': section,
      'roll': roll.trim(),
      'parent': parent.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'busRoute': busRoute?.trim(),
      'attendancePercentage': attendancePercentage,
      'lastAttendance': lastAttendance?.toIso8601String(),  
      'isPresent': isPresent ? 1 : 0,
    };
  }

  static Student fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      name: map['name'] as String,
      studentClass: map['class'] as String,
      section: map['section'] as String,
      roll: map['roll'] as String,
      parent: map['parent'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      busRoute: map['busRoute'] as String?,
      attendancePercentage: map['attendancePercentage'] as double,
      lastAttendance: map['lastAttendance'] != null 
          ? DateTime.parse(map['lastAttendance'] as String)  
          : null,
      isPresent: map['isPresent'] == 1,
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? studentClass,
    String? section,
    String? roll,
    String? parent,
    String? phone,
    String? address,
    String? busRoute,
    double? attendancePercentage,
    DateTime? lastAttendance,  
    bool? isPresent,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentClass: studentClass ?? this.studentClass,
      section: section ?? this.section,
      roll: roll ?? this.roll,
      parent: parent ?? this.parent,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      busRoute: busRoute ?? this.busRoute,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      lastAttendance: lastAttendance ?? this.lastAttendance,
      isPresent: isPresent ?? this.isPresent,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, name: $name, class: $studentClass, section: $section, roll: $roll}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          studentClass == other.studentClass &&
          section == other.section &&
          roll == other.roll &&
          parent == other.parent &&
          phone == other.phone &&
          address == other.address &&
          busRoute == other.busRoute &&
          attendancePercentage == other.attendancePercentage &&
          lastAttendance == other.lastAttendance &&
          isPresent == other.isPresent;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      studentClass.hashCode ^
      section.hashCode ^
      roll.hashCode ^
      parent.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      busRoute.hashCode ^
      attendancePercentage.hashCode ^
      lastAttendance.hashCode ^
      isPresent.hashCode;
}