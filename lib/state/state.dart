import 'dart:async';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

@CopyWith()
class PlayerState {
  final List<Player> players;

  const PlayerState({this.players = const []});
}

@CopyWith()
class MatchesState {
  final List<Match> matches;

  const MatchesState({this.matches = const []});
}

@CopyWith()
class FirebaseState {
  final List<StreamSubscription> subscriptions;

  const FirebaseState({this.subscriptions = const []});
}

/// A representation of the app state.
@CopyWith()
@immutable
class AppState {
  final PlayerState playerState;
  final MatchesState matchesState;
  final FirebaseState firebaseState;

  const AppState({
    this.playerState = const PlayerState(),
    this.matchesState = const MatchesState(),
    this.firebaseState = const FirebaseState(),
  });
}

/// A representation of a single player.
@immutable
@JsonSerializable(nullable: false)
class Player {
  /// The name of this player.
  final String name;

  /// The elo ranking of this player.
  @JsonKey(ignore: true)
  final double ranking;

  const Player({this.name, this.ranking = 0});

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

/// A representation of a match winner.
enum MatchWinner { Player1, Player2 }

/// A representation of a single match.
@immutable
@JsonSerializable(nullable: false)
class Match {
  /// The first player in this match.
  final Player player1;

  /// The second player in this match.
  final Player player2;

  /// The winner of this match.
  final MatchWinner winner;

  const Match({this.player1, this.player2, this.winner});
}
