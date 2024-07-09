import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'warehouse.db';
  static const String tableInventory = 'inventory';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Lazily instantiate the database if not already created
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get a location using path_provider
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, dbName);

    // Open/create the database at a given path
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableInventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse TEXT,
        category TEXT,
        group TEXT,
        subgroup TEXT,
        itemCode TEXT,
        itemName TEXT,
        formCode TEXT,
        documentNo TEXT,
        documentDate TEXT,
        vendorName TEXT,
        dept TEXT,
        projectCode TEXT,
        indentNo TEXT,
        indentDate TEXT,
        costCenter TEXT,
        receivedPcs INTEGER,
        receivedQty REAL,
        issuedPcs INTEGER,
        issuedQty REAL,
        itemRate REAL,
        balancePcs INTEGER,
        balanceQty REAL,
        balanceAmt REAL,
        pendingDays INTEGER,
        maxLength REAL,
        minLength REAL,
        avgLength REAL,
        length REAL,
        width REAL
      )
    ''');
  }

  Future<int> insertInventoryItem(Map<String, dynamic> item) async {
    Database db = await instance.database;
    return await db.insert(tableInventory, item);
  }

  Future<List<Map<String, dynamic>>> getAllInventoryItems() async {
    Database db = await instance.database;
    return await db.query(tableInventory);
  }

  // Add more methods as needed for CRUD operations
}
