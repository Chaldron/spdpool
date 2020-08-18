import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:redux/redux.dart';
import 'package:spd_pool/state/state.dart';

/// Creates the root middleware, combining all other middleware.
List<Middleware<AppState>> rootMiddleware() {
  return [
    TypedMiddleware<AppState, RequestSubscriptionsAction>(
        createPlayersSubscription()),
    TypedMiddleware<AppState, CreatePlayerAction>(
      createPlayer()
    ),
    TypedMiddleware<AppState, CancelSubscriptionsAction>(cancelSubscriptions())
  ];
}

// -- Player Middleware

/// Middleware to create a new player.
Middleware<AppState> createPlayer() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    Firestore.instance.collection('players').add(action.player.toJson());
    next(action);
  };
}

// -- Subscription Middleware

/// Middleware to create the Firestore players subscription.
Middleware<AppState> createPlayersSubscription() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    // ignore: cancel_subscriptions
    final subscription = Firestore.instance
        .collection('players')
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((element) {
        store.dispatch(AddPlayerAction(Player.fromJson(element.document.data)));
        store.dispatch(ComputePlayerRankingsAction());
      });
    });
    store.dispatch(AddSubscriptionAction(subscription));
    next(action);
  };
}

/// Middleware to cancel all subscriptions.
Middleware<AppState> cancelSubscriptions() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    store.state.subscriptions.map((subscription) => subscription.cancel());
    next(action);
  };
}
