import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DatabaseHelper {
  static const _databaseName = "school.db";
  static const _databaseVersion = 1;

  static const table = 'students';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnClass = 'class';
  static const columnSection = 'section';
  static const columnRoll = 'roll';
  static const columnParent = 'parent';
  static const columnPhone = 'phone';
  static const columnAddress = 'address';
  static const columnBusRoute = 'busRoute';
  static const columnAttendancePercentage = 'attendancePercentage';
  static const columnLastAttendance = 'lastAttendance';
  static const columnIsPresent = 'isPresent';

  // Make the DatabaseHelper class a singleton
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor(); // Private named constructor to prevent multiple instances.

  // Factory constructor to return the same instance
  factory DatabaseHelper() {
    return _instance;
  }

  // Get the database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $table(
            $columnId TEXT PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnClass TEXT NOT NULL,
            $columnSection TEXT NOT NULL,
            $columnRoll TEXT NOT NULL,
            $columnParent TEXT NOT NULL,
            $columnPhone TEXT NOT NULL,
            $columnAddress TEXT NOT NULL,
            $columnBusRoute TEXT,
            $columnAttendancePercentage REAL DEFAULT 0.0,
            $columnLastAttendance TEXT,
            $columnIsPresent INTEGER DEFAULT 0
          )
          ''');
      },
      version: _databaseVersion,
    );
  }

  // Check if student exists
  Future<bool> checkStudentExists(String id) async {
    try {
      final Database db = await database;
      final result = await db.query(
        table,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking student existence: $e');
    }
  }

  // Insert a student into the database
  Future<String> insertStudent(Student student) async {
    try {
      final Database db = await database;
      await db.insert(
        table,
        student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return student.id;
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        throw Exception('Student ID already exists');
      }
      throw Exception('Failed to insert student: $e');
    }
  }

  // Get all students
  Future<List<Student>> getStudents() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        table,
        orderBy: '$columnClass ASC, $columnSection ASC, $columnRoll ASC',
      );
      return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get students: $e');
    }
  }

  // Get a specific student by ID
  Future<Student?> getStudent(String id) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        table,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return Student.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  // Update a student
  Future<void> updateStudent(Student student) async {
    try {
      final Database db = await database;
      final count = await db.update(
        table,
        student.toMap(),
        where: '$columnId = ?',
        whereArgs: [student.id],
      );
      if (count == 0) {
        throw Exception('Student not found');
      }
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  // Delete a student
  Future<void> deleteStudent(String id) async {
    try {
      final Database db = await database;
      final count = await db.delete(
        table,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw Exception('Student not found');
      }
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // Update student attendance
  Future<void> updateAttendance(String id, bool isPresent) async {
    try {
      final Database db = await database;
      final now = DateTime.now();

      // Get current attendance percentage
      final student = await getStudent(id);
      if (student == null) {
        throw Exception('Student not found');
      }

      // Calculate new attendance percentage
      double newPercentage = student.attendancePercentage;
      if (student.lastAttendance != null) {
        final lastDate = DateTime.parse(student.lastAttendance! as String);
        if (lastDate.year != now.year ||
            lastDate.month != now.month ||
            lastDate.day != now.day) {
          // Only update percentage if it's a different day
          final totalDays = await getTotalAttendanceDays(id);
          newPercentage =
              (totalDays + (isPresent ? 1 : 0)) / (totalDays + 1) * 100;
        }
      } else {
        newPercentage = isPresent ? 100 : 0;
      }

      final count = await db.update(
        table,
        {
          columnIsPresent: isPresent ? 1 : 0,
          columnLastAttendance: now.toIso8601String(),
          columnAttendancePercentage: newPercentage,
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception('Student not found');
      }
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  // Get total attendance days for a student
  Future<int> getTotalAttendanceDays(String id) async {
    try {
      final Database db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM $table
        WHERE $columnId = ? AND $columnLastAttendance IS NOT NULL
      ''', [id]);
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get total attendance days: $e');
    }
  }

  // Search students with filters
  Future<List<Student>> searchStudents({
    String? query,
    String? studentClass,
    String? section,
    bool? presentOnly,
  }) async {
    try {
      final Database db = await database;
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (query != null && query.isNotEmpty) {
        whereClause += ''' AND (
          $columnId LIKE ? OR 
          $columnName LIKE ? OR 
          $columnParent LIKE ? OR 
          $columnPhone LIKE ? OR
          $columnRoll LIKE ?
        )''';
        final searchPattern = '%$query%';
        whereArgs.addAll([
          searchPattern,
          searchPattern,
          searchPattern,
          searchPattern,
          searchPattern,
        ]);
      }

      if (studentClass != null && studentClass != 'All') {
        whereClause += ' AND $columnClass = ?';
        whereArgs.add(studentClass);
      }

      if (section != null && section != 'All') {
        whereClause += ' AND $columnSection = ?';
        whereArgs.add(section);
      }

      if (presentOnly == true) {
        whereClause += ' AND $columnIsPresent = 1';
      }

      final List<Map<String, dynamic>> maps = await db.query(
        table,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: '$columnClass ASC, $columnSection ASC, $columnRoll ASC',
      );

      return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to search students: $e');
    }
  }

  // Get classwise student count
  Future<Map<String, int>> getClasswiseCount() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT $columnClass, COUNT(*) as count
        FROM $table
        GROUP BY $columnClass
        ORDER BY $columnClass
      ''');

      return Map.fromEntries(result.map(
          (row) => MapEntry(row[columnClass] as String, row['count'] as int)));
    } catch (e) {
      throw Exception('Failed to get classwise count: $e');
    }
  }

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
