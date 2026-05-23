import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates washgo.db with tables and seed data in the sqflite FFI folder.
/// Run from project root: dart run bin/create_database.dart
Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbDir = p.absolute(p.join('.dart_tool', 'sqflite_common_ffi', 'databases'));
  await Directory(dbDir).create(recursive: true);

  final dbPath = p.join(dbDir, 'washgo.db');
  final file = File(dbPath);
  if (await file.exists()) {
    await file.delete();
    stdout.writeln('Removed existing database.');
  }

  final db = await databaseFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            profile_image_path TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE services (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            duration_minutes INTEGER NOT NULL,
            vehicle_type TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE bookings (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            user_name TEXT NOT NULL,
            service_id TEXT NOT NULL,
            service_name TEXT NOT NULL,
            vehicle_type TEXT NOT NULL,
            plate_number TEXT NOT NULL,
            booking_date TEXT NOT NULL,
            booking_time TEXT NOT NULL,
            queue_number INTEGER NOT NULL,
            status TEXT NOT NULL,
            price REAL NOT NULL,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id),
            FOREIGN KEY(service_id) REFERENCES services(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE queue_settings (
            id INTEGER PRIMARY KEY,
            current_serving_queue INTEGER NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        final now = DateTime.now().toIso8601String();

        await db.insert('users', {
          'id': 'a1',
          'full_name': 'WashGo Admin',
          'email': 'admin@washgo.com',
          'password': 'admin123',
          'role': 'admin',
          'profile_image_path': null,
          'created_at': now,
        });

        final services = [
          {
            'id': 's1',
            'name': 'Basic Wash',
            'description': 'Exterior wash with quick rinse and dry.',
            'price': 120.0,
            'duration_minutes': 20,
            'vehicle_type': 'Car / Motorcycle',
          },
          {
            'id': 's2',
            'name': 'Premium Wash',
            'description': 'Exterior wash, tire shine, and interior vacuum.',
            'price': 250.0,
            'duration_minutes': 35,
            'vehicle_type': 'Car',
          },
          {
            'id': 's3',
            'name': 'Interior Cleaning',
            'description':
                'Deep interior vacuum, dashboard cleaning, and fragrance.',
            'price': 300.0,
            'duration_minutes': 45,
            'vehicle_type': 'Car / Van',
          },
          {
            'id': 's4',
            'name': 'Full Detailing',
            'description': 'Complete interior and exterior detailing service.',
            'price': 800.0,
            'duration_minutes': 90,
            'vehicle_type': 'Car / SUV / Van',
          },
        ];

        for (final s in services) {
          await db.insert('services', {
            ...s,
            'created_at': now,
            'updated_at': null,
          });
        }

        await db.insert('queue_settings', {
          'id': 1,
          'current_serving_queue': 0,
          'updated_at': now,
        });
      },
    ),
  );

  await db.close();

  stdout.writeln('washgo.db created successfully.');
  stdout.writeln('Path: $dbPath');
}
