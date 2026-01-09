class BotAction {
  final String? message;
  final String? display;
  final bool special;

  BotAction({this.message, this.display, this.special = false});

  factory BotAction.fromJson(Map<String, dynamic> json) {
    return BotAction(
      message: json['message'] as String?,
      display: json['display'] as String?,
      special: json['special'] is bool ? json['special'] : false,
    );
  }
}