// ignore_for_file: non_constant_identifier_names, file_names

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String preferredVersion;

  User({this.preferredVersion = "web"}) {
    const uuid = Uuid();

    // these are always set automatically & cannot be changed after initialized
    id = uuid.v4();
  }

  String getHiveKey() => id;
}
