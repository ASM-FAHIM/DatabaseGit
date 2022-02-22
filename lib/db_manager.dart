import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DbManager {
  //column names
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        designation TEXT,
        salary TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

//initialize db
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'employee.db',
      version: 2,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }

//create user
  static Future<int> createUser(
      String name, String? designation, String? salary) async {
    final db = await DbManager.db();

    final data = {'name': name, 'designation': designation, "salary": salary};
    final id = await db.insert('employees', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // all users list
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await DbManager.db();
    return db.query('employees', orderBy: "id");
  }

  //A single user by id
  // static Future<List<Map<String, dynamic>>> getItem(int id) async {
  //   final db = await DbManager.db();
  //   return db.query('employees', where: "id = ?", whereArgs: [id], limit: 1);
  // }

  // Update user
  static Future<int> updateUser(
      int id, String name, String? designation, String? salary) async {
    final db = await DbManager.db();

    final data = {
      'name': name,
      'designation': designation,
      "salary": salary,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('employees', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteUser(int id) async {
    final db = await DbManager.db();
    try {
      await db.delete("employees", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
