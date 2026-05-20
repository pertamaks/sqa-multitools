import '../models/dictionary_entry.dart';

class ScanCandidate {
  final String term;
  final EntryCategory category;

  ScanCandidate({required this.term, required this.category});
}

class TermScanner {
  static const Set<String> skipList = {
    // Keywords (all lowercase)
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'inherited',
    'inline',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef', 'var', 'void', 'when', 'while', 'with', 'yield',
    // Types
    'int',
    'double',
    'num',
    'string',
    'bool',
    'list',
    'map',
    'object',
    'future',
    'stream',
    'any',
    'let',
    // HTTP/REST common terms
    'http',
    'https',
    'post',
    'put',
    'delete',
    'patch',
    'options',
    'head',
    'headers',
    'body',
    'request',
    'response',
    'status',
    'code',
    'error',
    'message',
    'success',
    'data',
    'content',
    'type',
    'application',
    'json',
    'xml',
    'text',
    'html',
    'auth',
    'bearer',
    'token',
    'api',
    'v1',
    'v2',
    'v3',
    'url',
    'uri',
    'path',
    'query',
    'params',
    'localhost',
    // DB common terms
    'select',
    'insert',
    'update',
    'from',
    'where',
    'join',
    'left',
    'right',
    'inner',
    'outer',
    'group',
    'by',
    'order',
    'having',
    'limit',
    'offset',
    'index',
    'primary',
    'key',
    'foreign',
    'table',
    'column',
    'database',
    'schema',
    'sql',
    'nosql',
    'mongodb',
    'postgres', 'mysql', 'sqlite', 'oracle',
    // General technical labels
    'id',
    'uuid',
    'created',
    'updated',
    'deleted',
    'at',
    'date',
    'time',
    'timestamp',
    'name',
    'title',
    'description',
    'user',
    'admin',
    'password',
    'email',
    'phone',
    'address',
    'config',
    'settings', 'parameters', 'value', 'item', 'details', 'info',
    'version',
    'build',
    'release',
    'debug',
    'test',
    'prod',
    'production',
    'dev',
    'development',
    'stage',
    'staging',
    'local',
    'env',
    'environment',
    'server',
    'client',
    'app',
    'system', 'process', 'task', 'job', 'worker', 'queue', 'topic', 'payload',
    'pdf', 'prd', 'nfr', 'cdn',
    // Document and Business Noise terms
    'notion',
    'workspace',
    'workspaces',
    'document',
    'documents',
    'requirement',
    'requirements',
    'specification',
    'specifications',
    'overview',
    'context',
    'vision',
    'target',
    'audience',
    'creator',
    'creators',
    'influencer',
    'influencers',
    'agency',
    'agencies',
    'talent',
    'manager', 'managers', 'team', 'teams', 'role', 'roles', 'clients', 'tech',
    'stack',
    'assumption',
    'assumptions',
    'frontend',
    'backend',
    'microservice',
    'microservices',
    'gateway', 'layout', 'epic', 'priority', 'squad', 'story', 'stories',
    'active',
    'refining',
    'refinement',
    'backlog',
    'high',
    'medium',
    'low',
    'approved',
    'ready',
    'switching',
    'latency',
    'channel',
    'channels',
    'owner',
    'owners',
    'editor',
    'editors',
    'viewer',
    'viewers',
    'read',
    'only',
    'write',
    'operation',
    'operations',
    'profile',
    'link',
    'links',
    'historical',
    'history',
    'monetization',
    'donation',
    'donations',
    'billing',
    'follower',
    'followers',
    'digital',
    'good',
    'goods',
    'tip',
    'tips',
    'espresso',
    'latte',
    'mocha',
    'coffee',
    'shop',
    'theme',
    'financial',
    'tier',
    'tiers',
    'regional',
    'service',
    'services',
    'country',
    'countries',
    'factor',
    'admins',
    'keys',
    'secret',
    'secrets',
    'rest',
    'relational',
    'storage',
    'spike', 'spikes', 'transaction', 'transactions', 'asset',
    'assets',
    'delivery',
    'global',
    'load',
    'loads',
    'management',
    'guardrails',
    'degradation',
    'loop',
    'loops',
    'pipeline',
    'pipelines',
    'second',
    'seconds',
    'minute',
    'minutes',
    'hour',
    'hours',
    'day',
    'days',
    'week',
    'weeks',
    'month',
    'months',
    'year',
    'years',
    'traceability',
    'matrix',
    'board',
    'kanban',
    'linked',
    'feature',
    'features',
    'automated',
    'verification',
    'boundary',
    'interception',
    'sprint',
    'current',
    'hub',
    'social',
    'listening',
    'analytics',
    'platform',
    'empower',
    'empowers',
    'modern',
    'schedule',
    'scheduling',
    'forecast',
    'trend',
    'trends',
    'command',
    'commands',
    'bridge',
    'bridges',
    'hook',
    'hooks',
    'inference',
    'model',
    'models',
    'product',
    'engineering',
    'may',
    'see',
    'use',
    'processing',
    'fast',
  };

