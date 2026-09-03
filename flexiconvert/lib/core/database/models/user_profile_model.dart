import 'package:isar/isar.dart';

part 'user_profile_model.g.dart';

@collection
class UserProfileModel {
  Id id = Isar.autoIncrement; // Always 1 for the current user

  String? uid;
  String? customAvatarPath;
  int? builtInAvatarIndex;
  
  // Cache stats for quick loading
  int totalConversions = 0;
  int storageSavedBytes = 0;
  int timeSavedMinutes = 0;
}
