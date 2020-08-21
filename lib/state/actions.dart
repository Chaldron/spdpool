import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:spd_pool/state/state.dart';

// -- Player Actions

/// An action to register a new player.
@immutable
class RegisterPlayerAction {
  final Player player;

  RegisterPlayerAction(this.player);
}

/// An action to set the list of players.
@immutable
class SetPlayersAction {
  final List<Player> players;

  SetPlayersAction(this.players);
}

/// An action to (re)compute player rankings.
@immutable
class ComputePlayerRankingsAction {
  final List<Match> matches;

  ComputePlayerRankingsAction(this.matches);
}

// -- Subscription Actions

@immutable

/// An action to initialize all Firestore subscriptions.
class RequestSubscriptionsAction {}

@immutable

/// An action to add a subscription to the store.
class AddSubscriptionAction {
  final StreamSubscription subscription;

  AddSubscriptionAction(this.subscription);
}

@immutable

/// An action to cancel (i.e. disconnect) all subscriptions.
class CancelSubscriptionsAction {}

@immutable

/// An action to delete (i.e. remove) all subscriptions from the store.
class DeleteSubscriptionsAction {}
