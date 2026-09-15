// lib/ai/tests/rule_cache_test.dart

import '../bayesian/bayesian_network.dart';
import '../storage/rule_cache_service.dart';

void main() async {
  final cacheService = RuleCacheService();
  final network = BayesianNetwork();

  print('=== OFFLINE RULE STORAGE & CACHE TEST ===\n');

  // 1. Serialize and cache model rules
  await cacheService.cacheNetworkRules(network);
  print('[Storage] Bayesian CPT rules serialized and saved to local offline store.');

  // 2. Load cached rules from offline store
  final cachedData = await cacheService.getCachedRules();

  if (cachedData != null && cachedData.containsKey('clinical_risk')) {
    print('[Retrieval] Offline cache read successful!');
    print('  Cached Node Keys: ${cachedData.keys.join(', ')}');
  } else {
    print('[Error] Failed to load offline cached rules.');
  }
}