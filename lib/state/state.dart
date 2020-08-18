import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

/// A representation of the app state.
class AppState {
  /// A list of players.
  final List<Player> players;

  /// A list of matches.
  final List<Match> matches;

  /// A list of Firestore subscriptions.
  final List<StreamSubscription> subscriptions;

  const AppState(
      {this.players = const [],
      this.matches = const [],
      this.subscriptions = const []});
}

@immutable
@JsonSerializable(nullable: false)

/// A representation of a single player.
class Player {
  /// The name of this player.
  final String name;

  /// The elo ranking of this player.
  final double ranking;

  const Player({this.name, this.ranking});

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

/// A representation of a match winner.
enum MatchWinner { Player1, Player2 }

@immutable
@JsonSerializable(nullable: false)

/// A representation of a single match.
class Match {
  /// The first player in this match.
  final Player player1;

  /// The second player in this match.
  final Player player2;

  /// The winner of this match.
  final MatchWinner winner;

  const Match({this.player1, this.player2, this.winner});
}
