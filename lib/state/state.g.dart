// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'name': instance.name,
    };

// ignore: unused_element
Match _$MatchFromJson(Map<String, dynamic> json) {
  return Match(
    player1: Player.fromJson(json['player1'] as Map<String, dynamic>),
    player2: Player.fromJson(json['player2'] as Map<String, dynamic>),
    winner: _$enumDecode(_$MatchWinnerEnumMap, json['winner']),
  );
}

// ignore: unused_element
Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'player1': instance.player1,
      'player2': instance.player2,
      'winner': _$MatchWinnerEnumMap[instance.winner],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$MatchWinnerEnumMap = {
  MatchWinner.Player1: 'Player1',
  MatchWinner.Player2: 'Player2',
};
