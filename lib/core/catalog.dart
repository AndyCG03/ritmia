part 'catalog_data.dart';

class ServiceBrand {
  const ServiceBrand(this.id, this.name, this.color, this.cancelUrl,
    {this.assetId, this.preserveColors = false, this.ai = false, this.aliases = const []});
  final String id, name, cancelUrl;
  final int color;
  final String? assetId;
  /// Multicolor marks (Gemini, Copilot, Claude…) are drawn as-is instead of tinted.
  final bool preserveColors;
  /// Listed under the "Artificial intelligence" tab.
  final bool ai;
  /// Extra lowercase search terms ("gpt", "anthropic"…).
  final List<String> aliases;
  bool get hasAsset => true;
  String get asset => 'assets/services/${assetId ?? id}.svg';
}

final Map<String, ServiceBrand> _byId = {for (final b in serviceBrands) b.id: b};
ServiceBrand? findBrand(String? id) => id == null ? null : _byId[id];

/// Featured AI services shown first in the AI tab, in display order.
const aiBrandIds = ['openai','claude','googlegemini','perplexity','microsoftcopilot',
  'midjourney','cursor','elevenlabs','poe','anthropic','huggingface','replit'];

String _fold(String v) => v.toLowerCase()
  .replaceAll(RegExp('[áà]'),'a').replaceAll(RegExp('[éè]'),'e').replaceAll(RegExp('[íì]'),'i')
  .replaceAll(RegExp('[óò]'),'o').replaceAll(RegExp('[úùü]'),'u').trim();

final List<ServiceBrand> _aiOrdered = [
  for (final id in aiBrandIds) if (_byId[id] != null) _byId[id]!,
  ...(serviceBrands.where((b) => b.ai && !aiBrandIds.contains(b.id)).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()))),
];
final List<ServiceBrand> _allOrdered = [...serviceBrands]
  ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

/// Catalog search across names and aliases; [aiOnly] limits to the AI tab.
/// Name-prefix matches rank before other matches.
List<ServiceBrand> searchBrands(String query, {bool aiOnly = false}) {
  final source = aiOnly ? _aiOrdered : _allOrdered;
  final q = _fold(query);
  if (q.isEmpty) return source;
  final prefix = <ServiceBrand>[], other = <ServiceBrand>[];
  for (final b in source) {
    final name = _fold(b.name);
    if (name.startsWith(q) || b.aliases.any((a) => a.startsWith(q))) {
      prefix.add(b);
    } else if (name.contains(q) || b.aliases.any((a) => a.contains(q))) {
      other.add(b);
    }
  }
  return [...prefix, ...other];
}
