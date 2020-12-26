import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spd_pool/utils/elo.dart';

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
@JsonSerializable(nullable: false, explicitToJson: true)
class Player {
  /// The name of this player.
  final String name;

  /// The elo ranking of this player.
  @JsonKey(ignore: true)
  final double rating;

  const Player({this.name, this.rating = ELO_STARTING_RATING});

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

/// A representation of a match winner.
enum MatchWinner { Player1, Player2 }

/// A representation of a single match.
@JsonSerializable(nullable: false, explicitToJson: true)
class Match {
  /// The first player in this match.
  final Player player1;

  /// The second player in this match.
  final Player player2;

  /// The winner of this match.
  final MatchWinner winner;

  /// The elo deltas for player 1.
  @JsonKey(ignore: true)
  final double eloDelta1;

  /// The elo deltas for player 2.
  @JsonKey(ignore: true)
  final double eloDelta2;

  // The timestamp of this map.
  @JsonKey(fromJson: _firebaseDateDeserializer, toJson: _firebaseDateSerializer)
  final DateTime timestamp;

  const Match(
      {this.player1,
      this.player2,
      this.winner,
      this.timestamp,
      this.eloDelta1,
      this.eloDelta2});

  Map<String, dynamic> toJson() => _$MatchToJson(this);
  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  static DateTime _firebaseDateDeserializer(Timestamp date) => date.toDate();
  static Timestamp _firebaseDateSerializer(DateTime date) =>
      Timestamp.fromDate(date);
}
