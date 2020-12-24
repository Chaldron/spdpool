import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spd_pool/state/actions.dart';
import 'package:redux/redux.dart';
import 'package:spd_pool/state/state.dart';
import 'package:spd_pool/constants.dart' as Constants;

/// Creates the root middleware, combining all other middleware.
List<Middleware<AppState>> rootMiddleware() {
  return [
    TypedMiddleware<AppState, RequestSubscriptionsAction>(
        createPlayersSubscription()),
    TypedMiddleware<AppState, RegisterPlayerAction>(createPlayer()),
    TypedMiddleware<AppState, CancelSubscriptionsAction>(cancelSubscriptions())
  ];
}

// -- Player Middleware

/// Middleware to create a new player.
Middleware<AppState> createPlayer() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    // Add a new player to the Firestore collection.
    Firestore.instance
        .collection(Constants.FIREBASE_PLAYERS_COLLECTION)
        .add(action._player.toJson());
    // Recompute player rankings.
    store.dispatch(ComputePlayerRankingsAction(store.state.matches));
    next(action);
  };
}

// -- Subscription Middleware

/// Middleware to create the Firestore players subscription.
Middleware<AppState> createPlayersSubscription() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    // Subscribe to the players collection, setting the local copy of players each time a new snapshot is fired.
    // ignore: cancel_subscriptions
    final subscription = Firestore.instance
        .collection(Constants.FIREBASE_PLAYERS_COLLECTION)
        .snapshots()
        .listen((snapshot) {
      // Map the collection's documents to Player objects.
      final players = snapshot.documents
          .map((documentSnapshot) => Player.fromJson(documentSnapshot.data))
          .toList();
      // Update the players in the store, and recompute their rankings.
      store.dispatch(SetPlayersAction(players));
      store.dispatch(ComputePlayerRankingsAction(store.state.matches));
    });
    // Store the subscription we just made in the store, so it can be cancelled/deleted later.
    store.dispatch(AddSubscriptionAction(subscription));
    next(action);
  };
}

/// Middleware to cancel all subscriptions.
Middleware<AppState> cancelSubscriptions() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    // Cancel every Firestore subscription.
    print("cancelling");
    store.state.subscriptions.forEach((subscription) => subscription.cancel());
    next(action);
  };
}
