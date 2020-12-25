import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spd_pool/state/state.dart';

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
    var playerMap = Map<String, double>();
    for (Player p in store.state.playerState.players) {
      playerMap.putIfAbsent(p.name, () => p.ranking);
    }
    for (final Match m in store.state.matchesState.matches) {
      double rating1 = playerMap[m.player1.name];
      double rating2 = playerMap[m.player2.name];

      double P1 = (1.0 / (1.0 + pow(10, ((rating1 - rating2) / 400))));
      double P2 = (1.0 / (1.0 + pow(10, ((rating2 - rating1) / 400))));

      double p1score = m.winner == MatchWinner.Player1 ? 1 : 0;
      double p2score = m.winner == MatchWinner.Player2 ? 1 : 0;

      double k = 10;
      rating1 = rating1 + k * (p1score - P1);
      rating2 = rating2 + k * (p2score - P2);

      playerMap[m.player1.name] = rating1;
      playerMap[m.player2.name] = rating2;
    }
    List<Player> rankedPlayers = playerMap.entries
        .map((entry) => Player(name: entry.key, ranking: entry.value))
        .toList();
    rankedPlayers.sort((p1, p2) => p2.ranking.compareTo(p1.ranking));
    return state.copyWith(
      playerState: state.playerState.copyWith(
        players: rankedPlayers,
      ),
    );
    /*final rankedPlayers = List.from(state.playerState.players)
        .map<Player>((player) => Player(
            name: player.name, ranking: Random().nextInt(3000).toDouble()))
        .toList();
    rankedPlayers.sort((p1, p2) => p2.ranking.compareTo(p1.ranking));
    return state.copyWith(
      playerState: state.playerState.copyWith(
        players: rankedPlayers,
      ),
    );*/
    return null;
  }
}

// -- Match Actions
class AddMatchAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    int i1 = Random().nextInt(store.state.playerState.players.length);
    int i2 = Random().nextInt(store.state.playerState.players.length);
    while (i2 == i1)
      i2 = Random().nextInt(store.state.playerState.players.length);
    Player p1 = store.state.playerState.players[i1];
    Player p2 = store.state.playerState.players[i2];
    final match = Match(player1: p1, player2: p2, winner: MatchWinner.Player1);
    Firestore.instance
        .collection(_MATCHES_COLLECTION)
        .add(json.decode(json.encode(match)));
    print("added match");
    return null;
  }
}

class SetMatchesAction extends ReduxAction<AppState> {
  final List<Match> matches;

  SetMatchesAction({this.matches});
  @override
  AppState reduce() {
    matches.sort((m1, m2) => m1.timestamp.compareTo(m2.timestamp));
    return store.state.copyWith(
      matchesState: store.state.matchesState.copyWith(matches: matches),
    );
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
      store.dispatch(ComputePlayerRankingsAction());
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
      store.dispatch(ComputePlayerRankingsAction());
    });

    return null;
  }
}

/// An action to cancel (i.e. disconnect) all subscriptions.
class CancelSubscriptionsAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    RequestSubscriptionsAction._playersSubscription?.cancel();
    return null;
  }
}
