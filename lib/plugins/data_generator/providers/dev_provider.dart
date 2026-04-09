import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:intl/intl.dart';
import '../models/dev_state.dart';

part 'dev_provider.g.dart';

@Riverpod(keepAlive: true)
class DevGenerator extends _$DevGenerator {
  late Faker _faker;

  @override
  DevState build() {
    _faker = Faker.instance;
    return const DevState(
      resultsMap: <DevType, List<String>>{},
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

  void clear() {
    state = state.copyWith(
      resultsMap: <DevType, List<String>>{
        ...state.resultsMap,
        state.selectedType: <String>[],
      },
      uuidHistory: state.selectedType == DevType.uuid
          ? <String>[]
          : state.uuidHistory,
    );
  }

  void generate() {
    final List<String> results = [];

    // For Dev tab, we currently only generate one set of items (count=1)
    // per user feedback: "count is only for identity generator for now"
    if (state.selectedType == DevType.date) {
      results.addAll(_generateDateFormats());
    } else {
      results.add(_generateSingle());
    }

    var history = state.uuidHistory;
    if (state.selectedType == DevType.uuid) {
      history = [...results, ...history].take(10).toList();
    }

    state = state.copyWith(
      resultsMap: <DevType, List<String>>{
        ...state.resultsMap,
        state.selectedType: results,
      },
      uuidHistory: history,
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
