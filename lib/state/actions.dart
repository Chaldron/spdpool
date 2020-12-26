import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spd_pool/state/state.dart';
import 'package:spd_pool/utils/elo.dart';

const String _PLAYERS_COLLECTION = 'players';
const String _MATCHES_COLLECTION = 'matches';

// -- Player Actions

/// An action to register a new player.
class RegisterPlayerAction extends ReduxAction<AppState> {
  final Player player;

  RegisterPlayerAction({this.player});

  @override
  Future<AppState> reduce() async {
    // Add this player to the Firestore database.
    // They should automatically appear in the player list due to the one-way binding.
    await Firestore.instance
        .collection(_PLAYERS_COLLECTION)
        .add(player.toJson());

    return null;
  }

  @override
  void after() {
    // Update rankings after adding a new player
    store.dispatch(
      ComputePlayerRankingsAction(),
    );
  }
}

/// An action to set the list of players.
class SetPlayersAction extends ReduxAction<AppState> {
  final List<Player> players;

  SetPlayersAction({this.players});

  @override
  AppState reduce() {
    return state.copyWith(
      playerState: state.playerState.copyWith(
        players: players,
      ),
    );
  }
}

/// An action to (re)compute player rankings.
class ComputePlayerRankingsAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    // Initialize a map of ratings to the starting rating.
    final playerMap = <String, double>{};
    for (final p in store.state.playerState.players) {
      playerMap.putIfAbsent(p.name, () => ELO_STARTING_RATING);
    }

    // Initialize the list of updated matches (with proper player pointers)
    final matches = <Match>[];

    for (final m in store.state.matchesState.matches) {
      // Get existing ratings.
      final ratingP1 = playerMap[m.player1.name];
      final ratingP2 = playerMap[m.player2.name];

      // Compute new ratings from this match
      final newRatings = computeNewPlayerRankings(
        playerMap[m.player1.name],
        playerMap[m.player2.name],
        m.winner == MatchWinner.Player1,
      );

      // Insert new rating back into the map.
      playerMap[m.player1.name] = newRatings[0];
      playerMap[m.player2.name] = newRatings[1];

      // Append a new match to the list with two players and their rating *after* the match.
      matches.add(
        Match(
          player1: Player(name: m.player1.name, rating: ratingP1),
          player2: Player(name: m.player2.name, rating: ratingP2),
          winner: m.winner,
          timestamp: m.timestamp,
          eloDelta1: newRatings[0] - ratingP1,
          eloDelta2: newRatings[1] - ratingP2,
        ),
      );
    }

    // Create the final list of ranked players, and sort them
    final rankedPlayers = playerMap.entries
        .map((entry) => Player(name: entry.key, rating: entry.value))
        .toList();
    rankedPlayers.sort((p1, p2) => p2.rating.compareTo(p1.rating));

    return state.copyWith(
      playerState: state.playerState.copyWith(
        players: rankedPlayers,
      ),
      matchesState: state.matchesState.copyWith(
        matches: matches,
      ),
    );
  }
}

// -- Match Actions
class AddMatchAction extends ReduxAction<AppState> {
  final Player player1, player2;
  final MatchWinner winner;

  AddMatchAction({this.player1, this.player2, this.winner});

  @override
  AppState reduce() {
    final match = Match(
        player1: player1,
        player2: player2,
        winner: winner,
        timestamp: DateTime.now().toUtc());
    Firestore.instance.collection(_MATCHES_COLLECTION).add(match.toJson());
    print('added match');
    return null;
  }
}

class SetMatchesAction extends ReduxAction<AppState> {
  final List<Match> matches;

  SetMatchesAction({this.matches});
  @override
  AppState reduce() {
    print('setting matches ' + matches.length.toString());
    matches.sort((m1, m2) => m1.timestamp.compareTo(m2.timestamp));
    return store.state.copyWith(
      matchesState: store.state.matchesState.copyWith(matches: matches),
    );
  }

  @override
  void after() {
    store.dispatch(ComputePlayerRankingsAction());
  }
}

// -- Subscription Actions

/// An action to initialize all Firestore subscriptions.
class RequestSubscriptionsAction extends ReduxAction<AppState> {
  static StreamSubscription<QuerySnapshot> _playersSubscription;
  static StreamSubscription<QuerySnapshot> _matchesSubscription;

  @override
  AppState reduce() {
    // Create the players subscription
    _playersSubscription = Firestore.instance
        .collection(_PLAYERS_COLLECTION)
        .snapshots()
        .listen((snapshot) {
      // Create the player objects from the collection
      final players = snapshot.documents
          .map((document) => Player.fromJson(document.data))
          .toList();
      // Set our list of players and computer rankings
      store.dispatch(SetPlayersAction(players: players));
    });
    // Create the matches subscription
    _matchesSubscription = Firestore.instance
        .collection(_MATCHES_COLLECTION)
        .snapshots()
        .listen((snapshot) {
      final matches = snapshot.documents
          .map((document) => Match.fromJson(document.data))
          .toList();
      store.dispatch(SetMatchesAction(matches: matches));
    });

    return null;
  }
}

/// An action to cancel (i.e. disconnect) all subscriptions.
class CancelSubscriptionsAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    RequestSubscriptionsAction._playersSubscription?.cancel();
    RequestSubscriptionsAction._matchesSubscription?.cancel();
    return null;
  }
}
