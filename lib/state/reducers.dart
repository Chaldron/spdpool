import 'dart:async';
import 'package:redux/redux.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

/// Creates the root reducer, combining all other reducers.
AppState rootReducer(AppState state, action) {
  return AppState(
      players: _playerReducer()(state.players, action),
      matches: state.matches,
      subscriptions: subscriptionReducer()(state.subscriptions, action));
}

// -- Player Reducers

/// Creates the root player reducer, combining all other player reducers.
List<Player> Function(List<Player> players, dynamic action) _playerReducer() {
  return combineReducers<List<Player>>([
    TypedReducer<List<Player>, SetPlayersAction>(_setPlayersReducer),
    TypedReducer<List<Player>, ComputePlayerRankingsAction>(
        _computePlayerRankings)
  ]);
}

/// Reducer to set the list of players.
List<Player> _setPlayersReducer(List<Player> players, SetPlayersAction action) {
  return action.players;
}

/// Reducer to compute player rankings.
List<Player> _computePlayerRankings(
    List<Player> players, ComputePlayerRankingsAction action) {
  return List.from(players
      .map((player) => Player(name: player.name, ranking: 100))
      .toList());
}

// -- Subscription Reducers

/// Creates all subscription reducers, combining all other subscription reducers.
List<StreamSubscription> Function(
        List<StreamSubscription> subscriptions, dynamic action)
    subscriptionReducer() {
  return combineReducers<List<StreamSubscription>>([
    TypedReducer<List<StreamSubscription>, AddSubscriptionAction>(
        _addSubscriptionReducer),
    TypedReducer<List<StreamSubscription>, DeleteSubscriptionsAction>(
        _deleteSubscriptionsReducer)
  ]);
}

/// Reducer to add a subscription.
List<StreamSubscription> _addSubscriptionReducer(
    List<StreamSubscription> subscriptions, AddSubscriptionAction action) {
  return List.from(subscriptions)..add(action.subscription);
}

/// Reducer to delete all subscriptions.
List<StreamSubscription> _deleteSubscriptionsReducer(
    List<StreamSubscription> subscriptions, DeleteSubscriptionsAction action) {
  return List.empty();
}
