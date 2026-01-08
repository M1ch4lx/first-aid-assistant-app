class BotAction {
  final String actionId;
  final String? message;
  final String? display;

  BotAction({required this.actionId, this.message, this.display});

  factory BotAction.fromYaml(String id, Map map) {
    return BotAction(
      actionId: id,
      message: map['message'],
      display: map['display'],
    );
  }
}

class BotRule {
  final String name;
  final List<Map<String, String>> steps;

  BotRule({required this.name, required this.steps});
}