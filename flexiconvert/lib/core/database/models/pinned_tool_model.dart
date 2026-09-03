import 'package:isar/isar.dart';

part 'pinned_tool_model.g.dart';

@collection
class PinnedTool {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String toolId;

  late String toolName;
  late String category;
  late int displayOrder;
}
