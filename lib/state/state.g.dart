// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PlayerStateCopyWith on PlayerState {
  PlayerState copyWith({
    List<Player> players,
  }) {
    return PlayerState(
      players: players ?? this.players,
    );
  }
}

extension MatchesStateCopyWith on MatchesState {
  MatchesState copyWith({
    List<Match> matches,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
    );
  }
}

extension FirebaseStateCopyWith on FirebaseState {
  FirebaseState copyWith({
    List<StreamSubscription<dynamic>> subscriptions,
  }) {
    return FirebaseState(
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }
}

extension AppStateCopyWith on AppState {
  AppState copyWith({
    FirebaseState firebaseState,
    MatchesState matchesState,
    PlayerState playerState,
  }) {
    return AppState(
      firebaseState: firebaseState ?? this.firebaseState,
      matchesState: matchesState ?? this.matchesState,
      playerState: playerState ?? this.playerState,
    );
  }
}

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

Match _$MatchFromJson(Map<String, dynamic> json) {
  return Match(
    player1: Player.fromJson(json['player1'] as Map<String, dynamic>),
    player2: Player.fromJson(json['player2'] as Map<String, dynamic>),
    winner: _$enumDecode(_$MatchWinnerEnumMap, json['winner']),
    timestamp: Match._firebaseDateDeserializer(json['timestamp'] as Timestamp),
  );
}

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'player1': instance.player1.toJson(),
      'player2': instance.player2.toJson(),
      'winner': _$MatchWinnerEnumMap[instance.winner],
      'timestamp': Match._firebaseDateSerializer(instance.timestamp),
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
