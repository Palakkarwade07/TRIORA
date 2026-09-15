// lib/ai/storage/rule_cache_service.dart

import 'dart:convert';
import '../bayesian/bayesian_network.dart';

class RuleCacheService {
  final Map<String, String> _localStore = {};

  /// Serializes and caches Bayesian CPT rules locally for offline triage
  Future<void> cacheNetworkRules(BayesianNetwork network) async {
    final Map<String, dynamic> serializedData = {};

    network.nodes.forEach((nodeId, node) {
      final nodeCptMap = <String, dynamic>{};
      node.cpt.forEach((cptKey, stateMap) {
        final stateData = <String, dynamic>{};
        stateMap.forEach((state, meta) {
          stateData[state] = {
            'value': meta.value,
            'origin': meta.origin.toString(),
            'sourceCitation': meta.sourceCitation,
          };
        });
        nodeCptMap[cptKey] = stateData;
      });
      serializedData[nodeId] = nodeCptMap;
    });

    _localStore['bayesian_cpt_rules'] = jsonEncode(serializedData);
  }

  /// Restores cached probability tables from local offline storage
  Future<Map<String, dynamic>?> getCachedRules() async {
    final rawJson = _localStore['bayesian_cpt_rules'];
    if (rawJson == null) return null;
    return jsonDecode(rawJson) as Map<String, dynamic>;
  }
}