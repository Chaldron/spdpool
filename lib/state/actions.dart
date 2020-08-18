import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:spd_pool/state/state.dart';

// -- Player Actions

@immutable

/// An action to add a player to the store.
class AddPlayerAction {
  final Player player;

  AddPlayerAction(this.player);
}

/// An action to create a new player.
class CreatePlayerAction {
  final Player player;

  CreatePlayerAction(this.player);
}

@immutable

/// An action to (re)compute player rankings.
class ComputePlayerRankingsAction {}

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
