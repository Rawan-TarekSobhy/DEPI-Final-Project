// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  MedicationsDao? _medicationsDaoInstance;

  MedicationScheduleDao? _medicationScheduleDaoInstance;

  IntakeRecordDao? _intakeRecordDaoInstance;

  DocumentsDao? _documentsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`userId` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `email` TEXT NOT NULL, `password` TEXT NOT NULL, `gender` TEXT, `age` TEXT, `bloodType` TEXT, `weight` TEXT, `height` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `medications` (`medId` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` INTEGER NOT NULL, `name` TEXT NOT NULL, `dosage` TEXT, `frequency` TEXT, `durationOfUse` TEXT, `notes` TEXT, `imageUrl` TEXT, FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON UPDATE CASCADE ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `medication_schedule` (`scheduleId` INTEGER PRIMARY KEY AUTOINCREMENT, `medId` INTEGER NOT NULL, `intakeTime` TEXT NOT NULL, FOREIGN KEY (`medId`) REFERENCES `medications` (`medId`) ON UPDATE CASCADE ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `intake_records` (`recordId` INTEGER PRIMARY KEY AUTOINCREMENT, `medId` INTEGER NOT NULL, `takenAt` TEXT, `status` TEXT NOT NULL, FOREIGN KEY (`medId`) REFERENCES `medications` (`medId`) ON UPDATE CASCADE ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `documents` (`docId` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` INTEGER NOT NULL, `fileUrl` TEXT NOT NULL, `fileName` TEXT NOT NULL, FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON UPDATE CASCADE ON DELETE CASCADE)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  MedicationsDao get medicationsDao {
    return _medicationsDaoInstance ??=
        _$MedicationsDao(database, changeListener);
  }

  @override
  MedicationScheduleDao get medicationScheduleDao {
    return _medicationScheduleDaoInstance ??=
        _$MedicationScheduleDao(database, changeListener);
  }

  @override
  IntakeRecordDao get intakeRecordDao {
    return _intakeRecordDaoInstance ??=
        _$IntakeRecordDao(database, changeListener);
  }

  @override
  DocumentsDao get documentsDao {
    return _documentsDaoInstance ??= _$DocumentsDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}

class _$MedicationsDao extends MedicationsDao {
  _$MedicationsDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}

class _$MedicationScheduleDao extends MedicationScheduleDao {
  _$MedicationScheduleDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}

class _$IntakeRecordDao extends IntakeRecordDao {
  _$IntakeRecordDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}

class _$DocumentsDao extends DocumentsDao {
  _$DocumentsDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}
