import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:intl/intl.dart';
import '../models/dev_state.dart';
import '../providers/identity_provider.dart';

part 'dev_provider.g.dart';

@Riverpod(keepAlive: true)
class DevGenerator extends _$DevGenerator {
  late Faker _faker;

  @override
  DevState build() {
    _faker = Faker.instance;
    return const DevState(
      resultsMap: <DevType, List<List<String>>>{},
      uuidHistory: <String>[],
    );
  }

  void setType(DevType type) {
    state = state.copyWith(selectedType: type);
  }

  void setJsonCategory(JsonCategory category) {
    state = state.copyWith(selectedJsonCategory: category);
  }

  void setDateCategory(DateCategory category) {
    state = state.copyWith(selectedDateCategory: category);
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }

  void setIncludeFormatting(bool value) {
    state = state.copyWith(includeFormatting: value);
  }

  void clear() {
    state = state.copyWith(
      resultsMap: <DevType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: <List<String>>[],
      },
    );
  }

  void generate() {
    final List<String> currentGeneration = [];
    final identityState = ref.read(identityProvider);
    final count = state.selectedType == DevType.uuid ? identityState.quantity : 1;

    if (state.selectedType == DevType.date) {
      currentGeneration.addAll(_generateDateFormats());
    } else {
      for (int i = 0; i < count; i++) {
        currentGeneration.add(_generateSingle());
      }
    }

    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedType] ?? []);
    final newHistory = [currentGeneration, ...currentHistory];

    if (newHistory.length > 10) {
      newHistory.removeRange(10, newHistory.length);
    }

    state = state.copyWith(
      resultsMap: <DevType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: newHistory,
      },
    );
  }

  void removeHistory(List<String> session) {
    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedType] ?? []);
    currentHistory.remove(session);
    state = state.copyWith(
      resultsMap: <DevType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: currentHistory,
      },
    );
  }

  String _generateSingle() {
    switch (state.selectedType) {
      case DevType.uuid:
        return _faker.datatype.uuid();
      case DevType.json:
        return _generateJson();
      case DevType.date:
        // This won't be reached as we handle date separately above
        return '';
    }
  }

  String _generateJson() {
    final id = _faker.datatype.number(min: 1, max: 9999);
    final status = _faker.datatype.boolean() ? 'success' : 'pending';
    final name = _faker.name.firstName();
    final company = _faker.company.companyName();

    switch (state.selectedJsonCategory) {
      case JsonCategory.simple:
        return '''{
  "id": $id,
  "name": "$name",
  "status": "$status"
}''';
      case JsonCategory.medium:
        return '''{
  "id": $id,
  "user": {
    "name": "$name",
    "email": "${name.toLowerCase()}@example.com",
    "role": "${_faker.datatype.boolean() ? 'admin' : 'user'}"
  },
  "status": "$status",
  "meta": {
    "created_at": "${DateFormat('yyyy-MM-dd').format(DateTime.now())}"
  }
}''';
      case JsonCategory.complex:
        return '''{
  "id": $id,
  "organization": "$company",
  "owner": {
    "name": "$name",
    "contact": {
      "phone": "${_faker.phoneNumber.phoneNumber()}",
      "social": ["@${name.toLowerCase()}", "@${company.split(' ')[0].toLowerCase()}"]
    }
  },
  "inventory": [
    {"sku": "${_faker.datatype.uuid().substring(0, 8)}", "price": ${_faker.datatype.number(min: 10, max: 100)}},
    {"sku": "${_faker.datatype.uuid().substring(0, 8)}", "price": ${_faker.datatype.number(min: 10, max: 100)}}
  ],
  "status": "$status",
  "flags": {
    "is_active": true,
    "internal_only": ${_faker.datatype.boolean()},
    "region": "US-EAST"
  }
}''';
    }
  }

  List<String> _generateDateFormats() {
    late DateTime date;
    if (state.selectedDateCategory == DateCategory.past) {
      date = _faker.date.past(DateTime.now());
    } else {
      date = _faker.date.future(DateTime.now());
    }

    final iso = DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(date.toUtc());
    final rfc = DateFormat(
      "EEE, dd MMM yyyy HH:mm:ss '+0000'",
    ).format(date.toUtc());
    final sql = DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
    final unix = (date.millisecondsSinceEpoch ~/ 1000).toString();
    final human = DateFormat("EEEE, MMMM d, yyyy").format(date);

    return [iso, rfc, sql, unix, human];
  }
}
