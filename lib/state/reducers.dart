import 'dart:async';
import 'package:redux/redux.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:spd_pool/state/state.dart';

/// Creates the root reducer, combining all other reducers.
AppState rootReducer(AppState state, action) {
  return AppState(
      players: playerReducer()(state.players, action),
      matches: state.matches,
      subscriptions: subscriptionReducer()(state.subscriptions, action));
}

/// Creates the player reducers, combining all other player reducers.
List<Player> Function(List<Player> players, dynamic action) playerReducer() {
  return combineReducers<List<Player>>(
      [TypedReducer<List<Player>, AddPlayerAction>(_addPlayerReducer)]);
}

/// Reducer to add a player.
List<Player> _addPlayerReducer(List<Player> players, AddPlayerAction action) {
  return List.from(players)..add(action.player);
}

/// Reducer to compute player rankings.
List<Player> _computePlayerRankings(
    List<Player> players, ComputePlayerRankingsAction action) {
  return List.from(players);
}

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
