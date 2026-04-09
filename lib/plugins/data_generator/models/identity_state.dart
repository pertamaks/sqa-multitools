import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:faker_dart/faker_dart.dart';

part 'identity_state.freezed.dart';

enum IdentityType { email, address, phone, internet, company }

@freezed
abstract class IdentityState with _$IdentityState {
  const factory IdentityState({
    @Default(IdentityType.email) IdentityType selectedType,
    @Default(1) int quantity,
    @Default('') String customDomain,
    @Default(FakerLocaleType.en_US) FakerLocaleType locale,
    @Default(true) bool includeFormatting,
    @Default(false) bool includeExtension,
    @Default({}) Map<IdentityType, List<String>> resultsMap,
  }) = _IdentityState;
}
