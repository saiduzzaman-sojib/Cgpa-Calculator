import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cgpa_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT UNIQUE,
        password TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE semesters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        semester_name TEXT,
        sgpa REAL,
        total_credits REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester_id INTEGER,
        course_name TEXT,
        credit REAL,
        grade TEXT,
        grade_point REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          username TEXT UNIQUE,
          password TEXT,
          image_path TEXT
        )
      ''');
    }
  }

  Future<int> registerUser(Map<String, dynamic> user) async {
    Database db = await database;
    try {
      return await db.insert('users', user);
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<int> updateProfileImage(int userId, String imagePath) async {
    Database db = await database;
    return await db.update(
      'users',
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> saveSemester(int userId, String semesterName, double sgpa, double totalCredits, List<Map<String, dynamic>> courses) async {
    Database db = await database;
    
    int semesterId = await db.insert('semesters', {
      'user_id': userId,
      'semester_name': semesterName,
      'sgpa': sgpa,
      'total_credits': totalCredits
    });

    for (var course in courses) {
      await db.insert('courses', {
        'semester_id': semesterId,
        'course_name': course['course_name'],
        'credit': course['credit'],
        'grade': course['grade'],
        'grade_point': course['grade_point']
      });
    }
    return semesterId;
  }

  Future<List<Map<String, dynamic>>> getSemesters(int userId) async {
    Database db = await database;
    return await db.query('semesters', where: 'user_id = ?', whereArgs: [userId], orderBy: 'id DESC');
  }
}