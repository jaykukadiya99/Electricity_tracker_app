import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('electricity_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Because we are changing schema significantly from v1 to v2 in early dev,
    // we use onUpgrade to drop old tables and recreate.
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS BillingRecords');
      await db.execute('DROP TABLE IF EXISTS BillingHistory');
      await db.execute('DROP TABLE IF EXISTS TenantSetup');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE Meter (
  id INTEGER PRIMARY KEY,
  meter_name $textType,
  opening_reading $realType,
  latest_reading $realType
)
''');

    await db.execute('''
CREATE TABLE BillingHistory (
  id $idType,
  month_year $textType,
  total_cost_per_unit $realType,
  date_added $intType
)
''');

    await db.execute('''
CREATE TABLE BillingRecords (
  id $idType,
  bill_id $intType,
  meter_id $intType,
  previous_reading $realType,
  current_reading $realType,
  consumption $realType,
  amount $realType,
  FOREIGN KEY (bill_id) REFERENCES BillingHistory (id) ON DELETE CASCADE,
  FOREIGN KEY (meter_id) REFERENCES Meter (id) ON DELETE CASCADE
)
''');
  }

  // --- Meter Operations ---
  Future<void> insertMeter(Map<String, dynamic> meter) async {
    final db = await instance.database;
    await db.insert('Meter', meter);
  }

  Future<List<Map<String, dynamic>>> getAllMeters() async {
    final db = await instance.database;
    return await db.query('Meter', orderBy: 'id ASC');
  }

  Future<Map<String, dynamic>?> getMeter(int id) async {
    final db = await instance.database;
    final res = await db.query('Meter', where: 'id = ?', whereArgs: [id], limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  Future<bool> isSetupComplete() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM Meter');
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<void> updateMeterLatestReading(int id, double newReading) async {
    final db = await instance.database;
    await db.update(
      'Meter',
      {'latest_reading': newReading},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMeterName(int id, String newName) async {
    final db = await instance.database;
    await db.update(
      'Meter',
      {'meter_name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMeter(int id) async {
    final db = await instance.database;
    await db.delete('Meter', where: 'id = ?', whereArgs: [id]);
  }

  // --- Billing Operations ---
  Future<int> insertBillingHistory(Map<String, dynamic> bill) async {
    final db = await instance.database;
    return await db.insert('BillingHistory', bill);
  }

  Future<void> insertBillingRecord(Map<String, dynamic> record) async {
    final db = await instance.database;
    await db.insert('BillingRecords', record);
  }

  Future<List<Map<String, dynamic>>> getBillingHistory() async {
    final db = await instance.database;
    return await db.query('BillingHistory', orderBy: 'date_added DESC');
  }

  // Fetches grouped billing summaries for the Reports screen
  Future<List<Map<String, dynamic>>> getMonthlyReports() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT 
        h.id as bill_id, 
        h.month_year, 
        h.date_added,
        SUM(r.amount) as total_amount, 
        SUM(r.consumption) as total_consumption
      FROM BillingHistory h
      LEFT JOIN BillingRecords r ON h.id = r.bill_id
      GROUP BY h.id, h.month_year, h.date_added
      ORDER BY h.date_added DESC
    ''');
  }

  // Fetches line-item records with dynamic date bounding and meter selection
  Future<List<Map<String, dynamic>>> getFilteredReports({
    int? meterId, 
    int? startDate, 
    int? endDate,
    bool isLatestOnly = false,
  }) async {
    final db = await instance.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (meterId != null) {
      whereClause += ' AND r.meter_id = ?';
      whereArgs.add(meterId);
    }
    
    // Storing as milliseconds since epoch, so standard math works
    if (startDate != null) {
      whereClause += ' AND h.date_added >= ?';
      whereArgs.add(startDate);
    }
    
    if (endDate != null) {
      whereClause += ' AND h.date_added <= ?';
      whereArgs.add(endDate);
    }

    if (isLatestOnly) {
      return await db.rawQuery('''
        SELECT 
          r.id as record_id,
          h.month_year,
          MAX(h.date_added) as date_added,
          m.meter_name,
          r.previous_reading,
          r.current_reading,
          r.consumption,
          r.amount
        FROM BillingRecords r
        JOIN BillingHistory h ON r.bill_id = h.id
        JOIN Meter m ON r.meter_id = m.id
        WHERE $whereClause
        GROUP BY r.meter_id
        ORDER BY m.meter_name ASC
      ''', whereArgs);
    } else {
      return await db.rawQuery('''
        SELECT 
          r.id as record_id,
          h.month_year,
          h.date_added,
          m.meter_name,
          r.previous_reading,
          r.current_reading,
          r.consumption,
          r.amount
        FROM BillingRecords r
        JOIN BillingHistory h ON r.bill_id = h.id
        JOIN Meter m ON r.meter_id = m.id
        WHERE $whereClause
        ORDER BY h.date_added DESC, m.meter_name ASC
      ''', whereArgs);
    }
  }

  Future<List<Map<String, dynamic>>> getBillingRecords(int billId) async {
    final db = await instance.database;
    return await db.query('BillingRecords',
        where: 'bill_id = ?', whereArgs: [billId], orderBy: 'meter_id ASC');
  }

  Future<List<Map<String, dynamic>>> getMeterHistory(int meterId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT r.*, h.month_year, h.date_added 
      FROM BillingRecords r
      JOIN BillingHistory h ON r.bill_id = h.id
      WHERE r.meter_id = ?
      ORDER BY h.date_added DESC
    ''', [meterId]);
  }

  Future<void> deleteBill(int billId) async {
     final db = await instance.database;
     // The BillingRecords will also be deleted due to CASCADE
     await db.delete('BillingHistory', where: 'id = ?', whereArgs: [billId]);
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('BillingRecords');
    await db.delete('BillingHistory');
    await db.delete('Meter');
  }
}