  /// Scans source text for potential requirements names, configurations, APIs, models, and tables.
  /// Filters findings using skipList and knownTerms.
  static List<ScanCandidate> scan(
    String text,
    List<DictionaryEntry> knownTerms,
  ) {
    if (text.isEmpty) return [];

    final existingOriginals = knownTerms
        .map((e) => e.original.toLowerCase())
        .toSet();
    final List<ScanCandidate> candidates = [];

    void maybeAddCandidate(String term, EntryCategory category) {
      final cleanTerm = term.trim();
      if (cleanTerm.isEmpty) return;

      final key = cleanTerm.toLowerCase();
      if (skipList.contains(key) ||
          existingOriginals.contains(key) ||
          candidates.any((c) => c.term.toLowerCase() == key)) {
        return;
      }
      candidates.add(ScanCandidate(term: cleanTerm, category: category));
    }

    // Heuristic 1: System / Requirement codes (e.g. REQ-101, API-99, SYS-203)
    final codeRegex = RegExp(r'\b([A-Za-z]{2,})-(\d+)\b');
    for (final match in codeRegex.allMatches(text)) {
      final fullMatch = match.group(0)!;
      final prefix = match.group(1)!.toUpperCase();
      var category = EntryCategory.general;
      if (prefix.contains('API') ||
          prefix.contains('URL') ||
          prefix.contains('URI')) {
        category = EntryCategory.endpoint;
      } else if (prefix.contains('SYS') ||
          prefix.contains('SRV') ||
          prefix.contains('SVC')) {
        category = EntryCategory.service;
      } else if (prefix.contains('DB') ||
          prefix.contains('TBL') ||
          prefix.contains('MOD')) {
        category = EntryCategory.model;
      }
      maybeAddCandidate(fullMatch, category);
    }

    // Heuristic 2: IP Addresses
    final ipRegex = RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b');
    for (final match in ipRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.config);
    }

    // Heuristic 3: Emails
    final emailRegex = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
    );
    for (final match in emailRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.general);
    }

    // Heuristic 4: Screaming Snake Case config names (e.g. JWT_SECRET_KEY, DB_PASSWORD)
    final screamSnakeRegex = RegExp(r'\b[A-Z_]{3,}_[A-Z0-9_]{2,}\b');
    for (final match in screamSnakeRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.config);
    }

    // Heuristic 5: Database snake_case style table/field patterns (e.g. transaction_history, user_id)
    final snakeCaseRegex = RegExp(r'\b[a-z]{3,}_[a-z0-9_]{3,}\b');
    for (final match in snakeCaseRegex.allMatches(text)) {
      final matchText = match.group(0)!;
      maybeAddCandidate(
        matchText,
        matchText.endsWith('_id') ? EntryCategory.field : EntryCategory.model,
      );
    }

    // Heuristic 6: PascalCase Services (e.g. PaymentGateway, ConfigNotifier)
    final pascalServiceRegex = RegExp(
      r'\b[A-Z][a-zA-Z0-9]+(?:Service|Repository|Controller|Notifier|Manager|Processor)\b',
    );
    for (final match in pascalServiceRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.service);
    }

    // Heuristic 7: PascalCase Models/Entities (e.g. InvoiceModel, ProductEntity)
    final pascalModelRegex = RegExp(
      r'\b[A-Z][a-zA-Z0-9]+(?:Model|Entity|Dto|View|Page|Table)\b',
    );
    for (final match in pascalModelRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.model);
    }

    // Heuristic 8: API endpoint URI strings (e.g. /api/v1/checkout, /users/profile)
    final endpointRegex = RegExp(r'\B/[a-zA-Z0-9_-]+/[a-zA-Z0-9_/-]+\b');
    for (final match in endpointRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.endpoint);
    }

    // Heuristic 9: Bi-CamelCase proper nouns & technical names with internal capitals (e.g. PulseVibe, PostgreSQL, GraphQL, OAuth2)
    final camelCaseProperRegex = RegExp(
      r'\b(?:[A-Z][a-z0-9]+[A-Z][a-zA-Z0-9]*|[A-Z]{2,}[a-z0-9]+[a-zA-Z0-9]*)\b',
    );
    for (final match in camelCaseProperRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.general);
    }

    // Heuristic 10: Dynamic Mid-Sentence Capitalized Proper Nouns (e.g. Redis, Stripe, Espresso, Latte, Mocha)
    // Checks that the capitalized word is not at the start of a sentence, bullet point, or markdown header.
    final properNounRegex = RegExp(r'\b[A-Z][a-z]{3,}\b');
    for (final match in properNounRegex.allMatches(text)) {
      final start = match.start;
      var isSentenceStart = false;
      if (start == 0) {
        isSentenceStart = true;
      } else {
        // Find the last non-whitespace character before start
        var idx = start - 1;
        while (idx >= 0 && RegExp(r'\s').hasMatch(text[idx])) {
          idx--;
        }
        if (idx >= 0) {
          final prevChar = text[idx];
          if (prevChar == '.' ||
              prevChar == '?' ||
              prevChar == '!' ||
              prevChar == ':' ||
              prevChar == '#' ||
              prevChar == '-' ||
              prevChar == '*') {
            isSentenceStart = true;
          }
        } else {
          isSentenceStart = true;
        }
      }

      if (!isSentenceStart) {
        maybeAddCandidate(match.group(0)!, EntryCategory.general);
      }
    }

    // Heuristic 11: Sensitive uppercase acronyms and abbreviations of length 3-6 (e.g. AES, OIDC, RBAC, MFA)
    final acronymRegex = RegExp(r'\b[A-Z]{3,6}\b');
    for (final match in acronymRegex.allMatches(text)) {
      maybeAddCandidate(match.group(0)!, EntryCategory.config);
    }

    return candidates;
  }
}
