import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import 'package:xml/xml.dart';

class FormatService {
  const FormatService();

  // --- JSON <-> YAML ---
  String jsonToYaml(String jsonString) {
    final decoded = json.decode(jsonString);
    final writer = YamlWriter();
    return writer.write(decoded);
  }

  String yamlToJson(String yamlString, {bool indent = true}) {
    final loaded = loadYaml(yamlString);
    final clean = _normalizeYamlNode(loaded);
    return indent
        ? const JsonEncoder.withIndent('  ').convert(clean)
        : json.encode(clean);
  }

  dynamic _normalizeYamlNode(dynamic node) {
    if (node is YamlMap) {
      return node.map((key, value) => MapEntry(key.toString(), _normalizeYamlNode(value)));
    } else if (node is YamlList) {
      return node.map(_normalizeYamlNode).toList();
    } else if (node is Map) {
      return node.map((key, value) => MapEntry(key.toString(), _normalizeYamlNode(value)));
    } else if (node is List) {
      return node.map(_normalizeYamlNode).toList();
    }
    return node;
  }

  // --- JSON <-> XML ---
  String jsonToXml(String jsonString, {String rootElement = 'root'}) {
    final dynamic decoded = json.decode(jsonString);
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(rootElement, nest: () {
      _buildXmlNode(builder, decoded);
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _buildXmlNode(XmlBuilder builder, dynamic data) {
    if (data is Map) {
      for (final entry in data.entries) {
        final key = _sanitizeXmlKey(entry.key.toString());
        final val = entry.value;
        if (val is List) {
          for (final item in val) {
            builder.element(key, nest: () => _buildXmlNode(builder, item));
          }
        } else if (val is Map) {
          builder.element(key, nest: () => _buildXmlNode(builder, val));
        } else {
          builder.element(key, nest: val?.toString() ?? '');
        }
      }
    } else if (data is List) {
      for (final item in data) {
        builder.element('item', nest: () => _buildXmlNode(builder, item));
      }
    } else {
      builder.text(data?.toString() ?? '');
    }
  }

  String _sanitizeXmlKey(String key) {
    var sanitized = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    if (sanitized.isEmpty || RegExp(r'^[0-9\-]').hasMatch(sanitized)) {
      sanitized = 'elem_$sanitized';
    }
    return sanitized;
  }

  String xmlToJson(String xmlString, {bool indent = true}) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;
    final map = <String, dynamic>{
      root.name.local: _xmlElementToMap(root),
    };
    return indent
        ? const JsonEncoder.withIndent('  ').convert(map)
        : json.encode(map);
  }

  dynamic _xmlElementToMap(XmlElement element) {
    final result = <String, dynamic>{};

    // Attributes
    for (final attr in element.attributes) {
      result['@${attr.name.local}'] = attr.value;
    }

    final children = element.childElements.toList();
    if (children.isEmpty) {
      final text = element.innerText.trim();
      if (result.isEmpty) {
        return text;
      }
      if (text.isNotEmpty) {
        result['#text'] = text;
      }
      return result;
    }

    // Group children by tag name
    final grouped = <String, List<XmlElement>>{};
    for (final child in children) {
      grouped.putIfAbsent(child.name.local, () => []).add(child);
    }

    for (final entry in grouped.entries) {
      final tag = entry.key;
      final elements = entry.value;
      if (elements.length > 1) {
        result[tag] = elements.map(_xmlElementToMap).toList();
      } else {
        result[tag] = _xmlElementToMap(elements.first);
      }
    }

    return result;
  }
}
