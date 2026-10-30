enum ConversionCategory {
  encoding,
  format,
  jwt,
  hash,
  textCase,
}

enum EncodingSubMode {
  base64,
  url,
  html,
  hex,
  binary,
}

enum FormatSubMode {
  jsonToYaml,
  yamlToJson,
  jsonToXml,
  xmlToJson,
}

enum TextCaseSubMode {
  camelCase,
  pascalCase,
  snakeCase,
  kebabCase,
  constantCase,
  titleCase,
  cleanDuplicates,
  sortLines,
  trimLines,
}

enum ConversionDirection {
  forward, // e.g. Encode or To Format
  reverse, // e.g. Decode or From Format
}
