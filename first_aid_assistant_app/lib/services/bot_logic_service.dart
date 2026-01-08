import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../models/flow_models.dart';

class BotLogicService {
  Map<String, BotAction> actions = {};
  List<BotRule> rules = [];
  String? lastMessage;

  Future<void> loadFlow() async {
    final yamlString = await rootBundle.loadString('assets/ai/app_config.yml');
    final doc = loadYaml(yamlString);

    // Parsowanie akcji
    for (var a in doc['actions']) {
      final action = BotAction.fromYaml(a['action'], a);
      actions[a['action']] = action;
    }

    // Parsowanie reguł
    for (var r in doc['rules']) {
      List<Map<String, String>> steps = [];
      for (var s in r['steps']) {
        steps.add(Map<String, String>.from(s));
      }
      rules.add(BotRule(name: r['rule'], steps: steps));
    }
  }

  BotAction? getNextAction(String intent) {
    if (intent == "REPEAT" && lastMessage != null) {
      return BotAction(actionId: 'repeat', message: "Powtarzam: $lastMessage");
    }

    for (var rule in rules) {
      if (rule.steps.isNotEmpty && rule.steps[0]['intent'] == intent) {
        if (rule.steps.length > 1 && rule.steps[1].containsKey('action')) {
          String actionId = rule.steps[1]['action']!;
          var action = actions[actionId];
          
          if (action?.message != null) {
            lastMessage = action!.message;
          }
          return action;
        }
      }
    }
    return null;
  }
}