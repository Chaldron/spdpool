import 'dart:async';
import 'dart:math';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spd_pool/state/state.dart';

const String _PLAYERS_COLLECTION = 'players';

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

  SetPlayersAction(this.players);

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
    final rankedPlayers = List.from(state.playerState.players)
        .map<Player>((player) => Player(
            name: player.name, ranking: Random().nextInt(3000).toDouble()))
        .toList();
    rankedPlayers.sort((p1, p2) => p2.ranking.compareTo(p1.ranking));
    return state.copyWith(
      playerState: state.playerState.copyWith(
        players: rankedPlayers,
      ),
    );
  }
}

// -- Subscription Actions

/// An action to initialize all Firestore subscriptions.
class RequestSubscriptionsAction extends ReduxAction<AppState> {
  static StreamSubscription<QuerySnapshot> _playerSubscription;

  @override
  AppState reduce() {
    // Create the players subscription
    _playerSubscription = Firestore.instance
        .collection(_PLAYERS_COLLECTION)
        .snapshots()
        .listen((snapshot) {
      // Create the player objects from the collection
      final players = snapshot.documents
          .map((document) => Player.fromJson(document.data))
          .toList();
      // Set our list of players and computer rankings
      store.dispatch(SetPlayersAction(players));
      store.dispatch(ComputePlayerRankingsAction());
    });
    return null;
  }
}

/// An action to cancel (i.e. disconnect) all subscriptions.
class CancelSubscriptionsAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    RequestSubscriptionsAction._playerSubscription?.cancel();
    return null;
  }
}
