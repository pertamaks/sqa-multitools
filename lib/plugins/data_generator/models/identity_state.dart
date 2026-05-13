import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:faker_dart/faker_dart.dart';

part 'identity_state.freezed.dart';

enum IdentityType { email, address, phone, internet, company, name }

extension IdentityTypeExtension on IdentityType {
  String get label {
    switch (this) {
      case IdentityType.email: return 'Email';
      case IdentityType.address: return 'Address';
      case IdentityType.phone: return 'Phone';
      case IdentityType.internet: return 'Internet';
      case IdentityType.company: return 'Company';
      case IdentityType.name: return 'Name';
    }
  }
}

@freezed
abstract class IdentityState with _$IdentityState {
  const factory IdentityState({
    @Default(IdentityType.email) IdentityType selectedType,
    @Default(1) int quantity,
    @Default('') String customDomain,
    @Default(FakerLocaleType.en_US) FakerLocaleType locale,
    @Default(true) bool includeFormatting,
    @Default(false) bool includeExtension,
    @Default(<IdentityType, List<List<String>>>{})
    Map<IdentityType, List<List<String>>> resultsMap,
  }) = _IdentityState;
}
